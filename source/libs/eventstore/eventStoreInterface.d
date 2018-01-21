module eventstore.eventstoreinterface;

import eventstore.storageevent;
import eventstore.pager;
import vibe.vibe;

interface EventStoreInterface
{
    public void persist(StorageEvent storageEvent);
    public Json[] findByEventTypeAndWorkspace(string eventType, string workspaceId, long createdAfterSystime, EventStorePager pager);
}

interface StorableEvent
{
    public StorageEvent toStorageEvent();   
}