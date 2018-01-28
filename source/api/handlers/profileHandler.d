module api.handlers.profilehandler;

import std.stdio;
import std.conv;
import std.string;
import std.exception;
import std.ascii;

import vibe.vibe;
import mysql;
import vibe.vibe;

import api.handlers.abstracthandler;
import api.requestMetadata;
import appconfig;
import container;
import entity.all;
import eventmanager.all;
import eventstore.all;
import helpers.validatorHelper;

import api.interfaces.profileapi;

import decisionmakers.updateuser;
import commands.updateuser;

import decisionmakers.changepassword;
import commands.changepassword;

import decisionmakers.changeemail;
import commands.changeemail;

class ProfileHandler : AbstractHandler,ProfileAPI
{
    this(AppConfig appConfig)
	{
    	super(appConfig);
    }

	// POST Update Profile
	@property void profile(UpdateUserRequestMeta updateProfile, RequestInfo requestInfo) @safe
	{	
		try {
			this.checkToken(this._container, requestInfo);

			UpdateUserFacts facts;
			facts.userLoggedIn = true;
			facts.usrId = requestInfo.usrId;
			facts.firstName = updateProfile.firstName;
			facts.lastName = updateProfile.lastName;

			auto decisionMaker = new UpdateUserDM(facts);		
			this.executeCommands(this._container, decisionMaker);		
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}
	}

	// POST Change Password
	@property void changePassword(ChangePasswordRequestMeta changePassword, RequestInfo requestInfo) @safe
	{	
		try {
			this.checkToken(this._container, requestInfo);

			// If we get this far user has logged in and the id is in the requestInfo
			ChangePasswordFactors factors;
			factors.userLoggedIn = true;
			
			// Get the helpers and queries we need.
			auto validatorHelper = this._container.getHelperFactory().createValidatorHelper();
			auto stringsHelper = this._container.getHelperFactory().createStringsHelper();
			auto passwordHelper = this._container.getHelperFactory().createPasswordHelper();
			auto userQuery = this._container.getQueryFactory().createUserQuery();

			// Ensure all required fields have values in the metadata struct
			string[] requiredFields = ["existingPassword", "newPassword", "newPasswordRepeated"];

			const string[] missingFields = validatorHelper.enforceRequiredFields!ChangePasswordRequestMeta(changePassword, requiredFields);

			if (missingFields.length > 0) {
				throw new ValidationException("The following fields are missing: " ~ stringsHelper.arrayToString!string(missingFields));
			}
			
			// Load the used ensure the existing password entered by the client matches the existing password we have on required.
			const auto user = userQuery.getUserById(requestInfo.usrId);
			factors.existingPasswordIsCorrect = passwordHelper.VerifyBcryptHash(user.passwordHash, changePassword.existingPassword);
			
			// Ensure supplied new passwords match each other
			factors.repeatedPasswordMatches = changePassword.newPassword == changePassword.newPasswordRepeated;
			factors.newPasswordIsStrong = passwordHelper.passwordPassesSecurityPolicy(changePassword.newPassword);

			// Pass in the data the command needs to do its thing.
			ChangePasswordMeta changePasswordMeta;
			changePasswordMeta.usrId = requestInfo.usrId;			
			changePasswordMeta.password = changePassword.newPassword;

			auto decisionMaker = new ChangePasswordDM(changePasswordMeta, factors);		
			this.executeCommands(this._container, decisionMaker);	
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}
	}

	// POST Change Email
	@property void changeEmail(ChangeEmailRequestMeta changeEmail, RequestInfo requestInfo) @safe
	{	
		try {
			this.checkToken(this._container, requestInfo);

			// If we get this far user has logged in and the id is in the requestInfo
			ChangeEmailFactors factors;
			factors.userLoggedIn = true;
			
			// Get the helpers and queries we need.
			auto validatorHelper = this._container.getHelperFactory().createValidatorHelper();
			auto stringsHelper = this._container.getHelperFactory().createStringsHelper();
			auto passwordHelper = this._container.getHelperFactory().createPasswordHelper();
			auto userQuery = this._container.getQueryFactory().createUserQuery();

			// Ensure all required fields have values in the metadata struct
			string[] requiredFields = ["emailAddress"];

			const string[] missingFields = validatorHelper.enforceRequiredFields!ChangeEmailRequestMeta(changeEmail, requiredFields);

			if (missingFields.length > 0) {
				throw new ValidationException("The following fields are missing: " ~ stringsHelper.arrayToString!string(missingFields));
			}
			
			const auto user = userQuery.getUserById(requestInfo.usrId);
			factors.emailAddressIsDifferentToCurrent = user.email.toLower() != changeEmail.emailAddress.toLower();
			factors.emailAddressLooksValid = validatorHelper.validateEmailAddress(changeEmail.emailAddress);
			factors.emailAddressIsUnique = (userQuery.userExistsByEmail(changeEmail.emailAddress) == false);

			// Pass in the data the command needs to do its thing.
			ChangeEmailMeta changeEmailMeta;
			changeEmailMeta.emailAddress = changeEmail.emailAddress;	
			changeEmailMeta.usrId = requestInfo.usrId;		

			auto decisionMaker = new ChangeEmailDM(changeEmailMeta, factors);		
			this.executeCommands(this._container, decisionMaker);	
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}
	}

	// GET profile
	@property Profile profile(RequestInfo requestInfo) @safe
	{
		this.checkToken(this._container, requestInfo);

		auto userQuery = this._container.getQueryFactory().createUserQuery();
		return userQuery.getProfileByUserId(requestInfo.usrId);
	}

	@property Profile findProfileByEmail(RequestInfo requestInfo, string email) @safe
	{
		this.checkToken(this._container, requestInfo);

		auto validatorHelper = this._container.getHelperFactory().createValidatorHelper();
		if (!validatorHelper.validateEmailAddress(email)) {
			throw new Exception("Invalid Email Address");
		}

		auto userQuery = this._container.getQueryFactory().createUserQuery();

		Profile profile;

		// If a user with this email address exists, return the profile information.
		if (userQuery.userExistsByEmail(email)) {
			auto user = userQuery.getUserByEmail(email);

			profile.email = user.email;
			profile.firstName = user.firstName;
			profile.lastName = user.lastName;
		}

		// No matching user, return a blank profile
		return profile;
	}		
}