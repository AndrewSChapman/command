module command.abstractexecutor;

import command.commandinterface;

abstract class AbstractExecutor(CommandType,MetadataType)
{
    protected MetadataType getMetadataFromCommandInterface(CommandInterface event) 
    {
        return (cast(CommandType)event).getMetadataStruct();
    }
}