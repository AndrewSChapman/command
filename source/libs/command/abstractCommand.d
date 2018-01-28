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
        auto metadata = this.getMetadataStruct();
        return new StorageEvent(typeid(this), this.getLifecycle(), metadata.serializeToJson());
    }
}