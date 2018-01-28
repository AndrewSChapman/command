module api.handlers.abstracthandler;

import std.exception;
import vibe.vibe;

import appconfig;
import commands.extendtoken;
import commandrouter;
import container;
import decisionmakers.decisionmakerinterface;
import decisionmakers.extendtoken;
import entity.requestinfo;
import entity.sessioninfo;
import eventmanager.all;
import eventstore.all;

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
    
    protected void checkToken(Container container, ref RequestInfo requestInfo) @safe
	{
		enforce(requestInfo.tokenCode, "Missing or Invalid 'Token-Code' header - A valid Token Code must be supplied as a HTTP Header for this request");
		
		auto eventList = new EventListWithStorage(container.getEventStore());

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

			requestInfo.prefix = sessionInfo.prefix;
			requestInfo.usrId = sessionInfo.usrId;			
		} else {
			// Grab the token from MySQL
			auto tokenQuery = container.getQueryFactory().createTokenQuery();
			
			facts.tokenExists = tokenQuery.existsByCode(requestInfo.tokenCode);

			if (facts.tokenExists) {
				const auto token = tokenQuery.getByCode(requestInfo.tokenCode);
				facts.tokenExpiry = token.expiresAt;
				facts.tokenUserAgent = token.userAgent;
				facts.tokenIPAddress = token.ipAddress;

				requestInfo.prefix = token.prefix;
				requestInfo.usrId = token.usrId;
			}
		}

		facts.prefix = requestInfo.prefix;
		facts.usrId = requestInfo.usrId;

		auto decisionMaker = new ExtendTokenDM(facts);
        this.executeAndAwaitCommands(this._container, decisionMaker);
	}

	protected CommandRouter attachCommandRouter(Container container, ref EventDispatcher dispatcher) @safe
    {
		auto router = new CommandRouter(
			container
		);

		// Attach any commandrouter that need to listen to these events.
		dispatcher.attachListener(router);

		return router;	
	}

	protected void executeCommands(Container container, DecisionMakerInterface DecisionMakerInterface) @safe
	{
		auto eventList = new EventListWithStorage(container.getEventStore());

		// Execute the decision maker - this make thrown an exception if the decision
		// maker is not happy with some of the factors or metadata.
		try {
			DecisionMakerInterface.issueCommands(eventList);

			if (eventList.size == 0) {
				throw new Exception("Decision maker issued no commands - this should never happen");
			}	

			// Dispatch the command on separate task so we're not waiting for the result.
			auto executeTask = runTask({
				auto dispatcher = new EventDispatcher();
				auto director = this.attachCommandRouter(container, dispatcher);
				eventList.dispatch(dispatcher);
			});
		} catch (Exception e) {
			if (eventList.size > 0) {
				// Dispatch any commands on separate task so we're not waiting for the result.
				auto executeTask = runTask({
					auto dispatcher = new EventDispatcher();
					auto director = this.attachCommandRouter(container, dispatcher);
					eventList.dispatch(dispatcher);
				});				
			}

			throw new HTTPStatusException(400, e.msg);
		}
	}

	protected CommandRouter executeAndAwaitCommands(Container container, DecisionMakerInterface DecisionMakerInterface) @safe
	{
		auto eventList = new EventListWithStorage(container.getEventStore());        

		DecisionMakerInterface.issueCommands(eventList);

		if (eventList.size == 0) {
			throw new Exception("Decision maker issued no commands - this should never happen");
		}

		auto dispatcher = new EventDispatcher();
		auto director = this.attachCommandRouter(container, dispatcher);
		eventList.dispatch(dispatcher);

		return director;
	}     
}