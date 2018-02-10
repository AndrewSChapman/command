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
import command.all;
import eventstore.all;
import helpers.validatorHelper;

import api.interfaces.profileapi;

import query.user;
import query.prefix;

import decisionmakers.updateuser;
import commands.updateuser;

import decisionmakers.changepassword;
import commands.changepassword;

import decisionmakers.changeemail;
import commands.changeemail;

import decisionmakers.adduser;
import commands.adduser;

import decisionmakers.deleteuser;
import commands.deleteuser;

class ProfileHandler : AbstractHandler,ProfileAPI
{
    this(AppConfig appConfig)
	{
    	super(appConfig);
    }

	// POST Update Profile
	@property void profile(UpdateProfileRequestMeta updateProfile, RequestInfo requestInfo) @safe
	{	
		try {
			this.checkToken(this._container, requestInfo);

			UpdateUserFacts facts;
			facts.userLoggedIn = true;
			facts.usrId = requestInfo.usrId;
            facts.usrType = cast(UserType)requestInfo.usrType;
			facts.firstName = updateProfile.firstName;
			facts.lastName = updateProfile.lastName;

			auto decisionMaker = new UpdateUserDM(facts);		

            auto commandBus = new CommandBusWithStorage(this._container.getEventStore());
            decisionMaker.issueCommands(commandBus);
            decisionMaker.executeCommands(this._container, commandBus);            
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
			ChangePasswordFacts facts;
			facts.userLoggedIn = true;
			
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
			facts.existingPasswordIsCorrect = passwordHelper.VerifyBcryptHash(user.passwordHash, changePassword.existingPassword);
			
			// Ensure supplied new passwords match each other
			facts.repeatedPasswordMatches = changePassword.newPassword == changePassword.newPasswordRepeated;

			// Pass in the data the command needs to do its thing.
			facts.usrId = requestInfo.usrId;			
			facts.password = changePassword.newPassword;

			auto decisionMaker = new ChangePasswordDM(facts);		

            auto commandBus = new CommandBusWithStorage(this._container.getEventStore());
            decisionMaker.issueCommands(commandBus);
            decisionMaker.executeCommands(this._container, commandBus);            
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
			ChangeEmailFacts facts;
			facts.userLoggedIn = true;
			
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
			facts.emailAddressIsDifferentToCurrent = user.email.toLower() != changeEmail.emailAddress.toLower();
			facts.emailAddressLooksValid = validatorHelper.validateEmailAddress(changeEmail.emailAddress);
			facts.emailAddressIsUnique = (userQuery.userExistsByEmail(changeEmail.emailAddress) == false);
			facts.emailAddress = changeEmail.emailAddress;	
			facts.usrId = requestInfo.usrId;		

			auto decisionMaker = new ChangeEmailDM(facts);		

            auto commandBus = new CommandBusWithStorage(this._container.getEventStore());
            decisionMaker.issueCommands(commandBus);
            decisionMaker.executeCommands(this._container, commandBus);            
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

    // GET profile By Email
	@property Profile profileByEmail(RequestInfo requestInfo, string email) @safe
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
            profile.usrType = user.usrType;
		}

		// No matching user, return a blank profile
		return profile;
    }

    // GET profile By Id
	@property Profile userById(RequestInfo requestInfo, uint id) @safe
	{
		this.checkToken(this._container, requestInfo, [UserType.ADMIN]);

		auto userQuery = this._container.getQueryFactory().createUserQuery();

		Profile profile;

		// If a user with this email address exists, return the profile information.
		if (!userQuery.userExistsById(id)) {
			throw new Exception("There is no user with this id");
		}

        return userQuery.getProfileByUserId(id);
	}

    // GET List / Search for Users
    Profile[] users(RequestInfo requestInfo, uint pageNo = 0, uint usrType = 999, string searchTerm = "", bool showDeleted = false) @safe
    {
        this.checkToken(this._container, requestInfo, [UserType.ADMIN]);

        auto userQuery = this._container.getQueryFactory().createUserQuery();

        Profile[] results = userQuery.getList(pageNo, usrType, searchTerm, showDeleted);

        return results;
    }

