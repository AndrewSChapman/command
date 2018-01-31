module commandrouter;

import std.stdio;
import std.variant;

import command.all;
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

class CommandRouter : CommandListenerInterface
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
    
    public TypeInfo[] getInterestedCommands() @safe
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

    public CommandBusInterface executeCommand(CommandInterface event, TypeInfo commandType) @trusted
    {
        const string commandTypeStr = commandType.toString();

        debug {
            writeln("CommandRouter received event: ", commandTypeStr);
        }

        CommandHandler[TypeInfo] commandHandlers;    

        auto commandList = new CommandList();
        auto metaVariant = event.getMetadata();    

        // ASSIGN PREFIX COMMAND
        commandHandlers[typeid(AssignPrefixCommand)] = {
            auto const meta = *metaVariant.peek!(AssignPrefixCommandMetadata);
            auto handler = new AssignPrefixExecutor(this.relationalDb, meta);
            return;       
        }; 

        // CHANGE EMAIL
        commandHandlers[typeid(ChangeEmailCommand)] = {
            auto meta = *metaVariant.peek!(ChangeEmailCommandMeta);
            auto handler = new ChangeEmailExecutor(this.relationalDb, meta);
            handler.executeCommand(); 
            return;       
        };  

        // CHANGE PASSWORD
        commandHandlers[typeid(ChangePasswordCommand)] = {
            auto meta = *metaVariant.peek!(ChangePasswordCommandMetadata);
            auto handler = new ChangePasswordExecutor(this.relationalDb, this.helperFactory, meta);
            handler.executeCommand();
            return;       
        };                              

        // CREATE PREFIX
        commandHandlers[typeid(CreatePrefixCommand)] = {
            auto const meta = *metaVariant.peek!(CreatePrefixCommandMetadata);
            auto projection = new CreatePrefixExecutor(this.relationalDb, meta);
            projection.executeCommand(this.eventMessages);
            return;       
        };

        // LOGIN
        commandHandlers[typeid(LoginCommand)] = {
            auto const meta = *metaVariant.peek!(LoginCommandMetadata);
            auto handler = new LoginExecutor(this.relationalDb, this.helperFactory, meta);
            handler.executeCommand(this.eventMessages); 
            return;       
        };

        // PASSWORD RESET COMPLETE
        commandHandlers[typeid(PasswordResetCompleteCommand)] = {
            auto const meta = *metaVariant.peek!(PasswordResetCompleteCommandMetadata);
            auto handler = new PasswordResetCompleteExecutor(this.relationalDb, this.helperFactory, meta);
            handler.executeCommand();
            return;       
        };          

        // PASSWORD RESET INITIATE
        commandHandlers[typeid(PasswordResetInitiateCommand)] = {
            auto const meta = *metaVariant.peek!(PasswordResetInitiateCommandMetadata);
            auto handler = new PasswordResetInitiateExecutor(this.relationalDb, this.helperFactory, meta, this.smtpSettings);
            handler.executeCommand();
            return;       
        };            

        // REGISTER USER
        commandHandlers[typeid(RegisterUserCommand)] = {
            RegisterNewUserCommandMetadata meta = *metaVariant.peek!(RegisterNewUserCommandMetadata);
            auto handler = new RegisterUserExecutor(this.relationalDb, this.helperFactory, meta, this.smtpSettings);
            handler.executeCommand();
            return;       
        };

        // UPDATE USER
        commandHandlers[typeid(UpdateUserCommand)] = {
            auto meta = *metaVariant.peek!(UpdateUserCommandMetadata);
            auto handler = new UpdateUserExecutor(this.relationalDb, meta);
            handler.executeCommand();
            return;       
        };        

        if (commandType in commandHandlers) {
            commandHandlers[commandType]();
        } else {
            throw new Exception("Invalid commandType: " ~ commandType.toString());
        }


        return commandList;
    }

    public T getEventMessage(T)(string key) @trusted
    {
        if (key in this.eventMessages) {
            return *((this.eventMessages[key]).peek!T);
        }

        throw new Exception("Key does not exist in eventMessages hashmap");
    }
}