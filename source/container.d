module container;

import mysql;
import appconfig;
import vibe.vibe;
import helpers.helperfactory;
import query.factory;
import relationaldb.all;
import eventstore.all;
import entity.smtpsettings;

class Container
{
    private QueryFactory queryFactory;
    private HelperFactory helperFactory;
    private RelationalDBInterface relationalDb;
    private MongoClient mongoClient;
    private AppConfig appConfig;
    private RedisDatabase redisDatabase;
    private const SMTPSettings smtpSettings;
    private Connection connection;

    bool versionIsRelease;

    private string mongoDBName;
    private string mongoDBEventCollectionName;

    this(
        Connection connection,
        MongoClient mongoClient,
        RedisDatabase redisDatabase,
        ref AppConfig appConfig,
        bool versionIsRelease,
        ref in SMTPSettings smtpSettings
    ) @safe {
        this.appConfig = appConfig;
        this.versionIsRelease = versionIsRelease;
        this.smtpSettings = smtpSettings;       
        this.connection = connection;
        this.relationalDb = new MySQLRelationalDB(connection);
        this.mongoClient = mongoClient;
        this.redisDatabase = redisDatabase;
    }

    public RelationalDBInterface getRelationalDb() @safe
    {
        return this.relationalDb;
    }

    public string getMongoDBName() @safe
    {
        return this.appConfig.getMongoDbName();
    }

    public string getMongoDBEventCollectionName() @safe
    {
        return this.appConfig.getMongoCollectionName();
    }    

    public MongoClient getMongoClient() @safe
    {
        return this.mongoClient;
    }

    public RedisDatabase getRedisDatabase() @safe
    {
        return this.redisDatabase;
    }      

    public QueryFactory getQueryFactory() @safe
    {
        if (this.queryFactory is null) {
            this.queryFactory = new QueryFactory(this.relationalDb);
        }

        return this.queryFactory;
    }

    public HelperFactory getHelperFactory() @safe
    {
        if (this.helperFactory is null) {
            this.helperFactory = new HelperFactory(this.getQueryFactory());
        }

        return this.helperFactory;
    }

    public EventStoreInterface getEventStore() @safe
    {
        if (this.appConfig.getEventStoreEngineType == EventStoreEngineType.MySQL) {
            return new RelationalEventStore(this.relationalDb);    
        } else {
            return new MongoEventStore(this.mongoClient, this.getMongoDBName() ~ "." ~
                this.getMongoDBEventCollectionName());
        }
    }

    public SMTPSettings getSMTPSettings() @safe
    {
        return this.smtpSettings;
    }

    public static Container createFromAppConfig(AppConfig appConfig) @trusted
    {
        // Build SMTP Settings
        SMTPSettings smtpSettings;
        smtpSettings.host = appConfig.getSMTPHost();
        smtpSettings.port = appConfig.getSMTPPort();
        smtpSettings.username = appConfig.getSMTPUsername();
        smtpSettings.password = appConfig.getSMTPPassword();

        // Connect to MySQL
        string dbConnectionStr = format(
			"host=%s;port=%d;user=%s;pwd=%s;db=%s",
			appConfig.getRelationalDbHost(),
			appConfig.getRelationalDbPort(),
			appConfig.getRelationalDbUsername(),
			appConfig.getRelationalDbPassword(),
			appConfig.getRelationalDbName()
		);       

        auto connection = new Connection(dbConnectionStr);

        // Connect to Mongo
        auto mongoClient = connectMongoDB(appConfig.getMongoHost());

        // Connect to Redis
		auto redisClient = connectRedis (appConfig.getRedisHost(), appConfig.getRedisPort());
		auto redisDatabase = redisClient.getDatabase(appConfig.getRedisDbNo());

        bool versionIsRelease = true;
        debug {
            versionIsRelease = false;
        }

        return new Container(connection, mongoClient, redisDatabase, appConfig, versionIsRelease, smtpSettings);
    }
}