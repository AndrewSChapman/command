module facts.toomanyfailedlogins;

import command.all;

class TooManyFailedLogins : AbstractFact
{
    private uint numFailedLogins;

    this(uint numFailedLogins) @safe
    {
        super("TooManyFailedLogins");
        this.numFailedLogins = numFailedLogins;
    }

    override public bool isTrue() @safe
    {
        return this.numFailedLogins > 5;
    }
}