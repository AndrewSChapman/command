module query.prefix;

import std.typecons;
import std.variant;
import std.conv;
import std.exception;
import std.stdio;

import entity.prefix;
import relationaldb.all;

class PrefixQuery
{
    protected RelationalDBInterface relationalDb;

    this(RelationalDBInterface relationalDb) {
        this.relationalDb = relationalDb;
    }

    public bool exists(in string prefixCode)
    {
        enforce(prefixCode != "", "Please supply a prefix code");

        string sql = "
                SELECT count(`prefix`) as numRows
                FROM prefix
                WHERE prefix = ?
            ";

        auto numRows = this.relationalDb.getColumnValueInt(
            sql,
            variantArray(prefixCode)
        );            

        return (numRows > 0);
    }

    public Prefix getPrefix(in string prefixCode)
    {
        enforce(prefixCode != "", "Please supply a prefix code");
        
        string sql = "
                SELECT *
                FROM prefix
                WHERE prefix = ?
            ";

        Prefix prefix = this.relationalDb.loadRow!Prefix(
            sql,
            variantArray(prefixCode)
        );            

        return prefix;
    }    
}