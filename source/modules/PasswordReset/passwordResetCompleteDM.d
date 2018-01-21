module decisionmakers.passwordresetcomplete;

import std.exception;
import std.stdio;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.passwordresetcomplete;
import helpers.testhelper;

struct PasswordResetCompleteFactors
{
    bool userExists;
    bool newPasswordPinValidated;
    bool pinHasNotExpired;
}

struct PasswordResetCompleteRequestMeta
{
    string emailAddress;
    ulong newPasswordPin;
}

struct PasswordResetCompleteDMMeta
{
    ulong usrId;
}

class PasswordResetCompleteDM : DecisionMakerInterface
{
    private PasswordResetCompleteDMMeta meta;
    private PasswordResetCompleteFactors factors;
    
    public this(ref PasswordResetCompleteDMMeta meta, ref PasswordResetCompleteFactors factors) @safe
    {
        enforce(meta.usrId > 0, "Sorry, we could not find your user account.");
        enforce(factors.userExists, "Sorry, a user account with the specified email address does not exist.");
        enforce(factors.pinHasNotExpired, "Sorry, the password reset pin that you provided has expired.");
        enforce(factors.newPasswordPinValidated, "Sorry, the password reset pin that you provided was invalid.");

        this.meta = meta;
        this.factors = factors;
    }

    public void execute(EventListInterface eventList) @safe
    {
        eventList.append(new PasswordResetCompleteCommand(this.meta), typeid(PasswordResetCompleteCommand));
    }
}

unittest {
    PasswordResetCompleteDMMeta meta;
    meta.usrId = 1;

    // Test passing factors
    function (ref PasswordResetCompleteDMMeta meta) {
        PasswordResetCompleteFactors factors;
        factors.userExists = true;
        factors.newPasswordPinValidated = true;
        factors.pinHasNotExpired = true; 

        TestHelper.testGenericCommand!(PasswordResetCompleteDM, PasswordResetCompleteDMMeta, PasswordResetCompleteFactors)(meta, factors, 1, false);
    }(meta);    

    // Test failing factors
    function (ref PasswordResetCompleteDMMeta meta) {
        PasswordResetCompleteFactors factors;
        factors.userExists = false;
        factors.newPasswordPinValidated = true;
        factors.pinHasNotExpired = true; 

        TestHelper.testGenericCommand!(PasswordResetCompleteDM, PasswordResetCompleteDMMeta, PasswordResetCompleteFactors)(meta, factors, 0, true);
    }(meta);

    function (ref PasswordResetCompleteDMMeta meta) {
        PasswordResetCompleteFactors factors;
        factors.userExists = true;
        factors.newPasswordPinValidated = false;
        factors.pinHasNotExpired = true; 

        TestHelper.testGenericCommand!(PasswordResetCompleteDM, PasswordResetCompleteDMMeta, PasswordResetCompleteFactors)(meta, factors, 0, true);
    }(meta);

    function (ref PasswordResetCompleteDMMeta meta) {
        PasswordResetCompleteFactors factors;
        factors.userExists = true;
        factors.newPasswordPinValidated = true;
        factors.pinHasNotExpired = false; 

        TestHelper.testGenericCommand!(PasswordResetCompleteDM, PasswordResetCompleteDMMeta, PasswordResetCompleteFactors)(meta, factors, 0, true);
    }(meta);        
}