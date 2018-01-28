module commandlib.abstractcommand;

import eventmanager.all;
import eventstore.all;
import vibe.vibe;

class AbstractCommand(T) : AbstractEvent!T,StorableEvent
{
    this(T meta) @safe
    {
        super(meta);
    }

    protected T getMetadataStruct() @trusted
    {
        return *super.getMetadata().peek!(T);
    }

    public StorageEvent toStorageEvent() @trusted
    {
        ulong usrId = 0;
        auto metadata = this.getMetadataStruct();

        static if(__traits(hasMember, T, "usrId")) {
            usrId = metadata.usrId;
        }

        return new StorageEvent(typeid(this), this.getLifecycle(), metadata.serializeToJson(), usrId);
    }
}