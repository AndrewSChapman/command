module decisionmakers.login;

import std.exception;
import std.stdio;
import vibe.vibe;

import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.login;
import commands.assignprefix;
import helpers.testhelper;

struct LoginFacts
{
    bool userExists;
    bool passwordCorrect;
    bool prefixExists;
    bool prefixAssignedToUser;
    bool prefixNotAssigned;
    ulong usrId;
    string userAgent;
    string ipAddress;
    string prefix;    
}

class LoginDM : DecisionMakerInterface
{
    private LoginFacts facts;
    
    public this(ref LoginFacts facts) @safe
    {
        enforce(facts.userExists, "Sorry, a user account with the specified email address does not exist.");
        enforce(facts.passwordCorrect, "Sorry, the supplied password was incorrect.");            
        enforce(facts.prefixExists, "Sorry, the prefix code you supplied was invalid.");
        enforce(facts.prefixNotAssigned || facts.prefixAssignedToUser, "The supplied prefix is already assigned to a user or is not assigned to you.  Please generate a new prefix to complete this operation.");
        enforce(facts.usrId > 0, "Please supply a valid user Id.");
        enforce(facts.userAgent != "", "Please supply a user agent string.");
        enforce(facts.ipAddress != "", "Please supply an IP address.");
        enforce(facts.prefix != "", "Please supply a valid prefix code.");        

        this.facts = facts;
    }

    public void issueCommands(EventListInterface eventList) @safe
    {
        if (facts.prefixNotAssigned) {
            eventList.append(new AssignPrefixCommand(facts.prefix, facts.usrId), typeid(AssignPrefixCommand));
        }

        auto command = new LoginCommand(
            facts.usrId,
            facts.userAgent,
            facts.ipAddress,
            facts.prefix
        );
        
        eventList.append(command, typeid(LoginCommand));
    }
}

unittest {
    LoginDMMeta meta;
    meta.usrId = 1;
    meta.userAgent = "TESTAGENT";
    meta.ipAddress = "192.168.1.100";
    meta.prefix = "ABCDE";

    // Test passing facts
    function (ref LoginDMMeta meta) {
        Loginfacts facts;
        facts.userExists = true;
        facts.passwordCorrect = true;
        facts.prefixExists = true;
        facts.prefixAssignedToUser = true;
        facts.prefixNotAssigned = false;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, Loginfacts)(meta, facts, 1, false);
    }(meta);

    function (ref LoginDMMeta meta) {
        Loginfacts facts;
        facts.userExists = true;
        facts.passwordCorrect = true;
        facts.prefixExists = true;
        facts.prefixAssignedToUser = false;
        facts.prefixNotAssigned = true;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, Loginfacts)(meta, facts, 2, false);
    }(meta);

    // Test failing facts
    function (ref LoginDMMeta meta) {
        Loginfacts facts;
        facts.userExists = false;
        facts.passwordCorrect = true;
        facts.prefixExists = true;
        facts.prefixAssignedToUser = false;
        facts.prefixNotAssigned = true;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, Loginfacts)(meta, facts, 0, true);
    }(meta);

    function (ref LoginDMMeta meta) {
        Loginfacts facts;
        facts.userExists = true;
        facts.passwordCorrect = false;
        facts.prefixExists = true;
        facts.prefixAssignedToUser = false;
        facts.prefixNotAssigned = true;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, Loginfacts)(meta, facts, 0, true);
    }(meta);    

    function (ref LoginDMMeta meta) {
        Loginfacts facts;
        facts.userExists = true;
        facts.passwordCorrect = true;
        facts.prefixExists = false;
        facts.prefixAssignedToUser = false;
        facts.prefixNotAssigned = true;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, Loginfacts)(meta, facts, 0, true);
    }(meta);

    function (ref LoginDMMeta meta) {
        Loginfacts facts;
        facts.userExists = true;
        facts.passwordCorrect = true;
        facts.prefixExists = true;
        facts.prefixAssignedToUser = false;
        facts.prefixNotAssigned = false;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, Loginfacts)(meta, facts, 0, true);
    }(meta);        
}