module command.commanddispatcher;

import std.container : SList;
import std.algorithm.comparison : equal;
import std.stdio;

import command.commandlistenerinterface;
import command.commandinterface;
import command.commandbus;

interface CommandDispatcherInterface
{
    public void attachListener(CommandListenerInterface listener) @safe;
    public CommandBusInterface dispatch(CommandInterface command, TypeInfo commandType) @safe;
}

class CommandDispatcher : CommandDispatcherInterface
{
    // To clarify, this is a hashmap where an object type maps
    // to a singly linked list of eventlistenerinterfaces.
    private SList!CommandListenerInterface[TypeInfo] listenerMap;
    
    public void attachListener(CommandListenerInterface listener) @safe
    {
        auto listenerType = typeid(listener);
        auto interestedCommands = listener.getRegisteredCommands();

        foreach (commandType; interestedCommands) {
            if (!(commandType in this.listenerMap)) {
                this.listenerMap[commandType] = SList!CommandListenerInterface(listener);
            } else {
                this.listenerMap[commandType].insertFront(listener);
            }
        }
    }

    public CommandBusInterface dispatch(CommandInterface command, TypeInfo commandType) @safe
    {
        auto commandBus = new CommandBus();
        
        if(this.noListenersInterestedInThisEvent(commandType)) {
            return commandBus;
        }

        command.setEventReceived();

        auto interestedListeners = this.listenerMap[commandType];

        foreach (listener; interestedListeners) {
            commandBus.append(listener.executeCommand(command, commandType));
        }

        command.setEventDispatched();

        return commandBus;
    }    

    private bool noListenersInterestedInThisEvent(TypeInfo commandType) @safe {
        return !(commandType in this.listenerMap);
    }
}
