module eventstore.eventlistwithstorage;

import std.stdio;
import std.variant;

import eventstore.mongoeventstore;
import eventstore.eventstoreinterface;
import command.all;

// Delete this later
import commands.registeruser;

class CommandBusWithStorage : CommandBus
{
    protected EventStoreInterface eventStoreInterface;
    
    this(EventStoreInterface eventStoreInterface) @safe
    {
        super();
        
        this.eventStoreInterface = eventStoreInterface;
    }    
    
    /**
    Process all of the events in this command list.  Each command may
    in turn create new events which must also be processed.  Keep
    looping until all events have been processed and no new events
    have been created.
    */
    override public void dispatch(CommandDispatcherInterface dispatcher) @trusted
    {    
        auto commandBus = this.getEventList();

        while (true) {
            auto newCommandList = new CommandBus();

            foreach (container; commandBus) {
                // Set the lifecycle time for command received
                container.command.setEventReceived();
                newCommandList.append(dispatcher.dispatch(container.command, container.commandType));

                // Set the lifecycle time for command dispatched
                container.command.setEventDispatched();

                // Store the command in Mongo
                auto storageEvent = (cast(StorableEvent)container.command).toStorageEvent();
                this.eventStoreInterface.persist(storageEvent);
            }

            // If no new events were created, terminate the loop.
            if (newCommandList.size() == 0) {
                break;
            }

            // Use the "new command list" as the basis of the loop
            // for the next interation.
            commandBus = newCommandList.getEventList();
        }
    }    
}