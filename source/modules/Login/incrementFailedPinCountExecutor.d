module executors.incrementfailedpincount;

import std.variant;

import relationaldb.all;
import commands.incrementfailedpincount;
import command.all;

class IncrementFailedPinCountExecutor : AbstractExecutor!(IncrementFailedPinCountCommand,IncrementFailedPinCountCommandMetadata)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private IncrementFailedPinCountCommandMetadata meta;

    this(
        RelationalDBInterface relationalDb,
        CommandInterface command
    ) {
        this.relationalDb = relationalDb;
        this.meta = this.getMetadataFromCommandInterface(command);
    }

    void executeCommand() {
        this.incrementFailedLoginCount();    
    } 

    private void incrementFailedLoginCount()
    {
        string sql = "
                UPDATE usr 
                SET numPinAttempts = numPinAttempts + 1
                WHERE usrId = ?
            "; 

        this.relationalDb.execute(sql, variantArray(this.meta.usrId));
    }   
}