module commands.createprefix;

import commandlib.abstractcommand;

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
}