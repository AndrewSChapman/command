module query.abstractquery;

import std.exception;
import std.string;

import relationaldb.all;

abstract class AbstractQuery
{
    protected RelationalDBInterface relationalDb;
    private uint itemsPerPage = 25;

    this(RelationalDBInterface relationalDb) @safe
    {
        this.relationalDb = relationalDb;
    }

    public void setItemsPerPage(uint itemsPerPage) @safe
    {
        this.itemsPerPage = itemsPerPage;
    }

    protected uint calculatePageOffset(in ref uint pageNo) @safe
    {
        enforce(this.itemsPerPage > 0, "Cannot calculate offset when itemsPerPage is 0");
        return this.itemsPerPage * (pageNo - 1);
    }

    protected void applyPaging(ref string sql, uint pageNo)
    {
        if (pageNo == 0) {
            return;
        }

        sql ~= format(`LIMIT %d OFFSET %d `,
            this.itemsPerPage,
            this.calculatePageOffset(pageNo)
        );
    }    
}