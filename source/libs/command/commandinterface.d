module command.CommandInterface;

import std.variant;
import command.abstractcommand;
import eventstore.all;

interface CommandInterface
{
    public CommandLifecycle getLifecycle() @safe;
    public Variant getMetadata();
    public void setEventReceived() @safe;
    public void setEventDispatched() @safe;
    public StorageEvent toStorageEvent() @trusted;
}