module query.group;

import std.typecons;
import std.variant;
import std.conv;
import std.exception;

import relationaldb.all;
import entity.group;

class GroupQuery
{
    protected RelationalDBInterface relationalDb;

    this(RelationalDBInterface relationalDb)
    {
        this.relationalDb = relationalDb;
    }

    public bool existsById(string groupId)
    {
        enforce(groupId != "", "Please provide a valid group Id");

        string sql = "
                SELECT
                    count(*) as numRows
                FROM
                    grp
                WHERE
                    id = ?
            ";

        auto numRows = this.relationalDb.getColumnValueInt(
            sql,
            variantArray(groupId)
        );

        return (numRows > 0);
    }

    public Group getById(string groupId)
    {
        enforce(groupId != "", "Please provide a valid group Id");        

        string sql = "
                SELECT
                    g.grpId, g.name
                FROM
                    grp g
                WHERE
                    g.id = ?
            ";

        auto group = this.relationalDb.loadRow!Group(
            sql,
            variantArray(groupId)
        );            

        return group;
    }    
}