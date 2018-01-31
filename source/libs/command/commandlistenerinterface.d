module command.commandlistenerinterface;

import command.CommandInterface;
import command.eventlist;

interface CommandListenerInterface
{
    public TypeInfo[] getInterestedCommands() @safe;
    public CommandBusInterface executeCommand(CommandInterface event, TypeInfo commandType) @safe;
}