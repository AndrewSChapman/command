module facts.toomanyincorrectpinattempts;

import command.all;
import std.stdio;

class TooManyIncorrectPinAttempts : AbstractFact
{
    private uint numIncorrectPinAttempts;

    this(uint numIncorrectPinAttempts) @safe
    {
        super("TooManyIncorrectPinAttempts");
        this.numIncorrectPinAttempts = numIncorrectPinAttempts;
    }

    override public bool isTrue() @safe
    {
        return this.numIncorrectPinAttempts > 5;
    }
}