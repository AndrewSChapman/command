module commands.changepassword;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;

struct ChangePasswordMeta
{
    long usrId;
    string password;
}

class ChangePasswordCommand : AbstractEvent!ChangePasswordMeta,StorableEvent
{
    this(ChangePasswordMeta meta) @safe
    {
        super(meta);
    }

    public StorageEvent toStorageEvent() @trusted
    {
        auto lifecycle = this.getLifecycle();
        auto metadata = this.getMetadata();

        auto meta = *metadata.peek!(ChangePasswordMeta);
        return new StorageEvent(typeid(this), lifecycle, meta.serializeToJson());       
    }
}