module command.abstractdecisionmaker;

abstract class AbstractDecisionMaker
{
    bool canRunAsync()
    {
        return false;
    }

    public void throwExceptionIfNecessary()
    {

    }
}