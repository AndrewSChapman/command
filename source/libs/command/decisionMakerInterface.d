module command.decisionmakerinterface;

import command.all;

interface DecisionMakerInterface
{
    public void issueCommands(CommandBusInterface commandList) @safe;
    /*
    public bool canRunAsync() @safe;
    public void throwExceptionIfNecessary() @safe;
    */
}