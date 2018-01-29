module decisionmakers.changepassword;

import std.exception;
import std.stdio;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.changepassword;
import helpers.testhelper;


struct ChangePasswordFacts
{
    bool userLoggedIn;
    bool repeatedPasswordMatches;
    bool existingPasswordIsCorrect;
    bool newPasswordIsStrong;
    ulong usrId;
    string password;
}

class ChangePasswordDM : DecisionMakerInterface
{
    private ChangePasswordFacts facts;
    
    public this(ref ChangePasswordFacts facts) @safe
    {
        enforce(facts.userLoggedIn, "Sorry, you must be logged in to perform this action.");
        enforce(facts.repeatedPasswordMatches, "Sorry, your repeated password does not match the new password.");
        enforce(facts.existingPasswordIsCorrect, "Sorry, your current password doesn't match what you've entered as your existing password.");
        enforce(facts.newPasswordIsStrong, "Sorry, your new password does not match our security policy.  Please enter a stronger password.");
        enforce(facts.usrId > 0, "Please supply a valid user Id.");
        enforce(facts.password != "", "Password may not be blank.");
                
        this.facts = facts;
    }

    public void issueCommands(EventListInterface eventList) @safe
    {        
        auto command = new ChangePasswordCommand(
            this.facts.usrId,
            this.facts.password
        );

        eventList.append(command, typeid(ChangePasswordCommand));
    }
}

unittest {
    ChangePasswordMeta meta;
    meta.usrId = 1;
    meta.password = "MyNewCrazyPassword";

    // Test passing factors
    function (ref ChangePasswordMeta meta) {
        ChangePasswordFactors factors;
        factors.userLoggedIn = true;
        factors.repeatedPasswordMatches = true;
        factors.existingPasswordIsCorrect = true;
        factors.newPasswordIsStrong = true;

        TestHelper.testGenericCommand!(
            ChangePasswordDM,
            ChangePasswordMeta,
            ChangePasswordFactors
        )(meta, factors, 1, false);
    }(meta);

    // Test failing factors
    function (ref ChangePasswordMeta meta) {
        ChangePasswordFactors factors;
        factors.userLoggedIn = false;
        factors.repeatedPasswordMatches = true;
        factors.existingPasswordIsCorrect = true;
        factors.newPasswordIsStrong = true;

        TestHelper.testGenericCommand!(
            ChangePasswordDM,
            ChangePasswordMeta,
            ChangePasswordFactors
        )(meta, factors, 0, true);
    }(meta);  

    // Test failing factors
    function (ref ChangePasswordMeta meta) {
        ChangePasswordFactors factors;
        factors.userLoggedIn = true;
        factors.repeatedPasswordMatches = false;
        factors.existingPasswordIsCorrect = true;
        factors.newPasswordIsStrong = true;

        TestHelper.testGenericCommand!(
            ChangePasswordDM,
            ChangePasswordMeta,
            ChangePasswordFactors
        )(meta, factors, 0, true);
    }(meta);

    // Test failing factors
    function (ref ChangePasswordMeta meta) {
        ChangePasswordFactors factors;
        factors.userLoggedIn = true;
        factors.repeatedPasswordMatches = true;
        factors.existingPasswordIsCorrect = false;
        factors.newPasswordIsStrong = true;

        TestHelper.testGenericCommand!(
            ChangePasswordDM,
            ChangePasswordMeta,
            ChangePasswordFactors
        )(meta, factors, 0, true);
    }(meta);

    // Test failing factors
    function (ref ChangePasswordMeta meta) {
        ChangePasswordFactors factors;
        factors.userLoggedIn = true;
        factors.repeatedPasswordMatches = true;
        factors.existingPasswordIsCorrect = true;
        factors.newPasswordIsStrong = false;

        TestHelper.testGenericCommand!(
            ChangePasswordDM,
            ChangePasswordMeta,
            ChangePasswordFactors
        )(meta, factors, 0, true);
    }(meta);        
}