module command.abstractexecutor;

import command.CommandInterface;

abstract class AbstractExecutor(CommandType,MetadataType)
{
    protected MetadataType getMetadataFromCommandInterface(CommandInterface event) 
    {
        return (cast(CommandType)event).getMetadataStruct();
    }
}