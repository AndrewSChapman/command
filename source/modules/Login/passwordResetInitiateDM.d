module decisionmakers.passwordresetinitiate;

import std.exception;
import std.stdio;
import vibe.vibe;

import dcorelib;
import validators.all;
import command.decisionmakerinterface;
import command.all;
import commands.passwordresetinitiate;
import helpers.testhelper;

struct PasswordResetInitiateFacts
{
    bool userExists;
    bool newPasswordValidated;
    ulong usrId;
    string userFirstName;
    string userLastName;
    string userEmail;
    string newPassword;    
}

class PasswordResetInitiateDM : AbstractDecisionMaker,DecisionMakerInterface
{
    private PasswordResetInitiateFacts facts;
    
    public this(ref PasswordResetInitiateFacts facts) @safe
    {
        enforce(facts.usrId > 0, "Sorry, we could not find your user account.");
        enforce(facts.newPassword != "", "Please supply a valid new password.");
        enforce(facts.userExists, "Sorry, a user account with the specified email address does not exist.");
        enforce(facts.newPasswordValidated,
            "Sorry, either the password and repeatedPassword do not match, or the supplied new " ~
            "password does not meet the minimum security requirements.");

        (new Varchar255Required(facts.userFirstName, "userFirstName"));
        (new Varchar255Required(facts.userLastName, "userLastName"));
        (new EmailAddressRequired(facts.userEmail, "userEmail"));
        (new Password(facts.newPassword, "newPassword"));

        this.facts = facts;
    }

    public void issueCommands(CommandBusInterface commandBus) @safe
    {
        auto command = new PasswordResetInitiateCommand(
            facts.usrId,
            facts.userFirstName,
            facts.userLastName,
            facts.userEmail,
            facts.newPassword
        );

        commandBus.append(command, typeid(PasswordResetInitiateCommand));
    }
}


unittest {
    PasswordResetInitiateFacts facts;
    facts.usrId = 1;
    facts.newPassword = "PassW0rd*£2017";
    facts.userFirstName = "Homer";
    facts.userLastName = "Simpson";
    facts.userEmail = "homer@chapmandigital.co.uk";

    // Test passing facts
    function (ref PasswordResetInitiateFacts facts) {
        facts.userExists = true;
        facts.newPasswordValidated = true;

        TestHelper.testDecisionMaker!(PasswordResetInitiateDM, PasswordResetInitiateFacts)(facts, 1, false);
    }(facts);


    // Test failing facts
    function (ref PasswordResetInitiateFacts facts) {
        facts.userExists = false;
        facts.newPasswordValidated = false;

        TestHelper.testDecisionMaker!(PasswordResetInitiateDM, PasswordResetInitiateFacts)(facts, 0, true);
    }(facts);

    function (ref PasswordResetInitiateFacts facts) {
        facts.userExists = true;
        facts.newPasswordValidated = false;

        TestHelper.testDecisionMaker!(PasswordResetInitiateDM, PasswordResetInitiateFacts)(facts, 0, true);
    }(facts);      
}
