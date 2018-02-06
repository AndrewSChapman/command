module api.handlers.mischandler;

import mysql;
import vibe.vibe;
import std.datetime;

import api.handlers.abstracthandler;
import api.requestMetadata;
import appconfig;
import container;
import entity.all;
import command.all;
import eventstore.all;

import api.interfaces.miscapi;

class MiscHandler : AbstractHandler,MiscAPI
{
    this(AppConfig appConfig)
	{
    	super(appConfig);
    }

	// GET ping
	@property PingResponse ping(RequestInfo requestInfo) @safe
	{	
		try {
			this.checkToken(this._container, requestInfo);

            PingResponse response;
            response.timestamp = Clock.currTime().toUnixTime();
            return response;
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}
	}
}