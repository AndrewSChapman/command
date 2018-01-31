module commands.createprefix;

import command.all;

struct CreatePrefixCommandMetadata
{
    string userAgent;
    string ipAddress;
    ulong timestamp;
}

class CreatePrefixCommand : AbstractCommand!CreatePrefixCommandMetadata
{
    this(in ref string userAgent, in ref string ipAddress, in ref ulong timestamp) @safe
    {
        CreatePrefixCommandMetadata data;
        data.userAgent = userAgent;
        data.ipAddress = ipAddress;
        data.timestamp = timestamp;        
        
        super(data);
    }

    public static register(CommandListenerInterface listener)
    {
        listener.registerCommand(typeid(CreatePrefixCommand));
    }
}