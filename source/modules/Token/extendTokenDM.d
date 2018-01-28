module decisionmakers.extendtoken;

import std.exception;
import std.stdio;

import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import entity.token;
import commands.extendtoken;
import helpers.testhelper;

struct ExtendTokenFacts
{
    bool tokenExists;
    ulong tokenExpiry;
    string tokenUserAgent;
    string tokenIPAddress;
    string tokenCode;
    string userAgent;
    string ipAddress;
    string prefix;
    ulong usrId;    
}

class ExtendTokenDM : DecisionMakerInterface
{
    private ExtendTokenFacts facts;
    
    public this(in ref ExtendTokenFacts facts) @safe
    {
        enforce(facts.tokenExists, "Sorry, your login token is invalid.");
        enforce(facts.tokenExpiry > Clock.currTime().toUnixTime(), "Sorry, your login token has expired.");
        enforce(facts.tokenCode != "", "Please supply a valid tokenCode.");
        enforce(facts.userAgent != "", "Please supply a valid userAgent.");
        enforce(facts.ipAddress != "", "Please supply a valid ipAddress.");
        enforce(facts.userAgent == facts.tokenUserAgent, "Sorry, your login token has an invalid user agent.");
        enforce(facts.ipAddress == facts.tokenIPAddress, "Sorry, your login token has an invalid IP address.");
        enforce(facts.prefix != "", "Prefix may not be blank.");
        enforce(facts.usrId > 0, "UsrId must be > 0");

        this.facts = facts;
    }

    public void issueCommands(EventListInterface eventList) @safe
    {        
        auto command = new ExtendTokenCommand(
            this.facts.tokenCode,
            this.facts.userAgent,
            this.facts.ipAddress,
            this.facts.prefix,
            this.facts.usrId
        );

        eventList.append(command, typeid(ExtendTokenCommand));
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