module api.handlers.abstracthandler;

import std.exception;
import vibe.vibe;
import std.algorithm;
import std.stdio;

import appconfig;
import commands.extendtoken;
import commandrouter;
import container;
import command.decisionmakerinterface;
import decisionmakers.extendtoken;
import entity.requestinfo;
import entity.sessioninfo;
import command.all;
import eventstore.all;
public import entity.user;

abstract class AbstractHandler
{
	private Container container;
	private AppConfig appConfig;

    this(AppConfig appConfig) @safe
    {
        this.appConfig = appConfig;
    }

    protected AppConfig _appConfig() @property @safe
    {
        return this.appConfig;
    }

    protected Container _container() @property @safe
    {
        if (!this.container) {
            this.container = Container.createFromAppConfig(this.appConfig);
        }

        return this.container;
    } 
    
    protected void checkToken(Container container, ref RequestInfo requestInfo, uint[] allowedUserTypes = [UserType.GENERAL, UserType.ADMIN]) @safe
	{
		enforce(requestInfo.tokenCode, "Missing or Invalid 'Token-Code' header - A valid Token Code must be supplied as a HTTP Header for this request");
		
		ExtendTokenFacts facts;
		facts.tokenCode = requestInfo.tokenCode;
		facts.userAgent = requestInfo.userAgent;
		facts.ipAddress = requestInfo.ipAddress;		

		// See if the token is in redis.  If it is, use the details directly from redis.
		auto redisDatabase = container.getRedisDatabase();
		if(redisDatabase.exists(requestInfo.tokenCode)) {
			Json sessionInfoJson = parseJsonString(redisDatabase.get(requestInfo.tokenCode));
			const SessionInfo sessionInfo = deserializeJson!SessionInfo(sessionInfoJson);

			facts.tokenExists = true;
			facts.tokenExpiry = sessionInfo.expiresAt;
			facts.tokenUserAgent = sessionInfo.userAgent;
			facts.tokenIPAddress = sessionInfo.ipAddress;
            facts.usrType = sessionInfo.usrType;

			requestInfo.prefix = sessionInfo.prefix;
			requestInfo.usrId = sessionInfo.usrId;	
            requestInfo.usrType = sessionInfo.usrType;
		} else {
			// Grab the token from MySQL
			auto tokenQuery = container.getQueryFactory().createTokenQuery();
			
			facts.tokenExists = tokenQuery.existsByCode(requestInfo.tokenCode);

			if (facts.tokenExists) {
				const auto token = tokenQuery.getByCode(requestInfo.tokenCode);
				facts.tokenExpiry = token.expiresAt;
				facts.tokenUserAgent = token.userAgent;
				facts.tokenIPAddress = token.ipAddress;
                facts.usrType = token.usrType;
				requestInfo.prefix = token.prefix;
				requestInfo.usrId = token.usrId;
                requestInfo.usrType = token.usrType;
			}
		}

        if(!allowedUserTypes.canFind(requestInfo.usrType)) {
            throw new HTTPStatusException(401, "Sorry, you are not authorised to perform this action");
        }

		facts.prefix = requestInfo.prefix;
		facts.usrId = requestInfo.usrId;

		auto decisionMaker = new ExtendTokenDM(facts);

        auto commandList = new EventListWithStorage(this._container.getEventStore());
        decisionMaker.issueCommands(commandList);
        decisionMaker.executeCommands(this._container, commandList);
	}
}