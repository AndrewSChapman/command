module decisionmakers.adduser;

import std.exception;
import vibe.vibe;

import validators.all;
import decisionmakers.decisionmakerinterface;
import command.all;
import commands.adduser;
import helpers.testhelper;

struct AddUserFacts
{
    bool usernameAlreadyExists;
    bool emailAlreadyExists;
    uint usrType;
    string username;
    string userFirstName;
    string userLastName;
    string email;
    string password;    
}

class AddUserDM : DecisionMakerInterface
{
    private AddUserFacts facts;
    
    public this(ref AddUserFacts facts) @safe
    {
        enforce(!facts.usernameAlreadyExists, "A user already exists with this username.");
        enforce(!facts.emailAlreadyExists, "A user already exists with this email address.");
        enforce(facts.usrType <= 1, "Invalid usrType value - must be 0 or 1.");

        // Enforce value correctness
        (new Varchar255Required(facts.username, "username"));
        (new Varchar255Required(facts.userFirstName, "userFirstName"));
        (new Varchar255Required(facts.userLastName, "userLastName"));
        (new EmailAddressRequired(facts.email, "email"));
        (new Password(facts.password, "password"));
        
        this.facts = facts;
    }

    public void issueCommands(CommandBusInterface commandList) @safe
    {
        auto command = new AddUserCommand(
            this.facts.usrType,
            this.facts.username,
            this.facts.userFirstName,
            this.facts.userLastName,
            this.facts.email,
            this.facts.password
        );

        commandList.append(command, typeid(AddUserCommand));
    }
}

unittest {
    // Test passing facts
    AddUserFacts[] passingFactsArray;
    passingFactsArray ~= AddUserFacts(false, false, 0, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    passingFactsArray ~= AddUserFacts(false, false, 1, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");

    foreach(facts; passingFactsArray) {
        TestHelper.testDecisionMaker!(RegisterUserDM, AddUserFacts)(facts, 1, false);
    }

    // Test failing facts
    AddUserFacts[] failingFactsArray;
    failingFactsArray ~= AddUserFacts(true, false, 0, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, true, 0, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, false, 3, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, false, 0, "", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, false, 0,"HarryPotter", "", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, false, 0, "HarryPotter", "Harry", "", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, false, 0, "HarryPotter", "Harry", "Potter", "", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, false, 0, "HarryPotter", "Harry", "Potter", "harry@potter.com", "");

    foreach(facts; failingFactsArray) {
        TestHelper.testDecisionMaker!(RegisterUserDM, AddUserFacts)(facts, 0, true);    
    }
}