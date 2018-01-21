module appconfig;

class AppConfig
{
    // Server
    private string serverListenIP;
    private ushort serverListenPort;
    
    // Session
    private ulong sessionTimeout;

    // MySQL
    private string relationalDbHost;
    private ushort relationalDbPort;
    private string relationalDbUsername;
    private string relationalDbPassword;
    private string relationalDbName;

    // Mongo
    private string mongoHost;
    private string mongoDbName;
    private string mongoCollectionName;

    // Redis
    private string redisHost;
    private ushort redisPort;
    private uint redisDbNo;

    // SMTP
    private string SMTPHost;
    private ushort SMTPPort;
    private string SMTPUsername;
    private string SMTPPassword;

    this(
        string serverListenIP,
        ushort serverListenPort,
        ulong sessionTimeout,
        string relationalDbHost,
        ushort relationalDbPort,
        string relationalDbUsername,
        string relationalDbPassword,
        string relationalDbName,
        string mongoHost,
        string mongoDbName,
        string mongoCollectionName,
        string redisHost,
        ushort redisPort,
        uint redisDbNo,
        string SMTPHost,
        ushort SMTPPort,
        string SMTPUsername,
        string SMTPPassword
    ) {
        // Server
        this.serverListenIP = serverListenIP;
        this.serverListenPort = serverListenPort;
        
        // Session
        this.sessionTimeout = sessionTimeout;

        // MySQL
        this.relationalDbHost = relationalDbHost;
        this.relationalDbPort = relationalDbPort;
        this.relationalDbUsername = relationalDbUsername;
        this.relationalDbPassword = relationalDbPassword;
        this.relationalDbName = relationalDbName;

        // Mongo
        this.mongoHost = mongoHost;
        this.mongoDbName = mongoDbName;
        this.mongoCollectionName = mongoCollectionName;      

        // Redis
        this.redisHost = redisHost;
        this.redisPort = redisPort;
        this.redisDbNo = redisDbNo;   

        // SMTP
        this.SMTPHost = SMTPHost;
        this.SMTPPort = SMTPPort;
        this.SMTPUsername = SMTPUsername;
        this.SMTPPassword = SMTPPassword;             
    }
       
    // Server
    public string getServerListenIP()
    {
        return this.serverListenIP;
    }

    public ushort getServerListenPort()
    {
        return this.serverListenPort;
    }    
    
    // Session
    public ulong getSessionTimeout()
    {
        return this.sessionTimeout;
    }

    // MySQL
    public string getRelationalDbHost()
    {
        return this.relationalDbHost;
    }

    public ushort getRelationalDbPort()
    {
        return this.relationalDbPort;
    }

    public string getRelationalDbUsername()
    {
        return this.relationalDbUsername;
    }

    public string getRelationalDbPassword()
    {
        return this.relationalDbPassword;
    }

    public string getRelationalDbName()
    {
        return this.relationalDbName;
    }  

    // Mongo
    public string getMongoHost()
    {
        return this.mongoHost;
    }

    public string getMongoDbName()
    {
        return this.mongoDbName;
    }

    public string getMongoCollectionName()
    {
        return this.mongoCollectionName;
    }   

    // Redis
    public string getRedisHost()
    {
        return this.redisHost;
    }    

    public ushort getRedisPort()
    {
        return this.redisPort;
    } 

    public uint getRedisDbNo()
    {
        return this.redisDbNo;
    }

    // SMTP
    public string getSMTPHost()
    {
        return this.SMTPHost;
    }

    public ushort getSMTPPort()
    {
        return this.SMTPPort;
    }

    public string getSMTPUsername()
    {
        return this.SMTPUsername;
    }

    public string getSMTPPassword()
    {
        return this.SMTPPassword;
    }         
}

unittest {
    string serverListenIP = "123.123.123.123";
    ushort serverListenPort = 3210;
    
    long sessionTimeout = 86400;

    string relationalDbHost = "127.0.0.1";
    ushort relationalDbPort = 3306;
    string relationalDbUsername = "MyUsername";
    string relationalDbPassword = "Secret";
    string relationalDbName = "CloudpadDB";   

    string mongoHost = "MongoHost";
    string mongoDbName = "cloudpadMongoDB";
    string mongoCollectionName = "events";    

    string redisHost = "RedisHost";
    ushort redisPort = 1234;
    uint redisDbNo = 1;

    string SMTPHost = "SMTPHost";
    ushort SMTPPort = 5555;
    string SMTPUsername = "SMTPUsername";
    string SMTPPassword = "SMTPPassword";

    auto config = new AppConfig(
        serverListenIP,
        serverListenPort,
        sessionTimeout,
        relationalDbHost,
        relationalDbPort,
        relationalDbUsername,
        relationalDbPassword,
        relationalDbName,
        mongoHost,
        mongoDbName,
        mongoCollectionName,
        redisHost,
        redisPort,
        redisDbNo,
        SMTPHost,
        SMTPPort,
        SMTPUsername,
        SMTPPassword
    );

    assert(config.getServerListenIP() == serverListenIP);
    assert(config.getServerListenPort() == serverListenPort);
    assert(config.getSessionTimeout() == sessionTimeout);
    assert(config.getRelationalDbHost() == relationalDbHost);
    assert(config.getRelationalDbPort() == relationalDbPort);
    assert(config.getRelationalDbUsername() == relationalDbUsername);
    assert(config.getRelationalDbName() == relationalDbName);
    assert(config.getMongoHost() == mongoHost);
    assert(config.getMongoDbName() == mongoDbName);
    assert(config.getMongoCollectionName() == mongoCollectionName);
    assert(config.getRedisHost() == redisHost);
    assert(config.getRedisPort() == redisPort);
    assert(config.getRedisDbNo() == redisDbNo);   
    assert(config.getSMTPHost() == SMTPHost);
    assert(config.getSMTPPort() == SMTPPort);
    assert(config.getSMTPUsername() == SMTPUsername);
    assert(config.getSMTPPassword() == SMTPPassword);     
}