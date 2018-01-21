module helpers.testhelper;

import eventmanager.all;

class TestHelper
{
    public static void testGenericCommand(T, U, V)(ref U meta, V factors, uint numEvents, bool exceptionExpected)
    {
        bool exceptionThrown = false;

        auto eventList = new EventList();
        
        try {
            auto command = new T(meta, factors);
            command.execute(eventList);
        } catch(Exception e) {
            exceptionThrown = true;
        }

        assert(eventList.size() == numEvents);        
        assert(exceptionExpected == exceptionThrown);
    }
}