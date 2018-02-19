// Third party imports
import vibe.vibe;
import helpers.commandHelper;

// Our imports
import appconfig;
import api.handlers.all;

import std.stdio;
import entity.authenticateduser;
import container;

import handlers.pagehandler;

// Global objects
AppConfig appConfig;

void main()
{
	auto commandHelper = new CommandHelper();
    appConfig = commandHelper.loadAppConfig();

    auto settings = new HTTPServerSettings;
	settings.port = appConfig.getServerListenPort();
    settings.bindAddresses = ["::1", "127.0.0.1", appConfig.getServerListenIP()];
	settings.errorPageHandler = commandHelper.makeCustomErrorHandler();

	auto router = new URLRouter;

    // Setup router to service static files
    router.get("*", serveStaticFiles("public"));

    // Add REST API routes
    router
	    .registerRestInterface(new AuthHandler(appConfig))
        .registerRestInterface(new ProfileHandler(appConfig))
        .registerRestInterface(new MiscHandler(appConfig));

    // Add HTML page routes
    router
        .get("/login", (HTTPServerRequest req, HTTPServerResponse res) @safe {
            auto pageHandler = new PageHandler(req, res, appConfig);
            pageHandler.login();
        })
        .get("/", (HTTPServerRequest req, HTTPServerResponse res) @safe {
            auto pageHandler = new PageHandler(req, res, appConfig);
            pageHandler.home();
        })
        .get("/logout", (HTTPServerRequest req, HTTPServerResponse res) @safe {
            res.setCookie("tokenCode", null);
            res.redirect("/");
        })
        .get("/register", (HTTPServerRequest req, HTTPServerResponse res) @safe {
            auto pageHandler = new PageHandler(req, res, appConfig);
            pageHandler.register();
        })
        .get("/password_reset", (HTTPServerRequest req, HTTPServerResponse res) @safe {
            auto pageHandler = new PageHandler(req, res, appConfig);
            pageHandler.login();
        })
        .get("/my_profile", (HTTPServerRequest req, HTTPServerResponse res) @safe {
            auto pageHandler = new PageHandler(req, res, appConfig);
            pageHandler.profile();
        })              
    ;        

	listenHTTP(settings, router);
	runApplication();

    logInfo(format("Server listening at http://%s:%d/", appConfig.getServerListenIP(), appConfig.getServerListenPort()));
}