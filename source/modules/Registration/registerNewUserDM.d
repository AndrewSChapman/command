module decisionmakers.registeruser;

import std.exception;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.registeruser;
import helpers.testhelper;

struct RegisterNewUserFacts
{
    bool userAlreadyExists;
    string userFirstName;
    string userLastName;
    string email;
    string password;    
}

class RegisterUserDM : DecisionMakerInterface
{
    private RegisterNewUserFacts facts;
    
    public this(ref RegisterNewUserFacts facts) @safe
    {
        enforce(facts.userFirstName != "", "Please supply a user first name");
        enforce(facts.userLastName != "", "Please supply a user last name");
        enforce(facts.email != "", "Please supply a user email address");
        enforce(facts.password.length >= 8, "Please supply a password that is at least 8 characters long");
        enforce(!facts.userAlreadyExists, "A user already exists with this email address.");

        this.facts = facts;
    }

    public void issueCommands(EventListInterface eventList) @safe
    {
        auto command = new RegisterUserCommand(
            this.facts.userFirstName,
            this.facts.userLastName,
            this.facts.email,
            this.facts.password
        );

        eventList.append(command, typeid(RegisterUserCommand));
    }
}

unittest {
    // Test passing facts
    RegisterNewUserFacts[] passingFactsArray;
    passingFactsArray ~= RegisterNewUserFacts(false, "Harry", "Potter", "harry@potter.com", "PassW0rd");

    foreach(facts; passingFactsArray) {
        TestHelper.testDecisionMaker!(RegisterUserDM, RegisterNewUserFacts)(facts, 1, false);
    }

    // Test failing facts
    RegisterNewUserFacts[] failingFactsArray;
    failingFactsArray ~= RegisterNewUserFacts(true, "Harry", "Potter", "harry@potter.com", "PassW0rd");
    failingFactsArray ~= RegisterNewUserFacts(false, "", "Potter", "harry@potter.com", "PassW0rd");
    failingFactsArray ~= RegisterNewUserFacts(false, "Harry", "", "harry@potter.com", "PassW0rd");
    failingFactsArray ~= RegisterNewUserFacts(false, "Harry", "Potter", "", "PassW0rd");
    failingFactsArray ~= RegisterNewUserFacts(false, "Harry", "Potter", "harry@potter.com", "");

    foreach(facts; failingFactsArray) {
        TestHelper.testDecisionMaker!(RegisterUserDM, RegisterNewUserFacts)(facts, 0, true);    
    }
}