module eventstore.pager;

import std.exception;
import vibe.vibe;

enum SortDirection { ASCENDING, DESCENDING };

class EventStorePager
{
    private size_t itemsPerPage;
    private size_t offset;
    private SortDirection sortDirection;
    private uint currentPageNo;

    this(SortDirection sortDirection) @safe {
        this.itemsPerPage = 50;
        this.offset = 0;
        this.currentPageNo = 1;
        this.sortDirection = sortDirection;
    }

    public void setPaging(const size_t itemsPerPage, uint currentPageNo) @safe
    {
        enforce(itemsPerPage > 0, "itemsPerPage must be greater than zero");
        enforce(currentPageNo > 0, "currentPageNo must be greater than zero");
                
        this.itemsPerPage = itemsPerPage;
        this.currentPageNo = currentPageNo;
        this.offset = this.calculateOffset();
    }

    public SortDirection getSortDirection() @safe
    {
        return this.sortDirection;
    } 

    public size_t getNumItemsPerPage() @safe
    {
        return this.itemsPerPage;
    }    

    public size_t nextPage() @safe
    {
        this.currentPageNo++;
        return this.calculateOffset();
    }

    public size_t prevPage() @safe
    {
        if(this.currentPageNo > 0) {
            this.currentPageNo--;
        }

        return this.calculateOffset();
    }    

    public size_t calculateOffset() @safe
    {
        return this.itemsPerPage * (this.currentPageNo - 1);
    }
}