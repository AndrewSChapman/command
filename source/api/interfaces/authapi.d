module api.interfaces.authapi;

import api.requestinterface.common;
import container;

import entity.all;
import api.requestMetadata;
import decisionmakers.registeruser;
import decisionmakers.login;
import decisionmakers.passwordresetinitiate;
import decisionmakers.passwordresetcomplete;

interface AuthAPI
{
	@method(HTTPMethod.GET)
	@before!getRequestInfo("requestInfo")
	@property Prefix prefix(RequestInfo requestInfo) @safe;

	@method(HTTPMethod.POST)
	@property void register(RegisterNewUserRequestMetadata register) @safe;	

	@method(HTTPMethod.POST)
	@before!getRequestInfo("requestInfo")
	@property Token login(LoginRequestMetadata login, RequestInfo requestInfo) @safe;

	@method(HTTPMethod.POST)
	@property void passwordReset(PasswordResetRequestMeta passwordResetRequest) @safe;

	@method(HTTPMethod.POST)
	@property void passwordResetComplete(PasswordResetCompleteRequestMeta passwordResetCompleteRequest) @safe;		
}