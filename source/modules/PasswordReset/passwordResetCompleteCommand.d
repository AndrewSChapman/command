module commands.passwordresetcomplete;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;
import decisionmakers.passwordresetcomplete;

class PasswordResetCompleteCommand : AbstractEvent!PasswordResetCompleteDMMeta,StorableEvent
{
    this(PasswordResetCompleteDMMeta meta)
    {
        super(meta);
    }

    public StorageEvent toStorageEvent() {
        auto lifecycle = this.getLifecycle();
        auto metadata = this.getMetadata();

        auto commandMeta = *metadata.peek!(PasswordResetCompleteDMMeta);
        return new StorageEvent(typeid(this), lifecycle, commandMeta.serializeToJson());       
    }
}