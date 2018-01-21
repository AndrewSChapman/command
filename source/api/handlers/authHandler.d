module api.handlers.authhandler;

import std.stdio;
import std.conv;
import std.string;
import std.exception;

import vibe.vibe;
import mysql;
import vibe.vibe;
import vibe.utils.dictionarylist;

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
import directors.all;
import api.interfaces.all;
import appconfig;

class AuthHandler : AuthAPI
{
	private AppConfig appConfig;

    this(AppConfig appConfig) {
		this.appConfig = appConfig;
    }

	private AuthDirector attachDirector(Container container, ref EventDispatcher dispatcher) {
		auto director = new AuthDirector(
			container
		);

		// Attach any directors that need to listen to these events.
		dispatcher.attachListener(director);	

		return director;	
	}

	private AuthDirector executeCommand(Container container, DecisionMakerInterface DecisionMakerInterface)
	{
		auto eventList = new EventListWithStorage(
			new MongoEventStore(container.getMongoClient(), this.appConfig.getMongoEventStoreName())
		);

		DecisionMakerInterface.execute(eventList);

		if (eventList.size == 0) {
			throw new Exception("Command raised no events - this should never happen");
		}

		auto dispatcher = new EventDispatcher();
		auto director = this.attachDirector(container, dispatcher);
		eventList.dispatch(dispatcher);

		return director;
	}

	@property Prefix prefix(RequestInfo requestInfo)
	{
		Container container = Container.createFromAppConfig(appConfig);

		CreatePrefixDMMeta meta;
		meta.userAgent = requestInfo.headers.get("User-Agent", "");
		meta.ipAddress = requestInfo.ipAddress;
		meta.timestamp = Clock.currStdTime();

		auto command = new CreatePrefixDM(meta);	
		auto director = this.executeCommand(container, command);		

		Prefix prefix;
		prefix.prefix = director.getEventMessage!string("prefixCode");

		return prefix;
	}

	@property void register(RegisterUserDMMeta registrationMetadata)
	{
		try {
			Container container = Container.createFromAppConfig(appConfig);

			auto userQuery = new UserQuery(container.getRelationalDb());
			auto prefixQuery = new PrefixQuery(container.getRelationalDb());

			// Determine the factors that the command needs in order to make decisions.
			RegisterNewUserFactors factors;
			factors.userExists = userQuery.userExistsByEmail(registrationMetadata.email);

			auto command = new RegisterUserDM(registrationMetadata, factors);
			this.executeCommand(container, command);	
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}
	}

	@property Token login(LoginRequestMeta meta, RequestInfo requestInfo)
	{	
		Token token;

		try {
			Container container = Container.createFromAppConfig(appConfig);
			auto userQuery = new UserQuery(container.getRelationalDb());
			auto prefixQuery = new PrefixQuery(container.getRelationalDb());

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
			auto director = this.executeCommand(container, command);	

			token = director.getEventMessage!Token("token");
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}

		return token;
	}	

	@property void passwordReset(PasswordResetRequestMeta passwordResetRequest)
	{
		try {
			Container container = Container.createFromAppConfig(appConfig);
			PasswordResetInitiateDMMeta commandMeta;
			PasswordResetInitiateFactors factors;

			auto userQuery = new UserQuery(container.getRelationalDb());
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
			auto director = this.executeCommand(container, command);			
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}		
	}

	@property void passwordResetComplete(PasswordResetCompleteRequestMeta passwordResetCompleteRequest)
	{
		try {
			Container container = Container.createFromAppConfig(appConfig);
			PasswordResetCompleteDMMeta commandMeta;
			PasswordResetCompleteFactors factors;

			auto userQuery = new UserQuery(container.getRelationalDb());
			factors.userExists = userQuery.userExistsByEmail(passwordResetCompleteRequest.emailAddress);

			if (factors.userExists) {
				auto const user = userQuery.getUserByEmail(passwordResetCompleteRequest.emailAddress);
				commandMeta.usrId = user.usrId;

				factors.newPasswordPinValidated = (passwordResetCompleteRequest.newPasswordPin == user.newPasswordPin);

				// @todo - Implement pin expiry
				factors.pinHasNotExpired = true;
			}
			
			auto command = new PasswordResetCompleteDM(commandMeta, factors);		
			this.executeCommand(container, command);			
		} catch (Exception exception) {
			throw new HTTPStatusException(400, exception.msg);
		}		
	}	
}