    // POST ADD USER (ADMIN)
    @property Profile user(AddNewUserRequestMetadata userDetails, RequestInfo requestInfo) @safe
    {   
        try {
            this.checkToken(this._container, requestInfo, [UserType.ADMIN]);

			auto userQuery = new UserQuery(this._container.getRelationalDb());
			auto prefixQuery = new PrefixQuery(this._container.getRelationalDb());

			// Determine the factors that the command needs in order to make decisions.
			AddUserFacts facts;
			facts.usernameAlreadyExists = userQuery.userExistsByUsername(userDetails.username);
            facts.emailAlreadyExists = userQuery.userExistsByEmail(userDetails.email);
            facts.usrType = userDetails.usrType;
            facts.username = userDetails.username;
            facts.userFirstName = userDetails.userFirstName;
            facts.userLastName = userDetails.userLastName;
            facts.email = userDetails.email;
            facts.password = userDetails.password;

			auto decisionMaker = new AddUserDM(facts);

            auto commandBus = new CommandBusWithStorage(this._container.getEventStore());
            decisionMaker.issueCommands(commandBus);
            decisionMaker.executeCommands(this._container, commandBus);            

            ulong usrId = decisionMaker.getNewUsrId();

            return userQuery.getProfileByUserId(usrId);

        } catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}
    }

    // PUT Update user
    @property void updateUser(UpdateUserRequestMeta userDetails, RequestInfo requestInfo) @safe
    {
		try {
			this.checkToken(this._container, requestInfo, [UserType.ADMIN]);

			UpdateUserFacts facts;
			facts.userLoggedIn = true;
			facts.usrId = userDetails.usrId;
            facts.usrType = cast(UserType)userDetails.usrType;
			facts.firstName = userDetails.firstName;
			facts.lastName = userDetails.lastName;

			auto decisionMaker = new UpdateUserDM(facts);		

            auto commandBus = new CommandBusWithStorage(this._container.getEventStore());
            decisionMaker.issueCommands(commandBus);
            decisionMaker.executeCommands(this._container, commandBus);      
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}        
    }

    // DELETE Delete user (ADMIN ONLY)
    @property void user(DeleteUserRequestMeta deleteUser, RequestInfo requestInfo) @safe
    {
        try {
            this.checkToken(this._container, requestInfo, [UserType.ADMIN]);

            auto userQuery = new UserQuery(this._container.getRelationalDb());

            DeleteUserFacts facts;
            facts.userToDeleteExists = userQuery.userExistsById(deleteUser.usrId);
            facts.loggedInUsrType = cast(UserType)requestInfo.usrType;
            facts.userToDeleteId = deleteUser.usrId;
            facts.loggedInUserId = requestInfo.usrId;
            facts.hardDelete = deleteUser.hardDelete;

            if (facts.userToDeleteExists) {
                auto user = userQuery.getUserById(deleteUser.usrId);
                facts.userToDeleteAlreadyDeleted = user.deleted == 1;
                facts.usrToDeleteUsrType = cast(UserType)user.usrType;
            }

			auto decisionMaker = new DeleteUserDM(facts);	

            auto commandBus = new CommandBusWithStorage(this._container.getEventStore());
            decisionMaker.issueCommands(commandBus);
            decisionMaker.executeCommands(this._container, commandBus);
        } catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}
    }

    // DELETE logged in user account
    @property void deleteMyAccount(RequestInfo requestInfo) @safe
    {
        try {
            this.checkToken(this._container, requestInfo, [UserType.GENERAL]);
            auto userQuery = new UserQuery(this._container.getRelationalDb());

            DeleteUserFacts facts;
            facts.userToDeleteExists = userQuery.userExistsById(requestInfo.usrId);
            facts.loggedInUsrType = cast(UserType)requestInfo.usrType;
            facts.userToDeleteId = requestInfo.usrId;
            facts.loggedInUserId = requestInfo.usrId;
            facts.tokenCode = requestInfo.tokenCode;
            facts.hardDelete = false;

            if (facts.userToDeleteExists) {
                auto user = userQuery.getUserById(requestInfo.usrId);
                facts.userToDeleteAlreadyDeleted = user.deleted == 1;
                facts.usrToDeleteUsrType = cast(UserType)user.usrType;
            }

			auto decisionMaker = new DeleteUserDM(facts);	

            auto commandBus = new CommandBusWithStorage(this._container.getEventStore());
            decisionMaker.issueCommands(commandBus);
            decisionMaker.executeCommands(this._container, commandBus);                  
        } catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}
    }
}