module decisionmakers.registeruser;

import std.exception;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.registeruser;

struct RegisterUserDMMeta
{
    string userFirstName;
    string userLastName;
    string email;
    string password;
}

struct RegisterNewUserFactors
{
    bool userExists;
}

class RegisterUserDM : DecisionMakerInterface
{
    private RegisterUserDMMeta meta;
    
    public this(RegisterUserDMMeta meta, ref RegisterNewUserFactors factors) @safe
    {
        enforce(meta.userFirstName != "", "Please supply a user first name");
        enforce(meta.userLastName != "", "Please supply a user last name");
        enforce(meta.email != "", "Please supply a user email address");
        enforce(meta.password.length >= 8, "Please supply a password that is at least 8 characters long");
        enforce(!factors.userExists, "A user already exists with this email address.");

        this.meta = meta;
    }

    public void execute(EventListInterface eventList) @safe
    {
        eventList.append(new RegisterUserCommand(this.meta), typeid(RegisterUserCommand));
    }
}

unittest {
    RegisterUserDMMeta meta;
    meta.userFirstName = "Joe";
    meta.userLastName = "Bloggs";
    meta.email = "job.blogs@chapmandigital.co.uk";
    meta.password = "FishF1shFish";

    void testHappyPath(ref RegisterUserDMMeta meta) {
        // Test the happy path
        RegisterNewUserFactors factors;
        factors.userExists = false;

        auto command = new RegisterUserDM(meta, factors);
        auto eventList = new EventList();
        command.execute(eventList);

        // Ensure an event was created by the command
        assert(eventList.size() == 1);
    }

    void testUserAlreadyExists(ref RegisterUserDMMeta meta) {
        // Test the happy path
        RegisterNewUserFactors factors;
        factors.userExists = true;

        auto eventList = new EventList();
        bool errorThrown = false;

        try {
            auto command = new RegisterUserDM(meta, factors);
            command.execute(eventList);
        } catch(Exception e) {
            errorThrown = true;
        }

        // An exception should have been thrown.
        assert(errorThrown == true);

        // Ensure an event was NOT created
        assert(eventList.size() == 0);   
    }


    testHappyPath(meta);
    testUserAlreadyExists(meta);
}
