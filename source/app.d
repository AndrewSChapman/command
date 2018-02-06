// Third party imports
import vibe.vibe;
import helpers.commandHelper;

// Our imports
import appconfig;
import api.handlers.all;

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
	router.registerRestInterface(new AuthHandler(appConfig));
    router.registerRestInterface(new ProfileHandler(appConfig));
    router.registerRestInterface(new MiscHandler(appConfig));

	listenHTTP(settings, router);
	runApplication();

    logInfo(format("Server listening at http://%s:%d/", appConfig.getServerListenIP(), appConfig.getServerListenPort()));
}