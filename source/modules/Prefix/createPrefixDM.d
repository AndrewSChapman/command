module decisionmakers.createprefix;

import std.exception;
import std.stdio;

import eventmanager.all;
import decisionmakers.decisionmakerinterface;
import commands.createprefix;

struct CreatePrefixDMMeta
{
    string userAgent;
    string ipAddress;
    ulong timestamp;
}

class CreatePrefixDM : DecisionMakerInterface
{    
    private CreatePrefixDMMeta meta;
    
    public this(ref CreatePrefixDMMeta meta) @safe
    {
        enforce(meta.userAgent != "", "Please supply a valid user agent");
        enforce(meta.ipAddress != "", "Please supply a valid ip address");
        enforce(meta.timestamp > 0, "Please supply a valid timestamp");

        this.meta = meta;
    }

    public void execute(EventListInterface eventList) @safe
    {        
        eventList.append(new CreatePrefixCommand(this.meta), typeid(CreatePrefixCommand));
    }
}