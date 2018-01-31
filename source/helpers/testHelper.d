module helpers.testhelper;

import command.all;

class TestHelper
{
    public static void testDecisionMaker(T, V)(V facts, uint numberOfExpectedCommands, bool exceptionExpected)
    {
        bool exceptionThrown = false;

        auto commandList = new EventList();
        
        try {
            auto decisionMaker = new T(facts);
            decisionMaker.issueCommands(commandList);
        } catch(Exception e) {
            exceptionThrown = true;
        }

        assert(commandList.size() == numberOfExpectedCommands);        
        assert(exceptionExpected == exceptionThrown);
    }
}