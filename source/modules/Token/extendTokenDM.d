module decisionmakers.extendtoken;

import std.exception;
import std.stdio;

import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import entity.token;
import commands.extendtoken;
import helpers.testhelper;

struct ExtendTokenFactors
{
    bool tokenExists;
    ulong tokenExpiry;
    string tokenUserAgent;
    string tokenIPAddress;
}

class ExtendTokenDM : DecisionMakerInterface
{
    private ExtendTokenCommandMeta meta;
    private ExtendTokenFactors factors;
    
    public this(ref ExtendTokenCommandMeta meta, ref ExtendTokenFactors factors)
    {
        enforce(factors.tokenExists, "Sorry, your login token is invalid.");
        enforce(factors.tokenExpiry > Clock.currTime().toUnixTime(), "Sorry, your login token has expired.");
        enforce(meta.tokenCode != "", "Please supply a valid tokenCode.");
        enforce(meta.userAgent != "", "Please supply a valid userAgent.");
        enforce(meta.ipAddress != "", "Please supply a valid ipAddress.");
        enforce(meta.userAgent == factors.tokenUserAgent, "Sorry, your login token has an invalid user agent.");
        enforce(meta.ipAddress == factors.tokenIPAddress, "Sorry, your login token has an invalid IP address.");
        enforce(meta.prefix != "", "Prefix may not be blank.");
        enforce(meta.usrId > 0, "UsrId must be > 0");

        this.meta = meta;
        this.factors = factors;
    }

    public void execute(EventListInterface eventList)
    {        
        eventList.append(new ExtendTokenCommand(this.meta), typeid(ExtendTokenCommand));
    }
}

unittest {
    ExtendTokenCommandMeta meta;
    meta.tokenCode = "12345";
    meta.userAgent = "ChapZilla";
    meta.ipAddress = "192.168.1.0";
    meta.prefix = "12345";
    meta.usrId = 1;

    // Test passing factors
    function (ref ExtendTokenCommandMeta meta) {
        ExtendTokenFactors factors;
        factors.tokenExists = true;
        factors.tokenExpiry = Clock.currTime().toUnixTime() + 86400;
        factors.tokenUserAgent = "ChapZilla";
        factors.tokenIPAddress = "192.168.1.0";

        TestHelper.testGenericCommand!(
            ExtendTokenDM,
            ExtendTokenCommandMeta,
            ExtendTokenFactors
        )(meta, factors, 1, false);
    }(meta);

    // Test failing factors
    function (ref ExtendTokenCommandMeta meta) {
        ExtendTokenFactors factors;
        factors.tokenExists = false;
        factors.tokenExpiry = Clock.currTime().toUnixTime() + 86400;
        factors.tokenUserAgent = "ChapZilla";
        factors.tokenIPAddress = "192.168.1.0";

        TestHelper.testGenericCommand!(
            ExtendTokenDM,
            ExtendTokenCommandMeta,
            ExtendTokenFactors
        )(meta, factors, 0, true);
    }(meta);

    function (ref ExtendTokenCommandMeta meta) {
        ExtendTokenFactors factors;
        factors.tokenExists = true;
        factors.tokenExpiry = Clock.currTime().toUnixTime() - 86400;
        factors.tokenUserAgent = "ChapZilla";
        factors.tokenIPAddress = "192.168.1.0";

        TestHelper.testGenericCommand!(
            ExtendTokenDM,
            ExtendTokenCommandMeta,
            ExtendTokenFactors
        )(meta, factors, 0, true);
    }(meta);

    function (ref ExtendTokenCommandMeta meta) {
        ExtendTokenFactors factors;
        factors.tokenExists = true;
        factors.tokenExpiry = Clock.currTime().toUnixTime() + 86400;
        factors.tokenUserAgent = "Wrong";
        factors.tokenIPAddress = "192.168.1.0";

        TestHelper.testGenericCommand!(
            ExtendTokenDM,
            ExtendTokenCommandMeta,
            ExtendTokenFactors
        )(meta, factors, 0, true);
    }(meta);

    function (ref ExtendTokenCommandMeta meta) {
        ExtendTokenFactors factors;
        factors.tokenExists = true;
        factors.tokenExpiry = Clock.currTime().toUnixTime() + 86400;
        factors.tokenUserAgent = "ChapZilla";
        factors.tokenIPAddress = "192.168.0.0";

        TestHelper.testGenericCommand!(
            ExtendTokenDM,
            ExtendTokenCommandMeta,
            ExtendTokenFactors
        )(meta, factors, 0, true);
    }(meta);    
}