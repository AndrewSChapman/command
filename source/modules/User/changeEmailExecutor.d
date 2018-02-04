module executors.profile.changeemail;

import std.stdio;
import std.variant;

import command.all;
import relationaldb.all;
import helpers.helperfactory;
import commands.changeemail;

class ChangeEmailExecutor : AbstractExecutor!(ChangeEmailCommand,ChangeEmailCommandMeta)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private ChangeEmailCommandMeta meta;

    this(
        RelationalDBInterface relationalDb,
        CommandInterface command
    ) {
        this.relationalDb = relationalDb;
        this.meta = this.getMetadataFromCommandInterface(command);
    }

    void executeCommand() {
        this.changeEmail();
    }

    private void changeEmail() {

        string sql = "
                UPDATE 
                    usr 
                SET 
                    email = ?
                WHERE
                    usrId = ?
            ";

        this.relationalDb.execute(sql, variantArray(
            this.meta.emailAddress,
            this.meta.usrId
        ));
    }       
}