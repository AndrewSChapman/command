module projections.auth.passwordresetcomplete;

import std.stdio;
import std.variant;

import relationaldb.all;
import decisionmakers.passwordresetcomplete;
import helpers.helperfactory;

class PasswordResetCompleteProjection
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private PasswordResetCompleteDMMeta meta;
    private HelperFactory helperFactory;

    this(
        RelationalDBInterface relationalDb,
        HelperFactory helperFactory,
        ref in PasswordResetCompleteDMMeta meta
    ) {
        this.relationalDb = relationalDb;
        this.helperFactory = helperFactory;
        this.meta = meta;
    }

    void handleEvent() {
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