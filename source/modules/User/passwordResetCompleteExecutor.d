module executors.auth.passwordresetcomplete;

import std.stdio;
import std.variant;

import command.all;
import relationaldb.all;
import commands.passwordresetcomplete;
import helpers.helperfactory;

class PasswordResetCompleteExecutor : AbstractExecutor!(PasswordResetCompleteCommand,PasswordResetCompleteCommandMetadata)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private PasswordResetCompleteCommandMetadata meta;
    private HelperFactory helperFactory;

    this(
        RelationalDBInterface relationalDb,
        HelperFactory helperFactory,
        CommandInterface command
    ) {
        this.relationalDb = relationalDb;
        this.helperFactory = helperFactory;
        this.meta = this.getMetadataFromCommandInterface(command);
    }

    void executeCommand() {
        this.setPasswordFromNewPassword();
    }  

    private void setPasswordFromNewPassword()
    {        
        string sql = "
                UPDATE usr SET 
                    password = newPassword,
                    newPasswordPin = null
                WHERE usrId = ?;
            ";

        this.relationalDb.execute(sql, variantArray(
            this.meta.usrId
        ));

        sql = "
                UPDATE usr SET 
                    newPassword = null
                WHERE usrId = ?;
            ";

        this.relationalDb.execute(sql, variantArray(
            this.meta.usrId
        ));        
    }   
}