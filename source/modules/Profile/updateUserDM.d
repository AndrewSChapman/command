module decisionmakers.updateuser;

import std.exception;
import std.stdio;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.updateuser;
import helpers.testhelper;

struct UpdateUserRequestMeta
{
    string firstName;
    string lastName;
}

struct UpdateUserFactors
{
    bool userLoggedIn;
}

class UpdateUserDM : DecisionMakerInterface
{
    private UpdateUserMeta meta;
    private UpdateUserFactors factors;
    
    public this(ref UpdateUserMeta meta, ref UpdateUserFactors factors) @safe
    {
        enforce(factors.userLoggedIn, "Sorry, you must be logged in to perform this action.");
        enforce(meta.usrId > 0, "Please supply a valid user Id.");
        enforce(meta.firstName != "", "First name may not be blank.");
        enforce(meta.lastName != "", "Last name may not be lbank.");
                
        this.meta = meta;
        this.factors = factors;
    }

    public void execute(EventListInterface eventList) @safe
    {        
        eventList.append(new UpdateUserCommand(this.meta), typeid(UpdateUserCommand));
    }
}

unittest {
    UpdateUserMeta meta;
    meta.usrId = 1;
    meta.firstName = "Harry";
    meta.lastName = "Potter";

    // Test passing factors
    function (ref UpdateUserMeta meta) {
        UpdateUserFactors factors;
        factors.userLoggedIn = true;

        TestHelper.testGenericCommand!(
            UpdateUserDM,
            UpdateUserMeta,
            UpdateUserFactors
        )(meta, factors, 1, false);
    }(meta);

    // Test failing factors
    function (ref UpdateUserMeta meta) {
        UpdateUserFactors factors;
        factors.userLoggedIn = false;

        TestHelper.testGenericCommand!(
            UpdateUserDM,
            UpdateUserMeta,
            UpdateUserFactors
        )(meta, factors, 0, true);
    }(meta);     
}