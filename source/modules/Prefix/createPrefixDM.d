module decisionmakers.createprefix;

import std.exception;
import std.stdio;

import validators.all;
import command.all;
import command.decisionmakerinterface;
import commands.createprefix;
import helpers.testhelper;

struct CreatePrefixFacts
{
    string userAgent;
    string ipAddress;
    ulong timestamp;
}

class CreatePrefixDM : AbstractDecisionMaker,DecisionMakerInterface
{    
    private CreatePrefixFacts facts;
    
    public this(ref CreatePrefixFacts facts) @safe
    {
        enforce(facts.userAgent != "", "Please supply a valid user agent");
        enforce(facts.timestamp > 0, "Please supply a valid timestamp");

        (new Varchar255Required(facts.ipAddress, "ipAddress"));

        this.facts = facts;
    }

    public void issueCommands(CommandBusInterface commandList) @safe
    {        
        auto command = new CreatePrefixCommand(
            this.facts.userAgent,
            this.facts.ipAddress,
            this.facts.timestamp
        );

        commandList.append(command, typeid(CreatePrefixCommand));
    }

    public string getPrefixCode() @safe
    {
        return this.router.getEventMessage!string("prefixCode");
    }    
}

unittest {
    CreatePrefixFacts facts;

    // Test passing facts
    function (ref CreatePrefixFacts facts) {
        facts.userAgent = "testy/mctestface";
        facts.ipAddress = "127.0.0.1";
        facts.timestamp = 1517261473; 

        TestHelper.testDecisionMaker!(CreatePrefixDM, CreatePrefixFacts)(facts, 1, false);
    }(facts);    

    // Test failing facts
    function (ref CreatePrefixFacts facts) {
        facts.userAgent = "";
        facts.ipAddress = "127.0.0.1";
        facts.timestamp = 1517261473; 

        TestHelper.testDecisionMaker!(CreatePrefixDM, CreatePrefixFacts)(facts, 0, true);
    }(facts);

    function (ref CreatePrefixFacts facts) {
        facts.userAgent = "testy/mctestface";
        facts.ipAddress = "";
        facts.timestamp = 1517261473; 

        TestHelper.testDecisionMaker!(CreatePrefixDM, CreatePrefixFacts)(facts, 0, true);
    }(facts);

    function (ref CreatePrefixFacts facts) {
        facts.userAgent = "testy/mctestface";
        facts.ipAddress = "127.0.0.1";
        facts.timestamp = 0;

        TestHelper.testDecisionMaker!(CreatePrefixDM, CreatePrefixFacts)(facts, 0, true);
    }(facts);        
}