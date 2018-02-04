module decisionmakers.changepassword;

import std.exception;
import std.stdio;
import vibe.vibe;

import validators.all;
import decisionmakers.decisionmakerinterface;
import command.all;
import commands.changepassword;
import helpers.testhelper;

struct ChangePasswordFacts
{
    bool userLoggedIn;
    bool repeatedPasswordMatches;
    bool existingPasswordIsCorrect;
    ulong usrId;
    string password;
}

class ChangePasswordDM : DecisionMakerInterface
{
    private ChangePasswordFacts facts;
    
    public this(ref ChangePasswordFacts facts) @safe
    {
        enforce(facts.userLoggedIn, "Sorry, you must be logged in to perform this action.");
        enforce(facts.repeatedPasswordMatches, "Sorry, your repeated password does not match the new password.");
        enforce(facts.existingPasswordIsCorrect, "Sorry, your current password doesn't match what you've entered as your existing password.");

        (new Password(facts.password, "password"));
        (new PositiveNumber!ulong(facts.usrId, "usrId"));        
                
        this.facts = facts;
    }

    public void issueCommands(CommandBusInterface commandList) @safe
    {        
        auto command = new ChangePasswordCommand(
            this.facts.usrId,
            this.facts.password
        );

        commandList.append(command, typeid(ChangePasswordCommand));
    }
}

unittest {
    ChangePasswordFacts facts;
    facts.usrId = 1;
    facts.password = "MyNewCrazyPassword";

    // Test passing facts
    function (ref ChangePasswordFacts facts) {
        facts.userLoggedIn = true;
        facts.repeatedPasswordMatches = true;
        facts.existingPasswordIsCorrect = true;

        TestHelper.testDecisionMaker!(
            ChangePasswordDM,
            ChangePasswordFacts,
        )(facts, 1, false);
    }(facts);

    // Test failing facts
    function (ref ChangePasswordFacts facts) {
        facts.userLoggedIn = false;
        facts.repeatedPasswordMatches = true;
        facts.existingPasswordIsCorrect = true;

        TestHelper.testDecisionMaker!(
            ChangePasswordDM,
            ChangePasswordFacts
        )(facts, 0, true);
    }(facts);  

    // Test failing facts
    function (ref ChangePasswordFacts facts) {
        facts.userLoggedIn = true;
        facts.repeatedPasswordMatches = false;
        facts.existingPasswordIsCorrect = true;

        TestHelper.testDecisionMaker!(
            ChangePasswordDM,
            ChangePasswordFacts
        )(facts, 0, true);
    }(facts);

    // Test failing facts
    function (ref ChangePasswordFacts facts) {
        facts.userLoggedIn = true;
        facts.repeatedPasswordMatches = true;
        facts.existingPasswordIsCorrect = false;

        TestHelper.testDecisionMaker!(
            ChangePasswordDM,
            ChangePasswordFacts
        )(facts, 0, true);
    }(facts);     
}
