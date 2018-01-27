module decisionmakers.passwordresetinitiate;

import std.exception;
import std.stdio;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.passwordresetinitiate;
import helpers.testhelper;

struct PasswordResetInitiateFactors
{
    bool userExists;
    bool newPasswordValidated;
}

struct PasswordResetRequestMeta
{
    string emailAddress;
    string newPassword;
    string newPasswordRepeated;
}

struct PasswordResetInitiateDMMeta
{
    ulong usrId;
    string userFirstName;
    string userLastName;
    string userEmail;
    string newPassword;
}

class PasswordResetInitiateDM : DecisionMakerInterface
{
    private PasswordResetInitiateDMMeta meta;
    private PasswordResetInitiateFactors factors;
    
    public this(ref PasswordResetInitiateDMMeta meta, ref PasswordResetInitiateFactors factors) @safe
    {
        enforce(meta.usrId > 0, "Sorry, we could not find your user account.");
        enforce(meta.newPassword != "", "Please supply a valid new password.");
        enforce(meta.userFirstName != "", "Please provide the user first name.");
        enforce(meta.userLastName != "", "Please provide the user last name.");
        enforce(meta.userEmail != "", "Please provide the user email address.");
        enforce(factors.userExists, "Sorry, a user account with the specified email address does not exist.");
        enforce(factors.newPasswordValidated,
            "Sorry, either the password and repeatedPassword do not match, or the supplied new " ~
            "password does not meet the minimum security requirements.");

        this.meta = meta;
        this.factors = factors;
    }

    public void issueCommands(EventListInterface eventList) @safe
    {
        eventList.append(new PasswordResetInitiateCommand(this.meta), typeid(PasswordResetInitiateCommand));
    }
}

unittest {
    PasswordResetInitiateDMMeta meta;
    meta.usrId = 1;
    meta.newPassword = "ABC1234";
    meta.userFirstName = "Homer";
    meta.userLastName = "Simpson";
    meta.userEmail = "homer@chapmandigital.co.uk";

    // Test passing factors
    function (ref PasswordResetInitiateDMMeta meta) {
        PasswordResetInitiateFactors factors;
        factors.userExists = true;
        factors.newPasswordValidated = true;

        TestHelper.testGenericCommand!(PasswordResetInitiateDM, PasswordResetInitiateDMMeta, PasswordResetInitiateFactors)(meta, factors, 1, false);
    }(meta);


    // Test failing factors
    function (ref PasswordResetInitiateDMMeta meta) {
        PasswordResetInitiateFactors factors;
        factors.userExists = false;
        factors.newPasswordValidated = false;

        TestHelper.testGenericCommand!(PasswordResetInitiateDM, PasswordResetInitiateDMMeta, PasswordResetInitiateFactors)(meta, factors, 0, true);
    }(meta);

    function (ref PasswordResetInitiateDMMeta meta) {
        PasswordResetInitiateFactors factors;
        factors.userExists = true;
        factors.newPasswordValidated = false;

        TestHelper.testGenericCommand!(PasswordResetInitiateDM, PasswordResetInitiateDMMeta, PasswordResetInitiateFactors)(meta, factors, 0, true);
    }(meta);      
}