module decisionmakers.decisionmakerinterface;

import eventmanager.all;

interface DecisionMakerInterface
{
    public void issueCommands(EventListInterface eventList) @safe;
}