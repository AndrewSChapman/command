module commands.passwordresetinitiate;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;
import decisionmakers.passwordresetinitiate;

class PasswordResetInitiateCommand : AbstractEvent!PasswordResetInitiateDMMeta,StorableEvent
{
    this(PasswordResetInitiateDMMeta meta)
    {
        super(meta);
    }

    public StorageEvent toStorageEvent() {
        auto lifecycle = this.getLifecycle();
        auto metadata = this.getMetadata();

        auto commandMeta = *metadata.peek!(PasswordResetInitiateDMMeta);
        return new StorageEvent(typeid(this), lifecycle, commandMeta.serializeToJson());       
    }
}