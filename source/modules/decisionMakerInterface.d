module decisionmakers.decisionmakerinterface;

import command.all;

interface DecisionMakerInterface
{
    public void issueCommands(CommandBusInterface commandList) @safe;
}