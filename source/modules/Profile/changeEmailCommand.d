module commands.changeemail;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;

struct ChangeEmailMeta
{
    long usrId;
    string emailAddress;
}

class ChangeEmailCommand : AbstractEvent!ChangeEmailMeta,StorableEvent
{
    this(ChangeEmailMeta meta)
    {
        super(meta);
    }

    public StorageEvent toStorageEvent() {
        auto lifecycle = this.getLifecycle();
        auto metadata = this.getMetadata();

        auto meta = *metadata.peek!(ChangeEmailMeta);
        return new StorageEvent(typeid(this), lifecycle, meta.serializeToJson());       
    }
}