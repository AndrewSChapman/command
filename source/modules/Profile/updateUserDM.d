module decisionmakers.updateuser;

import std.exception;
import std.stdio;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
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

    public void issueCommands(EventListInterface eventList) @safe
    {        
        auto command = new UpdateUserCommand(
            this.facts.usrId,
            this.facts.firstName,
            this.facts.lastName
        );

        eventList.append(command, typeid(UpdateUserCommand));
    }
}

/*
unittest {
    UpdateUserMeta meta;
    meta.usrId = 1;
    meta.firstName = "Harry";
    meta.lastName = "Potter";

    // Test passing factors
    function (ref UpdateUserMeta meta) {
        UpdateUserFactors factors;
        factors.userLoggedIn = true;

        TestHelper.testDecisionMaker!(
            UpdateUserDM,
            UpdateUserMeta,
            UpdateUserFactors
        )(meta, factors, 1, false);
    }(meta);

    // Test failing factors
    function (ref UpdateUserMeta meta) {
        UpdateUserFactors factors;
        factors.userLoggedIn = false;

        TestHelper.testDecisionMaker!(
            UpdateUserDM,
            UpdateUserMeta,
            UpdateUserFactors
        )(meta, factors, 0, true);
    }(meta);     
}
*/