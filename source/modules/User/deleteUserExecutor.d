module executors.deleteuser;

import std.stdio;
import std.variant;

import command.all;
import relationaldb.all;
import commands.deleteuser;

class DeleteUserExecutor : AbstractExecutor!(DeleteUserCommand,DeleteUserCommandMetadata)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private DeleteUserCommandMetadata meta;

    this(
        RelationalDBInterface relationalDb,
        CommandInterface command
    ) {
        this.relationalDb = relationalDb;
        this.meta = this.getMetadataFromCommandInterface(command);
    }

    void executeCommand() {
        this.deleteUser();
    }

    private void deleteUser() {
        if (this.meta.hardDelete) {
            string sql = "
                    DELETE FROM usr
                    WHERE usrId = ?
                ";

            this.relationalDb.execute(sql, variantArray(
                this.meta.usrId
            ));
        } else {
            string sql = "
                    UPDATE usr
                    SET deleted = 1
                    WHERE usrId = ?
                ";

            this.relationalDb.execute(sql, variantArray(
                this.meta.usrId
            ));
        }
    }       
}