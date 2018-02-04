module helpers.testhelper;

import command.all;
import std.stdio;

class TestHelper
{
    public static void testDecisionMaker(T, V)(V facts, uint numberOfExpectedCommands, bool exceptionExpected)
    {
        bool exceptionThrown = false;

        auto commandList = new CommandList();
        
        try {
            auto decisionMaker = new T(facts);
            decisionMaker.issueCommands(commandList);

            if (exceptionExpected) {
                writeln("These facts did NOT fail when they should have: ", facts);
            }
        } catch(Exception e) {
            if (!exceptionExpected) {
                writeln("These facts failed when they should not have: ", facts);
            }
            exceptionThrown = true;
        }

        assert(commandList.size() == numberOfExpectedCommands);        
        assert(exceptionExpected == exceptionThrown);
    }
}