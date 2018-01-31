module executors.auth.login;

import std.stdio;
import std.variant;
import std.datetime;
import core.time;

import relationaldb.all;
import commands.login;
import helpers.helperfactory;
import entity.token;

class LoginProjection
{
    // Mysql connection
    private RelationalDBInterface relationalDb;
    private LoginCommandMetadata meta;
    private HelperFactory helperFactory;
    private const uint tokenTimeoutInSeconds = 3600;

    this(
        RelationalDBInterface relationalDb,
        HelperFactory helperFactory,
        LoginCommandMetadata meta
    ) {
        this.relationalDb = relationalDb;
        this.helperFactory = helperFactory;
        this.meta = meta;
    }

    void handleEvent(ref Variant[string] eventMessage) {
        string tokenCode = this.generateToken(this.helperFactory.createStringsHelper());

        Token token;
        token.tokenCode = tokenCode;
        token.ipAddress = this.meta.ipAddress;
        token.userAgent = this.meta.userAgent;
        token.prefix = this.meta.prefix;
        token.expiresAt = this.generateExpiryTime();     
        token.usrId = this.meta.usrId;   

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
                INSERT INTO token(`tokenCode`, `prefix`, `expiresAt`, `ipAddress`, `userAgent`, `usrId`) 
                VALUES(?, ?, ?, ?, ?, ?);
            "; 

        this.relationalDb.execute(sql, variantArray(
            token.tokenCode,
            token.prefix,
            token.expiresAt,
            token.ipAddress,
            token.userAgent,
            token.usrId
        ));
    }   
}