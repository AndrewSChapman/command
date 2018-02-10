module command.commandbus;

import std.container : DList;
import std.algorithm.comparison : equal;

import std.stdio;

import command.abstractcommand;
import command.commandinterface;
import command.commanddispatcher;

struct CommandContainer
{
    TypeInfo commandType;
    CommandInterface command;
}

interface CommandBusInterface {
    public void append(CommandInterface command, TypeInfo commandType) @safe;
    public void dispatch(CommandDispatcherInterface dispatcher) @safe;
    public DList!CommandContainer getEventList() @safe;
    public ulong size() @safe;
}

class CommandBus : CommandBusInterface
{
    private DList!CommandContainer commandBus;

    this() @safe {
        this.commandBus = DList!CommandContainer();
    }  

    public void append(CommandInterface command, TypeInfo commandType) @safe
    {
        CommandContainer container;
        container.commandType = commandType;
        container.command = command;

        this.commandBus.insertBack(container);
    }

    // Allow appending from one command list into another.
    public void append(CommandBusInterface newCommandList) @safe {
        foreach (container; newCommandList.getEventList()) {
            this.append(container.command, container.commandType);
        }
    }

    /**
    Process all of the events in this command list.  Each command may
    in turn create new events which must also be processed.  Keep
    looping until all events have been processed and no new events
    have been created.
    */
    public void dispatch(CommandDispatcherInterface dispatcher) @safe
    {
        auto commandBus = this.commandBus;

        while (true) {
            auto newCommandList = new CommandBus();

            foreach (container; commandBus) {
                newCommandList.append(dispatcher.dispatch(container.command, container.commandType));
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

    public DList!CommandContainer getEventList() @safe
    {
        return this.commandBus;
    } 

    public ulong size() @safe
    {
        ulong count = 0;

        foreach (container; this.commandBus) {
            ++count;
        }

        return count;
    }
}