module api.interfaces.authapi;

import api.requestinterface.common;
import entity.all;

import decisionmakers.registeruser;
import decisionmakers.login;
import decisionmakers.passwordresetinitiate;
import decisionmakers.passwordresetcomplete;

interface AuthAPI
{
	@method(HTTPMethod.GET)
	@before!getRequestInfo("requestInfo")
	@property Prefix prefix(RequestInfo requestInfo);

	@method(HTTPMethod.POST)
	@property void register(RegisterUserDMMeta register);	

	@method(HTTPMethod.POST)
	@before!getRequestInfo("requestInfo")
	@property Token login(LoginRequestMeta login, RequestInfo requestInfo);

	@method(HTTPMethod.POST)
	@property void passwordReset(PasswordResetRequestMeta passwordResetRequest);

	@method(HTTPMethod.POST)
	@property void passwordResetComplete(PasswordResetCompleteRequestMeta passwordResetCompleteRequest);		
}