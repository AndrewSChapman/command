module api.interfaces.profileapi;

import api.requestinterface.common;
import api.requestMetadata;
import decisionmakers.updateuser;
import decisionmakers.changepassword;
import decisionmakers.changeemail;

interface ProfileAPI
{
	// Update Profile
	@method(HTTPMethod.POST)
	@before!getRequestInfo("requestInfo")
	@property void profile(UpdateUserRequestMeta updateProfile, RequestInfo requestInfo) @safe;

	// Change Password
	@method(HTTPMethod.POST)
	@before!getRequestInfo("requestInfo")
	@property void changePassword(ChangePasswordRequestMeta changePassword, RequestInfo requestInfo) @safe;

	// Change Email
	@method(HTTPMethod.POST)
	@before!getRequestInfo("requestInfo")
	@property void changeEmail(ChangeEmailRequestMeta changeEmail, RequestInfo requestInfo) @safe;

	// Get Profile
	@method(HTTPMethod.GET)
	@before!getRequestInfo("requestInfo")
	@property Profile profile(RequestInfo requestInfo) @safe;

	// Find Profile By Id
	@method(HTTPMethod.GET)
	@before!getRequestInfo("requestInfo")
	@property Profile findUserById(RequestInfo requestInfo, uint id) @safe;    	

	// Find Profile By Email
	@method(HTTPMethod.GET)
	@before!getRequestInfo("requestInfo")
	@property Profile findProfileByEmail(RequestInfo requestInfo, string email) @safe;
}