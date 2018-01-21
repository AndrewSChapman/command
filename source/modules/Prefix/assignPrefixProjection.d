module projections.auth.assignprefix;

import std.stdio;
import std.variant;

import relationaldb.all;
import commands.assignprefix;
import helpers.helperfactory;

class AssignPrefixProjection
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private AssignPrefixMeta meta;

    this(
        RelationalDBInterface relationalDb,
        AssignPrefixMeta meta
    ) {
        this.relationalDb = relationalDb;
        this.meta = meta;
    }

    void handleEvent() {
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