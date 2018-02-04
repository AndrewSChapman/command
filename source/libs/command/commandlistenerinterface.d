module command.commandlistenerinterface;

import command.CommandInterface;
import command.eventlist;

interface CommandListenerInterface
{
    public TypeInfo[] getRegisteredCommands() @safe;
    public CommandBusInterface executeCommand(CommandInterface command, TypeInfo commandType) @safe;
}