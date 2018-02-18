module handlers.abstractpagehandler;

import vibe.vibe;
import appconfig;
import container;
import api.requestinterface.common;
import entity.requestinfo;
import entity.profile;

abstract class AbstractPageHandler
{
    private HTTPServerRequest request;
    private HTTPServerResponse response;
    private AppConfig appConfig;
    private Container container;

    this(HTTPServerRequest request, HTTPServerResponse response, AppConfig appConfig) @safe {
        this.request = request;
        this.response = response;
        this.appConfig = appConfig;
    }

    protected HTTPServerRequest _request() @property @safe
    {
        return this.request;
    }

    protected HTTPServerResponse _response() @property @safe
    {
        return this.response;
    }

    protected Container _container() @property @safe
    {
        if (!this.container) {
            this.container = Container.createFromAppConfig(this.appConfig);
        }

        return this.container;
    }

    protected AuthenticatedUser checkToken(
        uint[] allowedUserTypes = [UserType.GENERAL, UserType.ADMIN]
    ) @safe {
        AuthenticatedUser authenticatedUser;

        // If there is no tokenCode cookie present, there's ntohing to do.
        if (!("tokenCode" in this.request.cookies)) {
            return authenticatedUser;
        }

        RequestInfo requestInfo = getRequestInfo(this.request, this.response);
        requestInfo.tokenCode = this.request.cookies["tokenCode"]; 

        auto queryFactory = this._container.getQueryFactory();
        auto tokenQuery = queryFactory.createTokenQuery();

        if (!tokenQuery.existsByCode(requestInfo.tokenCode)) {
            return authenticatedUser;
        }

        auto token = tokenQuery.getByCode(requestInfo.tokenCode);

        // Token has not expired
        if (token.expiresAt <= Clock.currTime().toUnixTime()) {
            return authenticatedUser;
        }

        // Token has same IP address
        if (token.ipAddress != requestInfo.ipAddress) {
            return authenticatedUser;
        }

        // Token has same user agent
        if (token.userAgent != requestInfo.userAgent) {
            return authenticatedUser;
        }        

        auto userQuery = queryFactory.createUserQuery();
        const Profile profile = userQuery.getProfileByUserId(token.usrId);

        authenticatedUser.usrId = profile.usrId;
        authenticatedUser.username = profile.username;
        authenticatedUser.email = profile.email;
        authenticatedUser.firstName = profile.firstName;
        authenticatedUser.lastName = profile.lastName;
        authenticatedUser.usrType = profile.usrType;
        authenticatedUser.ipAddress = requestInfo.ipAddress;
        authenticatedUser.tokenCode = requestInfo.tokenCode;        

        return authenticatedUser;
    }    
}