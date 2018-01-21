module decisionmakers.changepassword;

import std.exception;
import std.stdio;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.changepassword;
import helpers.testhelper;

struct ChangePasswordRequestMeta
{
    string existingPassword;
    string newPassword;
    string newPasswordRepeated;
}

struct ChangePasswordFactors
{
    bool userLoggedIn;
    bool repeatedPasswordMatches;
    bool existingPasswordIsCorrect;
    bool newPasswordIsStrong;
}

class ChangePasswordDM : DecisionMakerInterface
{
    private ChangePasswordMeta meta;
    private ChangePasswordFactors factors;
    
    public this(ref ChangePasswordMeta meta, ref ChangePasswordFactors factors)
    {
        enforce(factors.userLoggedIn, "Sorry, you must be logged in to perform this action.");
        enforce(factors.repeatedPasswordMatches, "Sorry, your repeated password does not match the new password.");
        enforce(factors.existingPasswordIsCorrect, "Sorry, your current password doesn't match what you've entered as your existing password.");
        enforce(factors.newPasswordIsStrong, "Sorry, your new password does not match our security policy.  Please enter a stronger password.");
        enforce(meta.usrId > 0, "Please supply a valid user Id.");
        enforce(meta.password != "", "Password may not be blank.");
                
        this.meta = meta;
        this.factors = factors;
    }

    public void execute(EventListInterface eventList)
    {        
        eventList.append(new ChangePasswordCommand(this.meta), typeid(ChangePasswordCommand));
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