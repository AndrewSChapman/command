module directors.auth;

import std.stdio;
import std.variant;

import eventmanager.all;
import relationaldb.all;
import helpers.helperfactory;
import helpers.emailHelper;
import entity.smtpsettings;
import container;

import decisionmakers.registeruser;
import decisionmakers.login;
import decisionmakers.createprefix;
import decisionmakers.passwordresetinitiate;
import decisionmakers.passwordresetcomplete;

import projections.auth.registeruser;
import projections.auth.assignprefix;
import projections.auth.login;
import projections.auth.createprefix;
import projections.auth.passwordresetinitiate;
import projections.auth.passwordresetcomplete;

import commands.assignprefix;
import commands.login;
import commands.registeruser;
import commands.createprefix;
import commands.passwordresetinitiate;
import commands.passwordresetcomplete;


class AuthDirector : EventListenerInterface
{
    private RelationalDBInterface relationalDb;
    private HelperFactory helperFactory;
    private SMTPSettings smtpSettings;
    protected Variant[string] eventMessages;
    
    this(Container container) @safe
    {
        this.relationalDb = container.getRelationalDb();
        this.helperFactory = container.getHelperFactory();
        this.smtpSettings = container.getSMTPSettings();
    }
    
    public TypeInfo[] getInterestedEvents() @safe
    {
        return [
            typeid(RegisterUserCommand),
            typeid(LoginCommand),
            typeid(AssignPrefixCommand),
            typeid(CreatePrefixCommand),
            typeid(PasswordResetInitiateCommand),
            typeid(PasswordResetCompleteCommand)
        ];
    }

    public EventListInterface handleEvent(EventInterface event, TypeInfo eventType) @trusted
    {
        const string eventTypeStr = eventType.toString();

        debug {
            writeln("AuthDirector received event: ", eventTypeStr);
        }

        auto eventList = new EventList();
        auto metaVariant = event.getMetadata();

        if (eventType == typeid(RegisterUserCommand)) {
            RegisterUserDMMeta meta = *metaVariant.peek!(RegisterUserDMMeta);
            auto handler = new RegisterUserProjection(this.relationalDb, this.helperFactory, meta);
            handler.handleEvent();
        } else if (eventType == typeid(AssignPrefixCommand)) {
            auto const meta = *metaVariant.peek!(AssignPrefixMeta);
            auto handler = new AssignPrefixProjection(this.relationalDb, meta);
            handler.handleEvent();
        } else if (eventType == typeid(LoginCommand)) {
            auto const meta = *metaVariant.peek!(LoginDMMeta);
            auto handler = new LoginProjection(this.relationalDb, this.helperFactory, meta);
            handler.handleEvent(this.eventMessages);
        } else if (eventType == typeid(CreatePrefixCommand)) {
            auto const meta = *metaVariant.peek!(CreatePrefixDMMeta);
            auto handler = new CreatePrefixProjection(this.relationalDb, meta);
            handler.handleEvent(this.eventMessages);
        } else if (eventType == typeid(PasswordResetInitiateCommand)) {
            auto const meta = *metaVariant.peek!(PasswordResetInitiateDMMeta);
            auto handler = new PasswordResetInitiateProjection(this.relationalDb, this.helperFactory, meta, this.smtpSettings);
            handler.handleEvent();
        } else if (eventType == typeid(PasswordResetCompleteCommand)) {
            auto const meta = *metaVariant.peek!(PasswordResetCompleteDMMeta);
            auto handler = new PasswordResetCompleteProjection(this.relationalDb, this.helperFactory, meta);
            handler.handleEvent();
        } else {
            debug {
                writeln("AuthDirector::handleEvent - Unhandled event type: ", eventType);
            }
        }   

        return eventList;
    }

    public T getEventMessage(T)(string key) @trusted
    {
        if (key in this.eventMessages) {
            return *((this.eventMessages[key]).peek!T);
        }

        throw new Exception("Key does not exist in eventMessages hashmap");
    }
}