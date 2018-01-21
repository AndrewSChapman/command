module decisionmakers.changeemail;

import std.exception;
import std.stdio;
import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.changeemail;
import helpers.testhelper;

struct ChangeEmailRequestMeta
{
    string emailAddress;
}

struct ChangeEmailFactors
{
    bool userLoggedIn;
    bool emailAddressLooksValid; 
    bool emailAddressIsDifferentToCurrent;
    bool emailAddressIsUnique;
}

class ChangeEmailDM : DecisionMakerInterface
{
    private ChangeEmailMeta meta;
    private ChangeEmailFactors factors;
    
    public this(ref ChangeEmailMeta meta, ref ChangeEmailFactors factors)
    {
        enforce(factors.userLoggedIn, "Sorry, you must be logged in to perform this action.");
        enforce(factors.emailAddressLooksValid, "Sorry, the proposed email address seems to be invalid.");
        enforce(factors.emailAddressIsDifferentToCurrent, "The proposed email address is not different to the current one.");
        enforce(factors.emailAddressIsUnique, "Sorry, another user account is using this email address.  Please choose another.");
        enforce(meta.emailAddress != "", "Email address may not be blank.");
        enforce(meta.usrId > 0, "Please supply a valid user id");
                
        this.meta = meta;
        this.factors = factors;
    }

    public void execute(EventListInterface eventList)
    {        
        eventList.append(new ChangeEmailCommand(this.meta), typeid(ChangeEmailCommand));
    }
}

unittest {
    ChangeEmailMeta meta;
    meta.usrId = 1;
    meta.emailAddress = "andy@andychapman.net";

    // Test passing factors
    function (ref ChangeEmailMeta meta) {
        ChangeEmailFactors factors;
        factors.userLoggedIn = true;
        factors.emailAddressLooksValid = true;
        factors.emailAddressIsDifferentToCurrent = true;
        factors.emailAddressIsUnique = true;

        TestHelper.testGenericCommand!(
            ChangeEmailDM,
            ChangeEmailMeta,
            ChangeEmailFactors
        )(meta, factors, 1, false);
    }(meta);

    // Test failing factors
    function (ref ChangeEmailMeta meta) {
        ChangeEmailFactors factors;
        factors.userLoggedIn = false;
        factors.emailAddressLooksValid = true;
        factors.emailAddressIsDifferentToCurrent = true;
        factors.emailAddressIsUnique = true;

        TestHelper.testGenericCommand!(
            ChangeEmailDM,
            ChangeEmailMeta,
            ChangeEmailFactors
        )(meta, factors, 0, true);
    }(meta);  

    // Test failing factors
    function (ref ChangeEmailMeta meta) {
        ChangeEmailFactors factors;
        factors.userLoggedIn = true;
        factors.emailAddressLooksValid = false;
        factors.emailAddressIsDifferentToCurrent = true;
        factors.emailAddressIsUnique = true;

        TestHelper.testGenericCommand!(
            ChangeEmailDM,
            ChangeEmailMeta,
            ChangeEmailFactors
        )(meta, factors, 0, true);
    }(meta);

    // Test failing factors
    function (ref ChangeEmailMeta meta) {
        ChangeEmailFactors factors;
        factors.userLoggedIn = true;
        factors.emailAddressLooksValid = true;
        factors.emailAddressIsDifferentToCurrent = false;
        factors.emailAddressIsUnique = true;

        TestHelper.testGenericCommand!(
            ChangeEmailDM,
            ChangeEmailMeta,
            ChangeEmailFactors
        )(meta, factors, 0, true);
    }(meta);

    // Test failing factors
    function (ref ChangeEmailMeta meta) {
        ChangeEmailFactors factors;
        factors.userLoggedIn = true;
        factors.emailAddressLooksValid = true;
        factors.emailAddressIsDifferentToCurrent = true;
        factors.emailAddressIsUnique = false;

        TestHelper.testGenericCommand!(
            ChangeEmailDM,
            ChangeEmailMeta,
            ChangeEmailFactors
        )(meta, factors, 0, true);
    }(meta);        
}	