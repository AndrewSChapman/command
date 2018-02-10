module decisionmakers.login;

import std.exception;
import std.stdio;
import vibe.vibe;

import vibe.vibe;

import dcorelib;
import command.all;
import commands.login;
import commands.assignprefix;
import commands.incrementfailedlogincount;
import entity.token;
import helpers.testhelper;
import facts.toomanyfailedlogins;

struct LoginFacts
{
    bool userExists;
    bool userDeleted;
    bool passwordCorrect;
    bool prefixExists;
    bool prefixAssignedToUser;
    bool prefixNotAssigned;
    TooManyFailedLogins tooManyFailedLogins;
    ulong usrId;
    uint usrType;
    string userAgent;
    string ipAddress;
    string prefix;    
}

class LoginDM : AbstractDecisionMaker,DecisionMakerInterface
{
    private LoginFacts facts;
    
    public this(ref LoginFacts facts) @safe
    {
        enforce(facts.userExists, "Sorry, a user account with the specified email address does not exist.");
        enforce(!facts.userDeleted, "Sorry, your user account is not accessible.");        
        enforce(facts.prefixExists, "Sorry, the prefix code you supplied was invalid.");
        enforce(facts.prefixNotAssigned || facts.prefixAssignedToUser, "The supplied prefix is already assigned to a user or is not assigned to you.  Please generate a new prefix to complete this operation.");
        enforce(facts.usrId > 0, "Please supply a valid user Id.");
        enforce(facts.usrType >= 0 && facts.usrType <= 1, "Please supply a valid usrType.");
        enforce(facts.userAgent != "", "Please supply a user agent string.");
        enforce(facts.prefix != "", "Please supply a valid prefix code."); 
        enforce((!(facts.tooManyFailedLogins is null)) && !facts.tooManyFailedLogins.isTrue(), 
            "You have tried to login too many times with an incorrect password.  You must now reset your password.");

        (new Varchar255Required(facts.ipAddress, "ipAddress"));

        this.facts = facts;

        // As the login command returns information to us and we need to be sure
        // the login has succeeded, this cannot run asyncronsously.
        this.executeCommandsAsyncronously = false;
    }

    public void issueCommands(CommandBusInterface commandBus) @safe
    {
        if (facts.passwordCorrect) {        
            if (facts.prefixNotAssigned) {
                commandBus.append(new AssignPrefixCommand(facts.prefix, facts.usrId), typeid(AssignPrefixCommand));
            }

            auto command = new LoginCommand(
                facts.usrId,
                facts.usrType,
                facts.userAgent,
                facts.ipAddress,
                facts.prefix
            );
            
            commandBus.append(command, typeid(LoginCommand));

            // Add command to reset failed login count and set lastLoginDate
        } else {
            auto command = new IncrementFailedLoginCountCommand(facts.usrId);
            commandBus.append(command, typeid(IncrementFailedLoginCountCommand));
        }
    }

    public Token getLoginToken() @safe
    {
        return this.router.getEventMessage!Token("token");
    }

    override protected void throwExceptionIfNecessary() @safe
    {
        if (!facts.passwordCorrect) {
            throw new Exception("Sorry, your login password was incorrect");
        }
    }    
}

unittest {
    LoginFacts facts;
    facts.usrId = 1;
    facts.usrType = 0;
    facts.userAgent = "TESTAGENT";
    facts.ipAddress = "192.168.1.100";
    facts.prefix = "ABCDE";
    facts.tooManyFailedLogins = new TooManyFailedLogins(0);

    // Test passing facts
    function (ref LoginFacts facts) {
        facts.userExists = true;
        facts.userDeleted = false;
        facts.passwordCorrect = true;
        facts.prefixExists = true;
        facts.prefixAssignedToUser = true;
        facts.prefixNotAssigned = false;
        
        TestHelper.testDecisionMaker!(LoginDM, LoginFacts)(facts, 1, false);
    }(facts);

    function (ref LoginFacts facts) {
        facts.userExists = true;
        facts.userDeleted = false;
        facts.passwordCorrect = true;
        facts.prefixExists = true;
        facts.prefixAssignedToUser = false;
        facts.prefixNotAssigned = true;
        facts.tooManyFailedLogins = new TooManyFailedLogins(3);

        TestHelper.testDecisionMaker!(LoginDM, LoginFacts)(facts, 2, false);
    }(facts);

    // Test failing facts
    function (ref LoginFacts facts) {
        facts.userExists = true;
        facts.userDeleted = false;
        facts.passwordCorrect = true;
        facts.prefixExists = true;
        facts.prefixAssignedToUser = true;
        facts.prefixNotAssigned = false;

        TestHelper.testDecisionMaker!(LoginDM, LoginFacts)(facts, 1, false);
    }(facts);

    function (ref LoginFacts facts) {
        facts.userExists = false;
        facts.userDeleted = false;
        facts.passwordCorrect = true;
        facts.prefixExists = true;
        facts.prefixAssignedToUser = false;
        facts.prefixNotAssigned = true;

        TestHelper.testDecisionMaker!(LoginDM, LoginFacts)(facts, 0, true);
    }(facts);

    function (ref LoginFacts facts) {
        facts.userExists = true;
        facts.userDeleted = false;
        facts.passwordCorrect = true;
        facts.prefixExists = true;
        facts.prefixAssignedToUser = false;
        facts.prefixNotAssigned = true;
        facts.tooManyFailedLogins = new TooManyFailedLogins(10);

        TestHelper.testDecisionMaker!(LoginDM, LoginFacts)(facts, 0, true);
    }(facts);    

    function (ref LoginFacts facts) {
        facts.userExists = true;
        facts.userDeleted = false;
        facts.passwordCorrect = true;
        facts.prefixExists = false;
        facts.prefixAssignedToUser = false;
        facts.prefixNotAssigned = true;

        TestHelper.testDecisionMaker!(LoginDM, LoginFacts)(facts, 0, true);
    }(facts);

    function (ref LoginFacts facts) {
        facts.userExists = true;
        facts.userDeleted = false;
        facts.passwordCorrect = true;
        facts.prefixExists = true;
        facts.prefixAssignedToUser = false;
        facts.prefixNotAssigned = false;

        TestHelper.testDecisionMaker!(LoginDM, LoginFacts)(facts, 0, true);
    }(facts);        
}