module handlers.pagehandler;

import vibe.vibe;
import handlers.abstractpagehandler;
import api.requestinterface.common;
import appconfig;
public import entity.authenticateduser;
import container;

import std.stdio;

class PageHandler : AbstractPageHandler
{
   
    this(HTTPServerRequest request, HTTPServerResponse response, AppConfig appConfig) @safe
    {
        super(request, response, appConfig);
    }

    public void login() @safe
    {
        AuthenticatedUser authUser = this.checkToken();
        if (authUser.isLoggedIn) {
            this._response.redirect("/");
            return;
        }

        render!("login.dt", authUser)(this._response);
    }

    public void home() @safe
    {
        AuthenticatedUser authUser = this.checkToken();
        render!("home.dt", authUser)(this._response);
    }

    public void register() @safe
    {
        AuthenticatedUser authUser = this.checkToken();
        if (authUser.isLoggedIn) {
            this._response.redirect("/");
            return;
        }

        render!("register.dt", authUser)(this._response);
    }

    public void passwordReset() @safe
    {
        AuthenticatedUser authUser = this.checkToken();
        if (authUser.isLoggedIn) {
            this._response.redirect("/");
            return;
        }

        render!("password_reset.dt", authUser)(this._response);
    }

    public void profile() @safe
    {
        AuthenticatedUser authUser = this.checkToken();
        if (!authUser.isLoggedIn) {
            this._response.redirect("/");
            return;
        }

        auto queryFactory = this._container.getQueryFactory();
        auto userQuery = queryFactory.createUserQuery();
        const Profile profile = userQuery.getProfileByUserId(authUser.usrId); 

        render!("profile.dt", authUser, profile)(this._response);
    }              
}