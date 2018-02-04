module executors.auth.login;

import std.stdio;
import std.variant;
import std.datetime;
import core.time;

import relationaldb.all;
import commands.login;
import helpers.helperfactory;
import entity.token;
import command.all;

class LoginExecutor : AbstractExecutor!(LoginCommand,LoginCommandMetadata)
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private LoginCommandMetadata meta;
    private HelperFactory helperFactory;
    private const uint tokenTimeoutInSeconds = 3600;

    this(
        RelationalDBInterface relationalDb,
        HelperFactory helperFactory,
        CommandInterface command
    ) {
        this.relationalDb = relationalDb;
        this.helperFactory = helperFactory;
        this.meta = this.getMetadataFromCommandInterface(command);
    }

    void executeCommand(ref Variant[string] eventMessage) {
        string tokenCode = this.generateToken(this.helperFactory.createStringsHelper());

        Token token;
        token.tokenCode = tokenCode;
        token.ipAddress = this.meta.ipAddress;
        token.userAgent = this.meta.userAgent;
        token.prefix = this.meta.prefix;
        token.expiresAt = this.generateExpiryTime();     
        token.usrId = this.meta.usrId;
        token.usrType = this.meta.usrType;

        this.saveToken(token);

        Variant tokenAsVariant = token;
        eventMessage["token"] = tokenAsVariant;        
    }

    private string generateToken(StringsHelper stringsHelper)
    {
        return stringsHelper.generateRandomString(30);        
    }

    private long currentUnixTime()
    {
        return Clock.currTime().toUnixTime();
    }    

    private long generateExpiryTime() {
        return this.currentUnixTime() + this.tokenTimeoutInSeconds;
    }    

    private void saveToken(ref Token token)
    {
        string sql = "
                INSERT INTO token(`tokenCode`, `prefix`, `expiresAt`, `ipAddress`, `userAgent`, `usrId`, `usrType`) 
                VALUES(?, ?, ?, ?, ?, ?, ?);
            "; 

        this.relationalDb.execute(sql, variantArray(
            token.tokenCode,
            token.prefix,
            token.expiresAt,
            token.ipAddress,
            token.userAgent,
            token.usrId,
            token.usrType
        ));
    }   
}