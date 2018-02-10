module command.decisionmakerinterface;

import command.all;
import container;

interface DecisionMakerInterface
{
    public void issueCommands(CommandBusInterface commandBus) @safe;
    /*public void executeCommands(Container container, CommandBusInterface commandBus) @safe;*/
}