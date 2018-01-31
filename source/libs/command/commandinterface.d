module command.CommandInterface;

import std.variant;
import command.abstractcommand;

interface CommandInterface
{
    public EventLifecycle getLifecycle() @safe;
    public Variant getMetadata();
    public void setEventReceived() @safe;
    public void setEventDispatched() @safe;
}