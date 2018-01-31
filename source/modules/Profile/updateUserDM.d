module decisionmakers.updateuser;

import std.exception;
import std.stdio;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import command.all;
import commands.updateuser;
import helpers.testhelper;

struct UpdateUserFacts
{
    bool userLoggedIn;
    ulong usrId;
    string firstName;
    string lastName;    
}

class UpdateUserDM : DecisionMakerInterface
{
    private UpdateUserFacts facts;
    
    public this(ref UpdateUserFacts facts) @safe
    {
        enforce(facts.userLoggedIn, "Sorry, you must be logged in to perform this action.");
        enforce(facts.usrId > 0, "Please supply a valid user Id.");
        enforce(facts.firstName != "", "First name may not be blank.");
        enforce(facts.lastName != "", "Last name may not be lbank.");
                
        this.facts = facts;
    }

    public void issueCommands(CommandBusInterface eventList) @safe
    {        
        auto command = new UpdateUserCommand(
            this.facts.usrId,
            this.facts.firstName,
            this.facts.lastName
        );

        eventList.append(command, typeid(UpdateUserCommand));
    }
}

unittest {
    // Test passing facts
    UpdateUserFacts[] passingFactsArray;
    passingFactsArray ~= UpdateUserFacts(true, 1, "Harry", "Potter");

    foreach(facts; passingFactsArray) {
        TestHelper.testDecisionMaker!(UpdateUserDM,UpdateUserFacts)(facts, 1, false);
    }

    // Test failing facts
    UpdateUserFacts[] failingFactsArray;
    failingFactsArray ~= UpdateUserFacts(false, 1, "Harry", "Potter");
    failingFactsArray ~= UpdateUserFacts(true, 0, "Harry", "Potter");
    failingFactsArray ~= UpdateUserFacts(true, 1, "", "Potter");
    failingFactsArray ~= UpdateUserFacts(true, 1, "Harry", "");

    foreach(facts; failingFactsArray) {
        TestHelper.testDecisionMaker!(UpdateUserDM,UpdateUserFacts)(facts, 0, true);    
    }
}
