module eventstore.eventstoreinterface;

import eventstore.storageevent;
import eventstore.pager;
import vibe.vibe;

interface EventStoreInterface
{
    public void persist(StorageEvent storageEvent);
}

interface StorableEvent
{
    public StorageEvent toStorageEvent();   
}