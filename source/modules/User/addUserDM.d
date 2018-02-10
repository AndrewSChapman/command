module decisionmakers.adduser;

import std.exception;
import vibe.vibe;

import validators.all;
import command.decisionmakerinterface;
import command.all;
import commands.adduser;
import helpers.testhelper;
import entity.user;

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

class AddUserDM : AbstractDecisionMaker,DecisionMakerInterface
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

    public ulong getNewUsrId() @safe
    {
        return this.router.getEventMessage!ulong("usrId");
    }    
}

unittest {
    // Test passing facts
    AddUserFacts[] passingFactsArray;
    passingFactsArray ~= AddUserFacts(false, false, UserType.GENERAL, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    passingFactsArray ~= AddUserFacts(false, false, UserType.ADMIN, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");

    foreach(facts; passingFactsArray) {
        TestHelper.testDecisionMaker!(AddUserDM, AddUserFacts)(facts, 1, false);
    }

    // Test failing facts
    AddUserFacts[] failingFactsArray;
    failingFactsArray ~= AddUserFacts(true, false, UserType.GENERAL, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, true, UserType.GENERAL, "HarryPotter", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, false, UserType.GENERAL, "", "Harry", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, false, UserType.GENERAL,"HarryPotter", "", "Potter", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, false, UserType.GENERAL, "HarryPotter", "Harry", "", "harry@potter.com", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, false, UserType.GENERAL, "HarryPotter", "Harry", "Potter", "", "PassW0rd*£2017");
    failingFactsArray ~= AddUserFacts(false, false, UserType.GENERAL, "HarryPotter", "Harry", "Potter", "harry@potter.com", "");

    foreach(facts; failingFactsArray) {
        TestHelper.testDecisionMaker!(AddUserDM, AddUserFacts)(facts, 0, true);    
    }
}