module commands.registeruser;

import vibe.vibe;
import eventmanager.all;
import eventstore.all;
import decisionmakers.registeruser;

struct RegisterNewUserCommandMetadata
{
    string userFirstName;
    string userLastName;
    string email;
    string password;    
}

class RegisterUserCommand : AbstractEvent!RegisterNewUserCommandMetadata,StorableEvent
{
    this(
        ref string userFirstName,
        ref string userLastName,
        ref string email,
        ref string password
    ) @safe {
        RegisterNewUserCommandMetadata meta;
        meta.userFirstName = userFirstName;
        meta.userLastName = userLastName;
        meta.email = email;
        meta.password = password;

        super(meta);
    }

    public StorageEvent toStorageEvent() @trusted
    {
        auto lifecycle = this.getLifecycle();
        auto metadata = this.getMetadata();

        auto commandMetadata = *metadata.peek!(RegisterNewUserCommandMetadata);
        return new StorageEvent(typeid(this), lifecycle, commandMetadata.serializeToJson());       
    }
}