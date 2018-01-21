module commands.extendtoken;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;
import decisionmakers.extendtoken;

struct ExtendTokenCommandMeta
{
    string tokenCode;
    string userAgent;
    string ipAddress;
    string prefix;
    ulong usrId;
}

class ExtendTokenCommand : AbstractEvent!ExtendTokenCommandMeta,StorableEvent
{
    this(ExtendTokenCommandMeta meta) @safe
    {
        super(meta);
    }

    public StorageEvent toStorageEvent() @trusted
    {
        auto lifecycle = this.getLifecycle();
        auto metadata = this.getMetadata();

        auto storageMeta = *metadata.peek!(ExtendTokenCommandMeta);
        return new StorageEvent(typeid(this), lifecycle, storageMeta.serializeToJson());       
    }
}