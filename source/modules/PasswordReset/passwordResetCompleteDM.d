module decisionmakers.passwordresetcomplete;

import std.exception;
import std.stdio;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.passwordresetcomplete;
import helpers.testhelper;

struct PasswordResetCompleteFacts
{
    bool userExists;
    bool newPasswordPinValidated;
    bool pinHasNotExpired;
    ulong usrId;
}

class PasswordResetCompleteDM : DecisionMakerInterface
{
    private PasswordResetCompleteFacts facts;
    
    public this(ref PasswordResetCompleteFacts facts) @safe
    {
        enforce(facts.usrId > 0, "Sorry, we could not find your user account.");
        enforce(facts.userExists, "Sorry, a user account with the specified email address does not exist.");
        enforce(facts.pinHasNotExpired, "Sorry, the password reset pin that you provided has expired.");
        enforce(facts.newPasswordPinValidated, "Sorry, the password reset pin that you provided was invalid.");

        this.facts = facts;
    }

    public void issueCommands(EventListInterface eventList) @safe
    {
        auto command = new PasswordResetCompleteCommand(this.facts.usrId);
        eventList.append(command, typeid(PasswordResetCompleteCommand));
    }
}

unittest {
    PasswordResetCompleteDMMeta meta;
    meta.usrId = 1;

    // Test passing facts
    function (ref PasswordResetCompleteDMMeta meta) {
        PasswordResetCompletefacts facts;
        facts.userExists = true;
        facts.newPasswordPinValidated = true;
        facts.pinHasNotExpired = true; 

        TestHelper.testGenericCommand!(PasswordResetCompleteDM, PasswordResetCompleteDMMeta, PasswordResetCompletefacts)(meta, facts, 1, false);
    }(meta);    

    // Test failing facts
    function (ref PasswordResetCompleteDMMeta meta) {
        PasswordResetCompletefacts facts;
        facts.userExists = false;
        facts.newPasswordPinValidated = true;
        facts.pinHasNotExpired = true; 

        TestHelper.testGenericCommand!(PasswordResetCompleteDM, PasswordResetCompleteDMMeta, PasswordResetCompletefacts)(meta, facts, 0, true);
    }(meta);

    function (ref PasswordResetCompleteDMMeta meta) {
        PasswordResetCompletefacts facts;
        facts.userExists = true;
        facts.newPasswordPinValidated = false;
        facts.pinHasNotExpired = true; 

        TestHelper.testGenericCommand!(PasswordResetCompleteDM, PasswordResetCompleteDMMeta, PasswordResetCompletefacts)(meta, facts, 0, true);
    }(meta);

    function (ref PasswordResetCompleteDMMeta meta) {
        PasswordResetCompletefacts facts;
        facts.userExists = true;
        facts.newPasswordPinValidated = true;
        facts.pinHasNotExpired = false; 

        TestHelper.testGenericCommand!(PasswordResetCompleteDM, PasswordResetCompleteDMMeta, PasswordResetCompletefacts)(meta, facts, 0, true);
    }(meta);        
}