module command.abstractcommand;

import std.datetime;
import std.variant;
import std.exception;
import std.stdio;
import vibe.vibe;

import command.commandinterface;
import eventstore.all;

struct CommandLifecycle
{
    long eventCreated;
    long eventReceived;
    long eventDispatched;
    long eventProcessingTime;   // How long the command took to be fully processed.
}

abstract class AbstractCommand(T) : CommandInterface,StorableEvent
{
    protected CommandLifecycle lifecycle;
    protected T metadata;

    this(T metadata) @safe {
        //this.timestamp = Clock.currTime().toUnixTime();
        this.lifecycle.eventCreated = Clock.currStdTime();
        this.metadata = metadata;
    }

    public CommandLifecycle getLifecycle() @safe
    {
        return this.lifecycle;
    }

    public Variant getMetadata()
    {
        return cast(Variant)this.metadata;
    }

    public void setEventReceived() @safe
    {
        this.lifecycle.eventReceived = Clock.currStdTime();
    }

    public void setEventDispatched() @safe in {
        enforce(this.lifecycle.eventReceived > 0, "Event must be flagged as being received BEFORE being dispatched");
    } body {
        this.lifecycle.eventDispatched = Clock.currStdTime();
        this.lifecycle.eventProcessingTime = this.lifecycle.eventDispatched - this.lifecycle.eventCreated;
    }

    public T getMetadataStruct() @trusted
    {
        return *this.getMetadata().peek!(T);
    }

    public StorageEvent toStorageEvent() @trusted
    {
        ulong usrId = 0;
        auto metadata = this.getMetadataStruct();

        static if(__traits(hasMember, T, "usrId")) {
            usrId = metadata.usrId;
        }

        return new StorageEvent(typeid(this), this.getLifecycle(), metadata.serializeToJson(), usrId);
    }    
}

unittest {
    struct EventTestMetadata
    {
        int id;
        string name;
    }
        
    class TestEvent : AbstractCommand!EventTestMetadata
    {
        this(EventTestMetadata metadata)
        {
            super(metadata);
        }
    }

    EventTestMetadata metadata;
    metadata.id = 1;
    metadata.name = "Jane Doe";
    
    // Test instantiating an command
    auto testEvent = new TestEvent(metadata);

    // Ensure the lifecycle created time has been set
    auto lifeCycle = testEvent.getLifecycle();
    assert(lifeCycle.eventCreated > 0);

    // Ensure we can get the command metadata back correctly
    auto meta = testEvent.getMetadata();
    assert(meta.type == typeid(EventTestMetadata));
    EventTestMetadata metaEventTest = *meta.peek!(EventTestMetadata);
    assert(metaEventTest.id == 1);
    assert(metaEventTest.name == "Jane Doe");
}