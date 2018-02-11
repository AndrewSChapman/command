module decisionmakers.passwordresetcomplete;

import std.exception;
import std.stdio;
import vibe.vibe;

import command.decisionmakerinterface;
import command.all;
import commands.passwordresetcomplete;
import commands.incrementfailedpincount;
import facts.toomanyincorrectpinattempts;
import helpers.testhelper;

struct PasswordResetCompleteFacts
{
    bool userExists;
    bool newPasswordPinCorrect;
    bool pinHasNotExpired;
    ulong usrId;
    TooManyIncorrectPinAttempts tooManyIncorrectPinAttempts;
}

class PasswordResetCompleteDM : AbstractDecisionMaker,DecisionMakerInterface
{
    private PasswordResetCompleteFacts facts;
    
    public this(ref PasswordResetCompleteFacts facts) @safe
    {
        enforce(facts.usrId > 0, "Sorry, we could not find your user account.");
        enforce(facts.userExists, "Sorry, a user account with the specified email address does not exist.");
        enforce(facts.pinHasNotExpired, "Sorry, the password reset pin that you provided has expired.");
        enforce((!(facts.tooManyIncorrectPinAttempts is null)) && (!facts.tooManyIncorrectPinAttempts.isTrue()),
         "Sorry, you have entered an incorrect pin too many times and you need to restart the " ~
         "password reset proceedure.");

        this.facts = facts;
    }

    public void issueCommands(CommandBusInterface commandBus) @safe
    {
        //enforce(facts.newPasswordPinCorrect, "Sorry, the password reset pin that you provided was invalid.");
        if (facts.newPasswordPinCorrect) {
            auto command = new PasswordResetCompleteCommand(this.facts.usrId);
            commandBus.append(command, typeid(PasswordResetCompleteCommand));
        } else {
            auto command = new IncrementFailedPinCountCommand(this.facts.usrId);
            commandBus.append(command, typeid(IncrementFailedPinCountCommand));
        }
    }

    override protected void throwExceptionIfNecessary() @safe
    {
        if (!facts.newPasswordPinCorrect) {
            throw new Exception("Sorry, the password reset pin that you provided was invalid.");
        }
    }    
}


unittest {
    PasswordResetCompleteFacts facts;
    facts.usrId = 1;

    // Test passing facts
    function (ref PasswordResetCompleteFacts facts) {
        facts.userExists = true;
        facts.newPasswordPinCorrect = true;
        facts.pinHasNotExpired = true;
        facts.tooManyIncorrectPinAttempts = new TooManyIncorrectPinAttempts(0);

        TestHelper.testDecisionMaker!(PasswordResetCompleteDM, PasswordResetCompleteFacts)(facts, 1, false);
    }(facts);   

    function (ref PasswordResetCompleteFacts facts) {
        facts.userExists = true;
        facts.newPasswordPinCorrect = true;
        facts.pinHasNotExpired = true;
        facts.tooManyIncorrectPinAttempts = new TooManyIncorrectPinAttempts(3);

        TestHelper.testDecisionMaker!(PasswordResetCompleteDM, PasswordResetCompleteFacts)(facts, 1, false);
    }(facts);       

    // Test failing facts
    function (ref PasswordResetCompleteFacts facts) {
        facts.userExists = false;
        facts.newPasswordPinCorrect = true;
        facts.pinHasNotExpired = true; 
        facts.tooManyIncorrectPinAttempts = new TooManyIncorrectPinAttempts(0);

        TestHelper.testDecisionMaker!(PasswordResetCompleteDM, PasswordResetCompleteFacts)(facts, 0, true);
    }(facts);

    function (ref PasswordResetCompleteFacts facts) {
        facts.userExists = true;
        facts.newPasswordPinCorrect = true;
        facts.pinHasNotExpired = false;
        facts.tooManyIncorrectPinAttempts = new TooManyIncorrectPinAttempts(0);

        TestHelper.testDecisionMaker!(PasswordResetCompleteDM, PasswordResetCompleteFacts)(facts, 0, true);
    }(facts);   

    function (ref PasswordResetCompleteFacts facts) {
        facts.userExists = true;
        facts.newPasswordPinCorrect = true;
        facts.pinHasNotExpired = true;
        facts.tooManyIncorrectPinAttempts = new TooManyIncorrectPinAttempts(6);

        TestHelper.testDecisionMaker!(PasswordResetCompleteDM, PasswordResetCompleteFacts)(facts, 0, true);
    }(facts);       
}