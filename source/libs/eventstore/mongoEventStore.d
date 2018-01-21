module eventstore.mongoeventstore;

import std.typecons;
import std.stdio;
import std.conv;

import vibe.vibe;
import eventstore.eventstoreinterface;
import eventstore.storageevent;
import eventstore.pager;

class MongoEventStore : EventStoreInterface
{
    protected MongoCollection mongoCollection;

    this(MongoClient client, string collectionName) @safe {
        this.mongoCollection = client.getCollection(collectionName);
    }

    public void persist(StorageEvent storageEvent)
    {
        this.mongoCollection.insert(storageEvent);
    }
}