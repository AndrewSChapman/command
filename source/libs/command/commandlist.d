module command.eventlist;

import std.container : DList;
import std.algorithm.comparison : equal;

import std.stdio;

import command.abstractcommand;
import command.CommandInterface;
import command.commanddispatcher;

struct CommandContainer
{
    TypeInfo commandType;
    CommandInterface event;
}

interface CommandBusInterface {
    public void append(CommandInterface event, TypeInfo commandType) @safe;
    public void dispatch(CommandDispatcherInterface dispatcher) @safe;
    public DList!CommandContainer getEventList() @safe;
    public ulong size() @safe;
}

class EventList : CommandBusInterface
{
    private DList!CommandContainer eventList;

    this() @safe {
        this.eventList = DList!CommandContainer();
    }  

    public void append(CommandInterface event, TypeInfo commandType) @safe
    {
        CommandContainer container;
        container.commandType = commandType;
        container.event = event;

        this.eventList.insertBack(container);
    }

    // Allow appending from one event list into another.
    public void append(CommandBusInterface newEventList) @safe {
        foreach (container; newEventList.getEventList()) {
            this.append(container.event, container.commandType);
        }
    }

    /**
    Process all of the events in this event list.  Each event may
    in turn create new events which must also be processed.  Keep
    looping until all events have been processed and no new events
    have been created.
    */
    public void dispatch(CommandDispatcherInterface dispatcher) @safe
    {
        auto eventList = this.eventList;

        while (true) {
            auto newEventList = new EventList();

            foreach (container; eventList) {
                newEventList.append(dispatcher.dispatch(container.event, container.commandType));
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

    public DList!CommandContainer getEventList() @safe
    {
        return this.eventList;
    } 

    public ulong size() @safe
    {
        ulong count = 0;

        foreach (container; this.eventList) {
            ++count;
        }

        return count;
    }
}