module executors.profile.updateuser;

import std.stdio;
import std.variant;

import command.all;
import relationaldb.all;
import helpers.helperfactory;
import commands.updateuser;

class UpdateUserExecutor : AbstractExecutor!(UpdateUserCommand,UpdateUserCommandMetadata)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private UpdateUserCommandMetadata meta;

    this(
        RelationalDBInterface relationalDb,
        CommandInterface command
    ) {
        this.relationalDb = relationalDb;
        this.meta = this.getMetadataFromCommandInterface(command);
    }

    void executeCommand() {
        this.updateUser();
    }

    private void updateUser() {

        string sql = "
                UPDATE usr SET 
                firstName = ?,
                lastName = ?
                WHERE usrId = ?
            ";

        this.relationalDb.execute(sql, variantArray(
            this.meta.firstName,
            this.meta.lastName,
            this.meta.usrId
        ));
    }       
}