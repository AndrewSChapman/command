module executors.auth.createprefix;

import std.stdio;
import std.variant;
import std.conv;
import std.digest.crc;

import command.all;
import relationaldb.all;
import commands.assignprefix;
import helpers.helperfactory;
import commands.createprefix;

class CreatePrefixExecutor : AbstractExecutor!(CreatePrefixCommand,CreatePrefixCommandMetadata)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private CreatePrefixCommandMetadata meta;

    this(
        RelationalDBInterface relationalDb,
        CommandInterface command
    ) {
        this.relationalDb = relationalDb;
        this.meta = this.getMetadataFromCommandInterface(command);
    }  

    public void executeCommand(ref Variant[string] eventMessage) {
        string prefix = this.generatePrefix();
        this.insertPrefix(prefix);

        Variant prefixCode = prefix;
        eventMessage["prefixCode"] = prefixCode;
    }

    string generatePrefix()
    {
        string combined = this.meta.userAgent ~ this.meta.ipAddress ~ to!string(this.meta.timestamp);
        ubyte[4] hash = crc32Of(combined);
        return crcHexString(hash);
    }

    private void insertPrefix(string prefix) {
        string sql = "
                INSERT INTO prefix(`prefix`) 
                VALUES(?);
            ";    

        this.relationalDb.execute(sql, variantArray(
            prefix,
        ));                 
    }      
}