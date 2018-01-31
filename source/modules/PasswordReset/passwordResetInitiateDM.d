module decisionmakers.passwordresetinitiate;

import std.exception;
import std.stdio;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
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

class PasswordResetInitiateDM : DecisionMakerInterface
{
    private PasswordResetInitiateFacts facts;
    
    public this(ref PasswordResetInitiateFacts facts) @safe
    {
        enforce(facts.usrId > 0, "Sorry, we could not find your user account.");
        enforce(facts.newPassword != "", "Please supply a valid new password.");
        enforce(facts.userFirstName != "", "Please provide the user first name.");
        enforce(facts.userLastName != "", "Please provide the user last name.");
        enforce(facts.userEmail != "", "Please provide the user email address.");
        enforce(facts.userExists, "Sorry, a user account with the specified email address does not exist.");
        enforce(facts.newPasswordValidated,
            "Sorry, either the password and repeatedPassword do not match, or the supplied new " ~
            "password does not meet the minimum security requirements.");

        this.facts = facts;
    }

    public void issueCommands(CommandBusInterface commandList) @safe
    {
        auto command = new PasswordResetInitiateCommand(
            facts.usrId,
            facts.userFirstName,
            facts.userLastName,
            facts.userEmail,
            facts.newPassword
        );

        commandList.append(command, typeid(PasswordResetInitiateCommand));
    }
}


unittest {
    PasswordResetInitiateFacts facts;
    facts.usrId = 1;
    facts.newPassword = "ABC1234";
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
