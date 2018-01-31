module eventstore.storageevent;

import vibe.d;
import command.abstractcommand;

class StorageEvent
{
    public BsonObjectID _id;
    public string commandType;
    public long eventCreated;
    public ulong usrId;
    public CommandLifecycle lifecycle;
    public Json metadataJson;

    this(TypeInfo commandType, CommandLifecycle lifecycle, Json metadataJson, ulong usrId = 0) {
        this._id = BsonObjectID.generate();
        this.commandType = commandType.toString();
        this.eventCreated = lifecycle.eventCreated;
        this.usrId = usrId;
        this.lifecycle = lifecycle;
        this.metadataJson = metadataJson;
    }

    public BsonObjectID getId() {
        return this._id;
    }
}