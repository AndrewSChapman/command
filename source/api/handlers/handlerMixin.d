module api.handlermixin;

public import decisionmakers.decisionmakerinterface;
public import decisionmakers.extendtoken;
public import commands.extendtoken;

import container;

mixin template HandlerMixin(DirectorType) {
	private void checkToken(Container container, ref RequestInfo requestInfo) @safe
	{
		enforce(requestInfo.tokenCode, "Missing or Invalid 'Token-Code' header - A valid Token Code must be supplied as a HTTP Header for this request");
		
		auto eventList = new EventListWithStorage(container.getEventStore());

		ExtendTokenFactors extendTokenFactors;

		ExtendTokenCommandMeta ExtendTokenCommandMeta;
		ExtendTokenCommandMeta.tokenCode = requestInfo.tokenCode;
		ExtendTokenCommandMeta.userAgent = requestInfo.userAgent;
		ExtendTokenCommandMeta.ipAddress = requestInfo.ipAddress;		

		// See if the token is in redis.  If it is, use the details directly from redis.
		auto redisDatabase = container.getRedisDatabase();
		if(redisDatabase.exists(requestInfo.tokenCode)) {
			Json sessionInfoJson = parseJsonString(redisDatabase.get(requestInfo.tokenCode));
			const SessionInfo sessionInfo = deserializeJson!SessionInfo(sessionInfoJson);

			extendTokenFactors.tokenExists = true;
			extendTokenFactors.tokenExpiry = sessionInfo.expiresAt;
			extendTokenFactors.tokenUserAgent = sessionInfo.userAgent;
			extendTokenFactors.tokenIPAddress = sessionInfo.ipAddress;

			requestInfo.prefix = sessionInfo.prefix;
			requestInfo.usrId = sessionInfo.usrId;			
		} else {
			// Grab the token from MySQL
			auto tokenQuery = container.getQueryFactory().createTokenQuery();
			
			extendTokenFactors.tokenExists = tokenQuery.existsByCode(requestInfo.tokenCode);

			if (extendTokenFactors.tokenExists) {
				const auto token = tokenQuery.getByCode(requestInfo.tokenCode);
				extendTokenFactors.tokenExpiry = token.expiresAt;
				extendTokenFactors.tokenUserAgent = token.userAgent;
				extendTokenFactors.tokenIPAddress = token.ipAddress;

				requestInfo.prefix = token.prefix;
				requestInfo.usrId = token.usrId;
			}
		}

		ExtendTokenCommandMeta.prefix = requestInfo.prefix;
		ExtendTokenCommandMeta.usrId = requestInfo.usrId;

		auto ExtendTokenDM = new ExtendTokenDM(ExtendTokenCommandMeta, extendTokenFactors);
		ExtendTokenDM.execute(eventList);

		if (eventList.size == 0) {
			throw new Exception("Error - ExtendTokenDM raised no events");
		}

		auto dispatcher = new EventDispatcher();
		auto director = this.attachDirector(container, dispatcher);
		eventList.dispatch(dispatcher);			
	}

	private DirectorType attachDirector(Container container, ref EventDispatcher dispatcher) @safe
    {
		auto director = new DirectorType(
			container
		);

		// Attach any directors that need to listen to these events.
		dispatcher.attachListener(director);

		return director;	
	}

	private void executeCommand(Container container, DecisionMakerInterface DecisionMakerInterface) @safe
	{
		auto eventList = new EventListWithStorage(container.getEventStore());

		// Execute the decision maker - this make thrown an exception if the decision
		// maker is not happy with some of the factors or metadata.
		try {
			DecisionMakerInterface.execute(eventList);

			if (eventList.size == 0) {
				throw new Exception("Command raised no events - this should never happen");
			}	

			// Dispatch the command on separate task so we're not waiting for the result.
			auto executeTask = runTask({
				auto dispatcher = new EventDispatcher();
				auto director = this.attachDirector(container, dispatcher);
				eventList.dispatch(dispatcher);
			});
		} catch (Exception e) {
			if (eventList.size > 0) {
				// Dispatch any commands on separate task so we're not waiting for the result.
				auto executeTask = runTask({
					auto dispatcher = new EventDispatcher();
					auto director = this.attachDirector(container, dispatcher);
					eventList.dispatch(dispatcher);
				});				
			}

			throw new HTTPStatusException(400, e.msg);
		}
	}    	  
}