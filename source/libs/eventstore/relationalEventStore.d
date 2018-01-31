module eventstore.relationaleventstore;
import std.datetime;
import vibe.vibe;

import vibe.vibe;
import eventstore.eventstoreinterface;
import eventstore.storageevent;
import eventstore.pager;
import relationaldb.all;

class RelationalEventStore : EventStoreInterface
{
    protected RelationalDBInterface relationalDb;

    this(RelationalDBInterface relationalDb) @safe {
        this.relationalDb = relationalDb;
    }

    public void persist(StorageEvent storageEvent) @trusted
    {
        string sql = "
                INSERT INTO commandLog (id, commandType, createdDtm, usrId, processingTime, lifecycle, metadata)
                VALUES (?, ?, FROM_UNIXTIME(?), ?, ?, ?, ?);
            ";

        auto metadata = storageEvent.metadataJson;
        this.removeSensitiveInformation(storageEvent.commandType, metadata);
        
        this.relationalDb.execute(sql, variantArray(
            storageEvent._id.toString(),
            storageEvent.commandType,
            stdTimeToUnixTime(storageEvent.eventCreated),
            storageEvent.usrId,
            storageEvent.lifecycle.eventProcessingTime,
            storageEvent.lifecycle.serializeToJsonString(),
            metadata.toString()
        ));        
    }

    private void removeSensitiveInformation(in string commandType, ref Json metadata) @safe
    {
        switch (commandType) {
            case "commands.registeruser.RegisterUserCommand":
                metadata["password"] = "******";
                break;

            case "commands.passwordresetinitiate.PasswordResetInitiateCommand":
                metadata["newPassword"] = "******";
                break;                

            default:
                break;
        }
    }
}