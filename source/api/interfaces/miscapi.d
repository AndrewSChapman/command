module api.interfaces.miscapi;

import api.requestinterface.common;
import api.requestMetadata;

struct PingResponse
{
    long timestamp;
}

interface MiscAPI
{
	// Update Profile (General User)
	@method(HTTPMethod.GET)
	@before!getRequestInfo("requestInfo")
	@property PingResponse ping(RequestInfo requestInfo) @safe;
}