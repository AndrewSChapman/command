module executors.incrementfailedlogincount;

import std.variant;

import relationaldb.all;
import commands.incrementfailedlogincount;
import command.all;

class IncrementFailedLoginCountExecutor : AbstractExecutor!(IncrementFailedLoginCountCommand,IncrementFailedLoginCountCommandMetadata)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private IncrementFailedLoginCountCommandMetadata meta;

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
                SET numLoginAttempts = numLoginAttempts + 1, lastLoginAttempt = Now()
                WHERE usrId = ?
            "; 

        this.relationalDb.execute(sql, variantArray(this.meta.usrId));
    }   
}