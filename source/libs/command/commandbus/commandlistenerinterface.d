module command.commandlistenerinterface;

import command.commandinterface;
import command.commandbus;

interface CommandListenerInterface
{
    public TypeInfo[] getRegisteredCommands() @safe;
    public CommandBusInterface executeCommand(CommandInterface command, TypeInfo commandType) @safe;
}