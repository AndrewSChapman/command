module eventstore.eventlistwithstorage;

import std.stdio;
import std.variant;

import eventstore.mongoeventstore;
import eventstore.eventstoreinterface;
import eventmanager.all;

// Delete this later
import commands.registeruser;

class EventListWithStorage : EventList
{
    protected EventStoreInterface eventStoreInterface;
    

    this(EventStoreInterface eventStoreInterface) @safe
    {
        super();
        this.eventStoreInterface = eventStoreInterface;
    }    
    
    /**
    Process all of the events in this event list.  Each event may
    in turn create new events which must also be processed.  Keep
    looping until all events have been processed and no new events
    have been created.
    */
    override public void dispatch(EventDispatcherInterface dispatcher) @safe
    {    
        auto eventList = this.getEventList();

        while (true) {
            auto newEventList = new EventList();

            foreach (container; eventList) {
                // Set the lifecycle time for event received
                container.event.setEventReceived();
                newEventList.append(dispatcher.dispatch(container.event, container.eventType));

                // Set the lifecycle time for event dispatched
                container.event.setEventDispatched();

                // Store the event in Mongo
                auto storageEvent = (cast(StorableEvent)container.event).toStorageEvent();
                this.eventStoreInterface.persist(storageEvent);
            }

            // If no new events were created, terminate the loop.
            if (newEventList.size() == 0) {
                break;
            }

            // Use the "new event list" as the basis of the loop
            // for the next interation.
            eventList = newEventList.getEventList();
        }
    }    
}