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

    public Json[] findByEventTypeAndWorkspace(
        string eventType,
        string workspaceId,
        long createdAfterSystime,
        EventStorePager pager,
    ) @safe {
        auto queryData = [
            "eventType" : Bson(eventType),
            "metadataJson.workspaceId" : Bson(workspaceId)
        ];

        if (createdAfterSystime > 0) {
            queryData["eventCreated"] = ["$gt": Bson(createdAfterSystime)];
        }

        Bson query = Bson(queryData);

        Json[] items;

        auto result = this.mongoCollection.find(query);

        if (!(pager is null)) {
            result.limit(pager.getNumItemsPerPage());

            if (pager.calculateOffset() > 0) {
                result.skip(to!int(pager.calculateOffset()));
            }

            if (pager.getSortDirection() == SortDirection.DESCENDING) {
                result.sort(["eventCreated" : -1]);
            } else {
                result.sort(["eventCreated" : 1]);
            }
        }

        while (!result.empty) {
            auto doc = result.front();
            items ~= doc.toJson();
            result.popFront();            
        }

        return items;
    }
}