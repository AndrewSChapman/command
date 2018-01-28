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
import decisionmakers.decisionmakerinterface;
import decisionmakers.registeruser;
import decisionmakers.login;
import decisionmakers.createprefix;
import decisionmakers.passwordresetinitiate;
import decisionmakers.passwordresetcomplete;

import entity.all;
import eventmanager.all;
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
import appconfig;
import api.requestMetadata;

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

        // Pass the facts to the decision maker
		auto decisionMaker = new CreatePrefixDM(facts);	
		auto router = this.executeAndAwaitCommands(this._container, decisionMaker);		

		Prefix prefix;
		prefix.prefix = router.getEventMessage!string("prefixCode");
		return prefix;
	}

	@property void register(RegisterNewUserRequestMetadata requestMetadata) @safe
	{
		try {
			auto userQuery = new UserQuery(this._container.getRelationalDb());
			auto prefixQuery = new PrefixQuery(this._container.getRelationalDb());

			// Determine the factors that the command needs in order to make decisions.
			RegisterNewUserFacts facts;
			facts.userAlreadyExists = userQuery.userExistsByEmail(requestMetadata.email);
            facts.userFirstName = requestMetadata.userFirstName;
            facts.userLastName = requestMetadata.userLastName;
            facts.email = requestMetadata.email;
            facts.password = requestMetadata.password;

			auto decisionMaker = new RegisterUserDM(facts);
			this.executeCommands(this._container, decisionMaker);
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
			LoginDMMeta LoginDMMeta;
			LoginFactors factors;
			factors.prefixExists = prefixQuery.exists(meta.prefix);
			factors.userExists = userQuery.userExistsByEmail(meta.email);

			if (factors.prefixExists) {
				Prefix prefix = prefixQuery.getPrefix(meta.prefix);
				LoginDMMeta.prefix = prefix.prefix;
				if ((prefix.usrId > 0) && (factors.userExists)) {
					auto user = userQuery.getUserByEmail(meta.email);
					if (user.usrId == prefix.usrId) {
						factors.prefixAssignedToUser = true;
					}
				} else {
					factors.prefixNotAssigned = true;
				}	
			}

			if (factors.userExists) {
				auto user = userQuery.getUserByEmail(meta.email);
				auto passwordHelper = new PasswordHelper();
				factors.passwordCorrect = passwordHelper.VerifyBcryptHash(user.passwordHash, meta.password);
				LoginDMMeta.usrId = user.usrId;
			}

			LoginDMMeta.userAgent = requestInfo.headers.get("User-Agent", "");
			LoginDMMeta.ipAddress = requestInfo.ipAddress;

			auto command = new LoginDM(LoginDMMeta, factors);		
			auto director = this.executeAndAwaitCommands(this._container, command);	

			token = director.getEventMessage!Token("token");
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}

		return token;
	}	

	@property void passwordReset(PasswordResetRequestMeta passwordResetRequest) @safe
	{
		try {
			PasswordResetInitiateDMMeta commandMeta;
			PasswordResetInitiateFactors factors;

			auto userQuery = new UserQuery(this._container.getRelationalDb());
			factors.userExists = userQuery.userExistsByEmail(passwordResetRequest.emailAddress);

			if (factors.userExists) {
				auto user = userQuery.getUserByEmail(passwordResetRequest.emailAddress);
				commandMeta.usrId = user.usrId;
				commandMeta.userFirstName = user.firstName;
				commandMeta.userLastName = user.lastName;
				commandMeta.userEmail = user.email;
				commandMeta.newPassword = passwordResetRequest.newPassword;

				auto passwordHelper = new PasswordHelper();
				factors.newPasswordValidated = 
					((passwordResetRequest.newPassword == passwordResetRequest.newPasswordRepeated) &&
					passwordHelper.passwordPassesSecurityPolicy(passwordResetRequest.newPassword));
			}
			
			auto command = new PasswordResetInitiateDM(commandMeta, factors);		
			auto router = this.executeAndAwaitCommands(this._container, command);			
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}		
	}

	@property void passwordResetComplete(PasswordResetCompleteRequestMeta passwordResetCompleteRequest) @safe
	{
		try {
			PasswordResetCompleteDMMeta commandMeta;
			PasswordResetCompleteFactors factors;

			auto userQuery = new UserQuery(this._container.getRelationalDb());
			factors.userExists = userQuery.userExistsByEmail(passwordResetCompleteRequest.emailAddress);

			if (factors.userExists) {
				auto const user = userQuery.getUserByEmail(passwordResetCompleteRequest.emailAddress);
				commandMeta.usrId = user.usrId;

				factors.newPasswordPinValidated = (passwordResetCompleteRequest.newPasswordPin == user.newPasswordPin);

				// @todo - Implement pin expiry
				factors.pinHasNotExpired = true;
			}
			
			auto command = new PasswordResetCompleteDM(commandMeta, factors);		
			this.executeCommands(this._container, command);			
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}		
	}    
}