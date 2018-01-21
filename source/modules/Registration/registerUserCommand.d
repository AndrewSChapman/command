module commands.registeruser;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;
import decisionmakers.registeruser;

class RegisterUserCommand : AbstractEvent!RegisterUserDMMeta,StorableEvent
{
    this(RegisterUserDMMeta meta)
    {
        super(meta);
    }

    public StorageEvent toStorageEvent() {
        auto lifecycle = this.getLifecycle();
        auto metadata = this.getMetadata();

        auto RegisterUserDMMeta = *metadata.peek!(RegisterUserDMMeta);
        return new StorageEvent(typeid(this), lifecycle, RegisterUserDMMeta.serializeToJson());       
    }
}