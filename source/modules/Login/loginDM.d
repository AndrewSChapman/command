module decisionmakers.login;

import std.exception;
import std.stdio;
import vibe.vibe;

import vibe.vibe;

import decisionmakers.decisionmakerinterface;
import eventmanager.all;
import commands.login;
import commands.assignprefix;
import helpers.testhelper;

struct LoginRequestMeta
{
    string email;
    string password;
    string prefix;
}

struct LoginDMMeta
{
    ulong usrId;
    string userAgent;
    string ipAddress;
    string prefix;
}

struct LoginFactors
{
    bool userExists;
    bool passwordCorrect;
    bool prefixExists;
    bool prefixAssignedToUser;
    bool prefixNotAssigned;
}

class LoginDM : DecisionMakerInterface
{
    private LoginDMMeta meta;
    private LoginFactors factors;
    
    public this(ref LoginDMMeta meta, ref LoginFactors factors) @safe
    {
        enforce(factors.userExists, "Sorry, a user account with the specified email address does not exist.");
        enforce(factors.passwordCorrect, "Sorry, the supplied password was incorrect.");            
        enforce(factors.prefixExists, "Sorry, the prefix code you supplied was invalid.");
        enforce(factors.prefixNotAssigned || factors.prefixAssignedToUser, "The supplied prefix is already assigned to a user or is not assigned to you.  Please generate a new prefix to complete this operation.");
        enforce(meta.usrId > 0, "Please supply a valid user Id.");
        enforce(meta.userAgent != "", "Please supply a user agent string.");
        enforce(meta.ipAddress != "", "Please supply an IP address.");
        enforce(meta.prefix != "", "Please supply a valid prefix code.");        

        this.meta = meta;
        this.factors = factors;
    }

    public void issueCommands(EventListInterface eventList) @safe
    {
        if (factors.prefixNotAssigned) {
            AssignPrefixMeta assignPrefixMeta;
            assignPrefixMeta.usrId = meta.usrId;
            assignPrefixMeta.prefix = meta.prefix;

            eventList.append(new AssignPrefixCommand(assignPrefixMeta), typeid(AssignPrefixCommand));
        }
        
        eventList.append(new LoginCommand(this.meta), typeid(LoginCommand));
    }
}

unittest {
    LoginDMMeta meta;
    meta.usrId = 1;
    meta.userAgent = "TESTAGENT";
    meta.ipAddress = "192.168.1.100";
    meta.prefix = "ABCDE";

    // Test passing factors
    function (ref LoginDMMeta meta) {
        LoginFactors factors;
        factors.userExists = true;
        factors.passwordCorrect = true;
        factors.prefixExists = true;
        factors.prefixAssignedToUser = true;
        factors.prefixNotAssigned = false;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, LoginFactors)(meta, factors, 1, false);
    }(meta);

    function (ref LoginDMMeta meta) {
        LoginFactors factors;
        factors.userExists = true;
        factors.passwordCorrect = true;
        factors.prefixExists = true;
        factors.prefixAssignedToUser = false;
        factors.prefixNotAssigned = true;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, LoginFactors)(meta, factors, 2, false);
    }(meta);

    // Test failing factors
    function (ref LoginDMMeta meta) {
        LoginFactors factors;
        factors.userExists = false;
        factors.passwordCorrect = true;
        factors.prefixExists = true;
        factors.prefixAssignedToUser = false;
        factors.prefixNotAssigned = true;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, LoginFactors)(meta, factors, 0, true);
    }(meta);

    function (ref LoginDMMeta meta) {
        LoginFactors factors;
        factors.userExists = true;
        factors.passwordCorrect = false;
        factors.prefixExists = true;
        factors.prefixAssignedToUser = false;
        factors.prefixNotAssigned = true;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, LoginFactors)(meta, factors, 0, true);
    }(meta);    

    function (ref LoginDMMeta meta) {
        LoginFactors factors;
        factors.userExists = true;
        factors.passwordCorrect = true;
        factors.prefixExists = false;
        factors.prefixAssignedToUser = false;
        factors.prefixNotAssigned = true;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, LoginFactors)(meta, factors, 0, true);
    }(meta);

    function (ref LoginDMMeta meta) {
        LoginFactors factors;
        factors.userExists = true;
        factors.passwordCorrect = true;
        factors.prefixExists = true;
        factors.prefixAssignedToUser = false;
        factors.prefixNotAssigned = false;

        TestHelper.testGenericCommand!(LoginDM, LoginDMMeta, LoginFactors)(meta, factors, 0, true);
    }(meta);        
}