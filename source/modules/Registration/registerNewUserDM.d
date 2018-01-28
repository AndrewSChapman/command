module decisionmakers.registeruser;

import std.exception;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.registeruser;

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
    RegisterNewUserFacts facts;
    facts.userFirstName = "Joe";
    facts.userLastName = "Bloggs";
    facts.email = "job.blogs@chapmandigital.co.uk";
    facts.password = "FishF1shFish";

    void testHappyPath(ref RegisterNewUserFacts facts) {
        // Test the happy path
        RegisterNewUserFacts facts;
        facts.userAlreadyExists = false;

        auto command = new RegisterUserDM(facts, facts);
        auto eventList = new EventList();
        command.issueCommands(eventList);

        // Ensure an event was created by the command
        assert(eventList.size() == 1);
    }

    void testUserAlreadyExists(ref RegisterNewUserFacts facts) {
        // Test the happy path
        RegisterNewUserFacts facts;
        facts.userAlreadyExists = true;

        auto eventList = new EventList();
        bool errorThrown = false;

        try {
            auto command = new RegisterUserDM(facts, facts);
            command.issueCommands(eventList);
        } catch(Exception e) {
            errorThrown = true;
        }

        // An exception should have been thrown.
        assert(errorThrown == true);

        // Ensure an event was NOT created
        assert(eventList.size() == 0);   
    }


    testHappyPath(facts);
    testUserAlreadyExists(facts);
}
