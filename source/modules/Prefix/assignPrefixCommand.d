module commands.assignprefix;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;
import decisionmakers.login;

struct AssignPrefixMeta
{
    string prefix;
    ulong usrId;
}

class AssignPrefixCommand : AbstractEvent!AssignPrefixMeta,StorableEvent
{
    this(AssignPrefixMeta meta) @safe
    {
        super(meta);
    }

    public StorageEvent toStorageEvent() @trusted
    {
        auto lifecycle = this.getLifecycle();
        auto metadata = this.getMetadata();

        auto storageMeta = *metadata.peek!(AssignPrefixMeta);
        return new StorageEvent(typeid(this), lifecycle, storageMeta.serializeToJson());       
    }
}