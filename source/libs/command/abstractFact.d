module facts.abstractfact;

abstract class AbstractFact
{
    private string factName;

    this(string factName) @safe
    {
        this.factName = factName;
    }

    public bool isTrue() @safe
    {
        return true;
    }

    override public string toString() @safe
    {
        return this.factName ~ ": " ~ (this.isTrue() ? "Yes" : "No");
    }    
}