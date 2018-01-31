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
    
    public TypeInfo[] getRegisteredCommands() @safe
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

    public void registerCommand(TypeInfo commandType)
    {
        writeln("Received register: ", commandType);
    }

    public CommandBusInterface executeCommand(CommandInterface command, TypeInfo commandType) @trusted
    {
        const string commandTypeStr = commandType.toString();

        debug {
            writeln("CommandRouter received command: ", commandTypeStr);
        }

        CommandHandler[TypeInfo] commandHandlers;    

        auto commandList = new CommandList();
        auto metaVariant = command.getMetadata();    

        // ASSIGN PREFIX COMMAND
        commandHandlers[typeid(AssignPrefixCommand)] = {
            auto const meta = *metaVariant.peek!(AssignPrefixCommandMetadata);
            auto executor = new AssignPrefixExecutor(this.relationalDb, meta);
            return;       
        }; 

        // CHANGE EMAIL
        commandHandlers[typeid(ChangeEmailCommand)] = {
            auto meta = *metaVariant.peek!(ChangeEmailCommandMeta);
            auto executor = new ChangeEmailExecutor(this.relationalDb, meta);
            executor.executeCommand(); 
            return;       
        };  

        // CHANGE PASSWORD
        commandHandlers[typeid(ChangePasswordCommand)] = {
            auto meta = *metaVariant.peek!(ChangePasswordCommandMetadata);
            auto executor = new ChangePasswordExecutor(this.relationalDb, this.helperFactory, meta);
            executor.executeCommand();
            return;       
        };                              

        // CREATE PREFIX
        commandHandlers[typeid(CreatePrefixCommand)] = {
            auto executor = new CreatePrefixExecutor(this.relationalDb, command);
            executor.executeCommand(this.eventMessages);
            return;       
        };

        // LOGIN
        commandHandlers[typeid(LoginCommand)] = {
            auto const meta = *metaVariant.peek!(LoginCommandMetadata);
            auto executor = new LoginExecutor(this.relationalDb, this.helperFactory, meta);
            executor.executeCommand(this.eventMessages); 
            return;       
        };

        // PASSWORD RESET COMPLETE
        commandHandlers[typeid(PasswordResetCompleteCommand)] = {
            auto const meta = *metaVariant.peek!(PasswordResetCompleteCommandMetadata);
            auto executor = new PasswordResetCompleteExecutor(this.relationalDb, this.helperFactory, meta);
            executor.executeCommand();
            return;       
        };          

        // PASSWORD RESET INITIATE
        commandHandlers[typeid(PasswordResetInitiateCommand)] = {
            auto const meta = *metaVariant.peek!(PasswordResetInitiateCommandMetadata);
            auto executor = new PasswordResetInitiateExecutor(this.relationalDb, this.helperFactory, meta, this.smtpSettings);
            executor.executeCommand();
            return;       
        };            

        // REGISTER USER
        commandHandlers[typeid(RegisterUserCommand)] = {
            RegisterNewUserCommandMetadata meta = *metaVariant.peek!(RegisterNewUserCommandMetadata);
            auto executor = new RegisterUserExecutor(this.relationalDb, this.helperFactory, meta, this.smtpSettings);
            executor.executeCommand();
            return;       
        };

        // UPDATE USER
        commandHandlers[typeid(UpdateUserCommand)] = {
            auto meta = *metaVariant.peek!(UpdateUserCommandMetadata);
            auto executor = new UpdateUserExecutor(this.relationalDb, meta);
            executor.executeCommand();
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