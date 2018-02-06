module api.interfaces.profileapi;

import api.requestinterface.common;
import api.requestMetadata;
import decisionmakers.updateuser;
import decisionmakers.changepassword;
import decisionmakers.changeemail;

interface ProfileAPI
{
	// Update Profile (General User)
	@method(HTTPMethod.POST)
	@before!getRequestInfo("requestInfo")
	@property void profile(UpdateProfileRequestMeta updateProfile, RequestInfo requestInfo) @safe;

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

	// Find Profile By Email
	@method(HTTPMethod.GET)
	@before!getRequestInfo("requestInfo")
	@property Profile profileByEmail(RequestInfo requestInfo, string email) @safe;

	// Find user By Id (ADMIN ONLY)
	@method(HTTPMethod.GET)
	@before!getRequestInfo("requestInfo")
	@property Profile userById(RequestInfo requestInfo, uint id) @safe;

	// List / Search for users (ADMIN ONLY)
	@method(HTTPMethod.GET)
	@before!getRequestInfo("requestInfo")
	Profile[] users(RequestInfo requestInfo, uint pageNo = 0, uint usrType = 999, string searchTerm = "", bool showDeleted=false) @safe;

	// Add new user
	@method(HTTPMethod.POST)
	@before!getRequestInfo("requestInfo")
	@property Profile user(AddNewUserRequestMetadata userDetails, RequestInfo requestInfo) @safe;

	// Update user
	@method(HTTPMethod.PUT)
	@before!getRequestInfo("requestInfo")
	@property void updateUser(UpdateUserRequestMeta userDetails, RequestInfo requestInfo) @safe;

	// DELETE user (ADMIN ONLY)
	@method(HTTPMethod.DELETE)
	@before!getRequestInfo("requestInfo")
	@property void user(DeleteUserRequestMeta deleteUser, RequestInfo requestInfo) @safe;

	// DELETE profile (Logged in user)
	@method(HTTPMethod.DELETE)
	@before!getRequestInfo("requestInfo")
	@property void deleteMyAccount(RequestInfo requestInfo) @safe;
}