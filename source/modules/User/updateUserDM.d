module decisionmakers.updateuser;

import std.exception;
import std.stdio;
import vibe.vibe;

import validators.all;
import decisionmakers.decisionmakerinterface;
import command.all;
import commands.updateuser;
import helpers.testhelper;
import entity.user;

struct UpdateUserFacts
{
    bool userLoggedIn;
    ulong usrId;
    UserType usrType;
    string firstName;
    string lastName;    
}

class UpdateUserDM : DecisionMakerInterface
{
    private UpdateUserFacts facts;
    
    public this(ref UpdateUserFacts facts) @safe
    {
        enforce(facts.userLoggedIn, "Sorry, you must be logged in to perform this action.");

        (new Varchar255Required(facts.firstName, "firstName"));
        (new Varchar255Required(facts.lastName, "lastName"));
        (new PositiveNumber!ulong(facts.usrId, "usrId"));        
                
        this.facts = facts;
    }

    public void issueCommands(CommandBusInterface commandList) @safe
    {        
        auto command = new UpdateUserCommand(
            this.facts.usrId,
            this.facts.usrType,
            this.facts.firstName,
            this.facts.lastName
        );

        commandList.append(command, typeid(UpdateUserCommand));
    }
}

unittest {
    // Test passing facts
    UpdateUserFacts[] passingFactsArray;
    passingFactsArray ~= UpdateUserFacts(true, 1, UserType.ADMIN, "Harry", "Potter");

    foreach(facts; passingFactsArray) {
        TestHelper.testDecisionMaker!(UpdateUserDM,UpdateUserFacts)(facts, 1, false);
    }

    // Test failing facts
    UpdateUserFacts[] failingFactsArray;
    failingFactsArray ~= UpdateUserFacts(false, 1, UserType.ADMIN, "Harry", "Potter");
    failingFactsArray ~= UpdateUserFacts(true, 1, UserType.ADMIN, "", "Potter");
    failingFactsArray ~= UpdateUserFacts(true, 1, UserType.ADMIN, "Harry", "");

    foreach(facts; failingFactsArray) {
        TestHelper.testDecisionMaker!(UpdateUserDM,UpdateUserFacts)(facts, 0, true);    
    }
}
