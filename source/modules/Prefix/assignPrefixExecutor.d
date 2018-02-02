module executors.auth.assignprefix;

import std.stdio;
import std.variant;

import command.all;
import relationaldb.all;
import commands.assignprefix;
import helpers.helperfactory;

class AssignPrefixExecutor : AbstractExecutor!(AssignPrefixCommand,AssignPrefixCommandMetadata)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private AssignPrefixCommandMetadata meta;

    this(
        RelationalDBInterface relationalDb,
        CommandInterface command
    ) {
        this.relationalDb = relationalDb;
        this.meta = this.getMetadataFromCommandInterface(command);
    }

    void executeCommand() {
        this.assignUserToPrefix();
    }

    public void assignUserToPrefix() {
        string sql = "
                UPDATE prefix
                SET `usrId` = ?
                WHERE `prefix` = ?
            ";       

        this.relationalDb.execute(sql, variantArray(this.meta.usrId, this.meta.prefix));                          
    }     
}