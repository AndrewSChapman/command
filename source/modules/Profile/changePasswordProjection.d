module projections.profile.changepassword;

import std.stdio;
import std.variant;

import relationaldb.all;
import helpers.helperfactory;
import commands.changepassword;

class ChangePasswordProjection
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private ChangePasswordCommandMetadata meta;
    private HelperFactory helperFactory;

    this(
        RelationalDBInterface relationalDb,
        HelperFactory helperFactory,
        ChangePasswordCommandMetadata meta
    ) {
        this.relationalDb = relationalDb;
        this.helperFactory = helperFactory;
        this.meta = meta;
    }

    void handleEvent() {
        this.changePassword();
    }

    private void changePassword() {
        auto passwordHelper = this.helperFactory.createPasswordHelper();
        string hashedPassword = passwordHelper.HashBcrypt(this.meta.password);        

        string sql = "
                UPDATE usr SET 
                password = ?
                WHERE usrId = ?
            ";

        this.relationalDb.execute(sql, variantArray(
            hashedPassword,
            this.meta.usrId
        ));
    }       
}