module query.factory;

import relationaldb.all;
import query.all;

class QueryFactory
{
    protected RelationalDBInterface relationalDb;

    this(RelationalDBInterface relationalDb) {
        this.relationalDb = relationalDb;
    }

    public GroupQuery createGroupQuery()
    {
        return new GroupQuery(this.relationalDb);
    }     

    public PrefixQuery createPrefixQuery()
    {
        return new PrefixQuery(this.relationalDb);
    }

    public TokenQuery createTokenQuery()
    {
        return new TokenQuery(this.relationalDb);
    }

    public UserQuery createUserQuery()
    {
        return new UserQuery(this.relationalDb);
    } 
}