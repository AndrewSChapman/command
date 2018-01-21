module eventstore.storageevent;

import vibe.d;
import eventmanager.abstractevent;

class StorageEvent
{
    public BsonObjectID _id;
    public string eventType;
    public long eventCreated;
    public ulong usrId;
    public EventLifecycle lifecycle;
    public Json metadataJson;

    this(TypeInfo eventType, EventLifecycle lifecycle, Json metadataJson, ulong usrId = 0) {
        this._id = BsonObjectID.generate();
        this.eventType = eventType.toString();
        this.eventCreated = lifecycle.eventCreated;
        this.usrId = usrId;
        this.lifecycle = lifecycle;
        this.metadataJson = metadataJson;
    }

    public BsonObjectID getId() {
        return this._id;
    }
}