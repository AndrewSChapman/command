module decisionmakers.changeemail;

import std.exception;
import std.stdio;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.changeemail;
import helpers.testhelper;

struct ChangeEmailFacts
{
    bool userLoggedIn;
    bool emailAddressLooksValid; 
    bool emailAddressIsDifferentToCurrent;
    bool emailAddressIsUnique;
    ulong usrId;
    string emailAddress;    
}

class ChangeEmailDM : DecisionMakerInterface
{
    private ChangeEmailFacts facts;
    
    public this(in ref ChangeEmailFacts facts) @safe
    {
        enforce(facts.userLoggedIn, "Sorry, you must be logged in to perform this action.");
        enforce(facts.emailAddressLooksValid, "Sorry, the proposed email address seems to be invalid.");
        enforce(facts.emailAddressIsDifferentToCurrent, "The proposed email address is not different to the current one.");
        enforce(facts.emailAddressIsUnique, "Sorry, another user account is using this email address.  Please choose another.");
        enforce(facts.emailAddress != "", "Email address may not be blank.");
        enforce(facts.usrId > 0, "Please supply a valid user id");
                
        this.facts = facts;
    }

    public void issueCommands(EventListInterface eventList) @safe
    {        
        auto command = new ChangeEmailCommand(
            this.facts.usrId,
            this.facts.emailAddress
        );

        eventList.append(command, typeid(ChangeEmailCommand));
    }
}


unittest {
    ChangeEmailFacts facts;
    facts.usrId = 1;
    facts.emailAddress = "andy@andychapman.net";

    // Test passing facts
    function (ref ChangeEmailFacts facts) {
        facts.userLoggedIn = true;
        facts.emailAddressLooksValid = true;
        facts.emailAddressIsDifferentToCurrent = true;
        facts.emailAddressIsUnique = true;

        TestHelper.testDecisionMaker!(
            ChangeEmailDM,
            ChangeEmailFacts
        )(facts, 1, false);
    }(facts);

    // Test failing facts
    function (ref ChangeEmailFacts facts) {
        facts.userLoggedIn = false;
        facts.emailAddressLooksValid = true;
        facts.emailAddressIsDifferentToCurrent = true;
        facts.emailAddressIsUnique = true;

        TestHelper.testDecisionMaker!(
            ChangeEmailDM,
            ChangeEmailFacts
        )(facts, 0, true);
    }(facts);  

    function (ref ChangeEmailFacts facts) {
        facts.userLoggedIn = true;
        facts.emailAddressLooksValid = false;
        facts.emailAddressIsDifferentToCurrent = true;
        facts.emailAddressIsUnique = true;

        TestHelper.testDecisionMaker!(
            ChangeEmailDM,
            ChangeEmailFacts
        )(facts, 0, true);
    }(facts);

    function (ref ChangeEmailFacts facts) {
        facts.userLoggedIn = true;
        facts.emailAddressLooksValid = true;
        facts.emailAddressIsDifferentToCurrent = false;
        facts.emailAddressIsUnique = true;

        TestHelper.testDecisionMaker!(
            ChangeEmailDM,
            ChangeEmailFacts
        )(facts, 0, true);
    }(facts);

    function (ref ChangeEmailFacts facts) {
        facts.userLoggedIn = true;
        facts.emailAddressLooksValid = true;
        facts.emailAddressIsDifferentToCurrent = true;
        facts.emailAddressIsUnique = false;

        TestHelper.testDecisionMaker!(
            ChangeEmailDM,
            ChangeEmailFacts
        )(facts, 0, true);
    }(facts);        
}
