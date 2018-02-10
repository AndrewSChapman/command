module api.handlers.authhandler;

import std.stdio;
import std.conv;
import std.string;
import std.exception;

import vibe.vibe;
import mysql;
import vibe.vibe;
import vibe.utils.dictionarylist;

import api.handlers.abstracthandler;
import command.decisionmakerinterface;
import decisionmakers.registeruser;
import decisionmakers.login;
import decisionmakers.createprefix;
import decisionmakers.passwordresetinitiate;
import decisionmakers.passwordresetcomplete;

import entity.all;
import command.all;
import eventstore.all;
import helpers.stringsHelper;
import helpers.helperfactory;

import query.user;
import query.prefix;
import query.factory;
import container;

import relationaldb.all;
import commandrouter;
import api.interfaces.all;
import api.requestMetadata;
import appconfig;

import facts.toomanyfailedlogins;


class AuthHandler : AbstractHandler,AuthAPI
{
    this(AppConfig appConfig) @safe
    {
        super(appConfig);
    }

	@property Prefix prefix(RequestInfo requestInfo) @safe
	{
		// Gather facts for the decision maker
        CreatePrefixFacts facts;
		facts.userAgent = requestInfo.headers.get("User-Agent", "");
		facts.ipAddress = requestInfo.ipAddress;
		facts.timestamp = Clock.currStdTime();

        auto commandBus = new CommandBusWithStorage(this._container.getEventStore());

        // Pass the facts to the decision maker
		auto decisionMaker = new CreatePrefixDM(facts);	

        decisionMaker.issueCommands(commandBus);
        decisionMaker.executeCommands(this._container, commandBus);

		Prefix prefix;
		prefix.prefix = decisionMaker.getPrefixCode();
		return prefix;
	}

	@property void register(RegisterNewUserRequestMetadata requestMetadata) @safe
	{
		try {
			auto userQuery = new UserQuery(this._container.getRelationalDb());
			auto prefixQuery = new PrefixQuery(this._container.getRelationalDb());

			// Determine the factors that the command needs in order to make decisions.
			RegisterNewUserFacts facts;
			facts.usernameAlreadyExists = userQuery.userExistsByUsername(requestMetadata.username);
            facts.emailAlreadyExists = userQuery.userExistsByEmail(requestMetadata.email);
            facts.username = requestMetadata.username;
            facts.userFirstName = requestMetadata.userFirstName;
            facts.userLastName = requestMetadata.userLastName;
            facts.email = requestMetadata.email;
            facts.password = requestMetadata.password;

            auto commandBus = new CommandBusWithStorage(this._container.getEventStore());
            
			auto decisionMaker = new RegisterUserDM(facts);

            decisionMaker.issueCommands(commandBus);
            decisionMaker.executeCommands(this._container, commandBus);
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}
	}

	@property Token login(LoginRequestMetadata meta, RequestInfo requestInfo) @safe
	{	
		Token token;

		try {
			auto userQuery = new UserQuery(this._container.getRelationalDb());
			auto prefixQuery = new PrefixQuery(this._container.getRelationalDb());

			// Determine the factors that the command needs in order to make decisions.
			LoginFacts facts;
			facts.prefixExists = prefixQuery.exists(meta.prefix);
			facts.userExists = userQuery.userExistsByUsername(meta.username);

            User user;

            // Load the user record if we can.
            if (facts.userExists) {
                user = userQuery.getUserByUsername(meta.username);
            }

			if (facts.prefixExists) {
				Prefix prefix = prefixQuery.getPrefix(meta.prefix);
				facts.prefix = prefix.prefix;
				if ((prefix.usrId > 0) && (facts.userExists)) {
					if (user.usrId == prefix.usrId) {
						facts.prefixAssignedToUser = true;
					}
				} else {
					facts.prefixNotAssigned = true;
				}	
			}

			if (facts.userExists) {
				auto passwordHelper = new PasswordHelper();
				facts.passwordCorrect = passwordHelper.VerifyBcryptHash(user.passwordHash, meta.password);
				facts.usrId = user.usrId;
                facts.usrType = user.usrType;
                facts.userDeleted = (user.deleted == 1);
                facts.tooManyFailedLogins = new TooManyFailedLogins(user.numLoginAttempts);
			}

			facts.userAgent = requestInfo.headers.get("User-Agent", "");
			facts.ipAddress = requestInfo.ipAddress;

			auto decisionMaker = new LoginDM(facts);

            auto commandBus = new CommandBusWithStorage(this._container.getEventStore());
            decisionMaker.issueCommands(commandBus);
            decisionMaker.executeCommands(this._container, commandBus);

			token = decisionMaker.getLoginToken();
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}

		return token;
	}	

	@property void passwordReset(PasswordResetRequestMeta passwordResetRequest) @safe
	{
		try {
			PasswordResetInitiateFacts facts;

			auto userQuery = new UserQuery(this._container.getRelationalDb());
			facts.userExists = userQuery.userExistsByUsername(passwordResetRequest.username);

			if (facts.userExists) {
				auto user = userQuery.getUserByUsername(passwordResetRequest.username);
				facts.usrId = user.usrId;
				facts.userFirstName = user.firstName;
				facts.userLastName = user.lastName;
				facts.userEmail = user.email;
				facts.newPassword = passwordResetRequest.newPassword;

				auto passwordHelper = new PasswordHelper();
				facts.newPasswordValidated = 
					((passwordResetRequest.newPassword == passwordResetRequest.newPasswordRepeated) &&
					passwordHelper.passwordPassesSecurityPolicy(passwordResetRequest.newPassword));
			}

			
			auto decisionMaker = new PasswordResetInitiateDM(facts);		

            auto commandBus = new CommandBusWithStorage(this._container.getEventStore());
            decisionMaker.issueCommands(commandBus);
            decisionMaker.executeCommands(this._container, commandBus);
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}		
	}

	@property void passwordResetComplete(PasswordResetCompleteRequestMeta passwordResetCompleteRequest) @safe
	{
		try {
			PasswordResetCompleteFacts facts;

			auto userQuery = new UserQuery(this._container.getRelationalDb());
			facts.userExists = userQuery.userExistsByEmail(passwordResetCompleteRequest.emailAddress);

			if (facts.userExists) {
				auto const user = userQuery.getUserByEmail(passwordResetCompleteRequest.emailAddress);
				facts.usrId = user.usrId;

				facts.newPasswordPinValidated = (passwordResetCompleteRequest.newPasswordPin == user.newPasswordPin);

				// @todo - Implement pin expiry
				facts.pinHasNotExpired = true;
			}
			
			auto decisionMaker = new PasswordResetCompleteDM(facts);

            auto commandBus = new CommandBusWithStorage(this._container.getEventStore());
            decisionMaker.issueCommands(commandBus);
            decisionMaker.executeCommands(this._container, commandBus);            
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}		
	}    
}