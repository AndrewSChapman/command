module helpers.testhelper;

import command.all;
import std.stdio;

class TestHelper
{
    public static void testDecisionMaker(T, V)(V facts, uint numberOfExpectedCommands, bool exceptionExpected)
    {
        bool exceptionThrown = false;

        auto commandBus = new CommandBus();
        
        try {
            auto decisionMaker = new T(facts);
            decisionMaker.issueCommands(commandBus);

            if (exceptionExpected) {
                writeln("These facts did NOT fail when they should have: ", facts);
            }
        } catch(Exception e) {
            if (!exceptionExpected) {
                writeln("These facts failed when they should not have: ", facts);
            }
            exceptionThrown = true;
        }

        assert(commandBus.size() == numberOfExpectedCommands);        
        assert(exceptionExpected == exceptionThrown);
    }
}