module executors.deletetoken;

import vibe.vibe;
import std.variant;
import std.datetime;
import core.time;

import command.all;
import relationaldb.all;
import commands.deletetoken;
import helpers.helperfactory;

class DeleteTokenExecutor : AbstractExecutor!(DeleteTokenCommand,DeleteTokenCommandMetadata)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private RedisDatabase redisDatabase;
    private DeleteTokenCommandMetadata meta;

    this(
        RelationalDBInterface relationalDb,
        RedisDatabase redisDatabase,
        CommandInterface command
    ) {
        this.relationalDb = relationalDb;
        this.redisDatabase = redisDatabase;
        this.meta = this.getMetadataFromCommandInterface(command);
    }

    void executeCommand() @safe
    {
        if (this.meta.tokenCode != "") {
            this.deleteToken();
        }

        if (this.meta.deleteAllUserTokens) {
            this.deleteUsrTokens();
        }
    }

    public void deleteToken() @trusted
    {
        string sql = "
                DELETE FROM token
                WHERE tokenCode = ?
            ";    

        this.relationalDb.execute(sql, variantArray(
            this.meta.tokenCode
        )); 

        if (this.redisDatabase.exists(this.meta.tokenCode)) {
            this.redisDatabase.del(this.meta.tokenCode);
        } 	
    }

    public void deleteUsrTokens() @trusted
    {
        string sql = "
                DELETE FROM token
                WHERE usrId = ?
            ";    

        this.relationalDb.execute(sql, variantArray(
            this.meta.usrId
        )); 
    }        
}