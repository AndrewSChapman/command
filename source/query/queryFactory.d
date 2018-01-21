module query.factory;

import relationaldb.all;
import query.all;

class QueryFactory
{
    protected RelationalDBInterface relationalDb;

    this(RelationalDBInterface relationalDb) @safe
    {
        this.relationalDb = relationalDb;
    }

    public GroupQuery createGroupQuery() @safe
    {
        return new GroupQuery(this.relationalDb);
    }     

    public PrefixQuery createPrefixQuery() @safe
    {
        return new PrefixQuery(this.relationalDb);
    }

    public TokenQuery createTokenQuery() @safe
    {
        return new TokenQuery(this.relationalDb);
    }

    public UserQuery createUserQuery() @safe
    {
        return new UserQuery(this.relationalDb);
    } 
}