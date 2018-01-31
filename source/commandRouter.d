module commandrouter;

import std.stdio;
import std.variant;

import eventmanager.all;
import relationaldb.all;
import helpers.helperfactory;
import helpers.emailHelper;
import entity.smtpsettings;
import container;

// AUTH
//import decisionmakers.registeruser;
import decisionmakers.login;
import decisionmakers.passwordresetinitiate;
import decisionmakers.passwordresetcomplete;

import commands.assignprefix;
import commands.login;
import commands.registeruser;
import commands.createprefix;
import commands.passwordresetinitiate;
import commands.passwordresetcomplete;

import executors.auth.registeruser;
import executors.auth.assignprefix;
import executors.auth.login;
import executors.auth.createprefix;
import executors.auth.passwordresetinitiate;
import executors.auth.passwordresetcomplete;

// PROFILE
import commands.updateuser;
import commands.changeemail;
import commands.changepassword;

import executors.profile.updateuser;
import executors.profile.changeemail;
import executors.profile.changepassword;

alias CommandHandler = void delegate();

class CommandRouter : EventListenerInterface
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
            // AUTH
            typeid(RegisterUserCommand),
            typeid(LoginCommand),
            typeid(AssignPrefixCommand),
            typeid(CreatePrefixCommand),
            typeid(PasswordResetInitiateCommand),
            typeid(PasswordResetCompleteCommand),

            // PROFILE
            typeid(ChangeEmailCommand),
            typeid(UpdateUserCommand),
            typeid(ChangePasswordCommand)            
        ];
    }

    public EventListInterface handleEvent(EventInterface event, TypeInfo eventType) @trusted
    {
        const string eventTypeStr = eventType.toString();

        debug {
            writeln("CommandRouter received event: ", eventTypeStr);
        }

        CommandHandler[TypeInfo] commandHandlers;    

        auto eventList = new EventList();
        auto metaVariant = event.getMetadata();    

        // ASSIGN PREFIX COMMAND
        commandHandlers[typeid(AssignPrefixCommand)] = {
            auto const meta = *metaVariant.peek!(AssignPrefixCommandMetadata);
            auto handler = new AssignPrefixProjection(this.relationalDb, meta);
            return;       
        }; 

        // CHANGE EMAIL
        commandHandlers[typeid(ChangeEmailCommand)] = {
            auto meta = *metaVariant.peek!(ChangeEmailCommandMeta);
            auto handler = new ChangeEmailProjection(this.relationalDb, meta);
            handler.handleEvent(); 
            return;       
        };  

        // CHANGE PASSWORD
        commandHandlers[typeid(ChangePasswordCommand)] = {
            auto meta = *metaVariant.peek!(ChangePasswordCommandMetadata);
            auto handler = new ChangePasswordProjection(this.relationalDb, this.helperFactory, meta);
            handler.handleEvent();
            return;       
        };                              

        // CREATE PREFIX
        commandHandlers[typeid(CreatePrefixCommand)] = {
            auto const meta = *metaVariant.peek!(CreatePrefixCommandMetadata);
            auto projection = new CreatePrefixProjection(this.relationalDb, meta);
            projection.handleEvent(this.eventMessages);     
            return;       
        };

        // LOGIN
        commandHandlers[typeid(LoginCommand)] = {
            auto const meta = *metaVariant.peek!(LoginCommandMetadata);
            auto handler = new LoginProjection(this.relationalDb, this.helperFactory, meta);
            handler.handleEvent(this.eventMessages); 
            return;       
        };

        // PASSWORD RESET COMPLETE
        commandHandlers[typeid(PasswordResetCompleteCommand)] = {
            auto const meta = *metaVariant.peek!(PasswordResetCompleteCommandMetadata);
            auto handler = new PasswordResetCompleteProjection(this.relationalDb, this.helperFactory, meta);
            handler.handleEvent();
            return;       
        };          

        // PASSWORD RESET INITIATE
        commandHandlers[typeid(PasswordResetInitiateCommand)] = {
            auto const meta = *metaVariant.peek!(PasswordResetInitiateCommandMetadata);
            auto handler = new PasswordResetInitiateProjection(this.relationalDb, this.helperFactory, meta, this.smtpSettings);
            handler.handleEvent();
            return;       
        };            

        // REGISTER USER
        commandHandlers[typeid(RegisterUserCommand)] = {
            RegisterNewUserCommandMetadata meta = *metaVariant.peek!(RegisterNewUserCommandMetadata);
            auto handler = new RegisterUserProjection(this.relationalDb, this.helperFactory, meta, this.smtpSettings);
            handler.handleEvent();
            return;       
        };

        // UPDATE USER
        commandHandlers[typeid(UpdateUserCommand)] = {
            auto meta = *metaVariant.peek!(UpdateUserCommandMetadata);
            auto handler = new UpdateUserProjection(this.relationalDb, meta);
            handler.handleEvent();
            return;       
        };        

        if (eventType in commandHandlers) {
            commandHandlers[eventType]();
        } else {
            throw new Exception("Invalid eventType: " ~ eventType.toString());
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