module projections.profile.updateuser;

import std.stdio;
import std.variant;

import relationaldb.all;
import helpers.helperfactory;
import commands.updateuser;

class UpdateUserProjection
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private UpdateUserMeta meta;

    this(
        RelationalDBInterface relationalDb,
        UpdateUserMeta meta
    ) {
        this.relationalDb = relationalDb;
        this.meta = meta;
    }

    void handleEvent() {
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