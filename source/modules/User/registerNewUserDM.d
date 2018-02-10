module decisionmakers.registeruser;

import std.exception;
import vibe.vibe;

import validators.all;
import dcorelib;
import command.decisionmakerinterface;
import command.all;
import commands.registeruser;
import helpers.testhelper;

struct RegisterNewUserFacts
{
    bool usernameAlreadyExists;
    bool emailAlreadyExists;
    string username;
    string userFirstName;
    string userLastName;
    string email;
    string password;    
}

class RegisterUserDM : AbstractDecisionMaker,DecisionMakerInterface
{
    private RegisterNewUserFacts facts;
    
    public this(ref RegisterNewUserFacts facts) @safe
    {
        enforce(!facts.usernameAlreadyExists, "A user already exists with this username.");
        enforce(!facts.emailAlreadyExists, "A user already exists with this email address.");

        // Enforce value correctness
        (new Varchar255Required(facts.username, "username"));
        (new Varchar255Required(facts.userFirstName, "userFirstName"));
        (new Varchar255Required(facts.userLastName, "userLastName"));
        (new EmailAddressRequired(facts.email, "email"));
        (new Password(facts.password, "password"));
        
        this.facts = facts;
    }

    public void issueCommands(CommandBusInterface commandBus) @safe
    {
        auto command = new RegisterUserCommand(
            this.facts.username,
            this.facts.userFirstName,
            this.facts.userLastName,
            this.facts.email,
            this.facts.password
        );

        commandBus.append(command, typeid(RegisterUserCommand));
    }
}

unittest {
    // Test passing facts
    RegisterNewUserFacts[] passingFactsArray;
    passingFactsArray ~= RegisterNewUserFacts(false, false, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");

    foreach(facts; passingFactsArray) {
        TestHelper.testDecisionMaker!(RegisterUserDM, RegisterNewUserFacts)(facts, 1, false);
    }

    // Test failing facts
    RegisterNewUserFacts[] failingFactsArray;
    failingFactsArray ~= RegisterNewUserFacts(true, false, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= RegisterNewUserFacts(false, true, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= RegisterNewUserFacts(false, false, "", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= RegisterNewUserFacts(false, false, "HarryPotter", "", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= RegisterNewUserFacts(false, false, "HarryPotter", "Harry", "", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= RegisterNewUserFacts(false, false, "HarryPotter", "Harry", "Potter", "", "PassW0rd*£2017");
    failingFactsArray ~= RegisterNewUserFacts(false, false, "HarryPotter", "Harry", "Potter", "harry@potter.com", "");

    foreach(facts; failingFactsArray) {
        TestHelper.testDecisionMaker!(RegisterUserDM, RegisterNewUserFacts)(facts, 0, true);    
    }
}