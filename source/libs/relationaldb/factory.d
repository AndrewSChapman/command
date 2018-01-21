module relationaldb.factory;

import mysql;
import relationaldb.interfaces;
import relationaldb.mysql;

class RelationalDBFactory
{
    public static RelationalDBInterface getConnection(Connection connection)
    {
        return new MySQLRelationalDB(connection);
    }
}