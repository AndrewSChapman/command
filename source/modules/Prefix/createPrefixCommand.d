module commands.createprefix;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;
import decisionmakers.createprefix;

struct CreatePrefixCommandMetadata
{
    string userAgent;
    string ipAddress;
    ulong timestamp;
}

class CreatePrefixCommand : AbstractEvent!CreatePrefixCommandMetadata,StorableEvent
{
    this(in ref string userAgent, in ref string ipAddress, in ref ulong timestamp) @safe
    {
        CreatePrefixCommandMetadata data;
        data.userAgent = userAgent;
        data.ipAddress = ipAddress;
        data.timestamp = timestamp;        
        
        super(data);
    }

    public StorageEvent toStorageEvent() @trusted
    {
        auto metadata = *this.getMetadata().peek!(CreatePrefixCommandMetadata);
        return new StorageEvent(typeid(this), this.getLifecycle(), metadata.serializeToJson());       
    }
}