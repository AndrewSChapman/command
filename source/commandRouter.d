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
import commands.adduser;

import executors.profile.updateuser;
import executors.profile.changeemail;
import executors.profile.changepassword;
import executors.adduser;

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
            typeid(ChangePasswordCommand),
            typeid(AddUserCommand)            
        ];
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
            auto executor = new AssignPrefixExecutor(this.relationalDb, command);
            executor.executeCommand();
            return;       
        }; 

        // CHANGE EMAIL
        commandHandlers[typeid(ChangeEmailCommand)] = {
            auto executor = new ChangeEmailExecutor(this.relationalDb, command);
            executor.executeCommand(); 
            return;       
        };  

        // CHANGE PASSWORD
        commandHandlers[typeid(ChangePasswordCommand)] = {
            auto executor = new ChangePasswordExecutor(this.relationalDb, this.helperFactory, command);
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
            auto executor = new LoginExecutor(this.relationalDb, this.helperFactory, command);
            executor.executeCommand(this.eventMessages); 
            return;       
        };

        // PASSWORD RESET COMPLETE
        commandHandlers[typeid(PasswordResetCompleteCommand)] = {
            auto executor = new PasswordResetCompleteExecutor(this.relationalDb, this.helperFactory, command);
            executor.executeCommand();
            return;       
        };          

        // PASSWORD RESET INITIATE
        commandHandlers[typeid(PasswordResetInitiateCommand)] = {
            auto executor = new PasswordResetInitiateExecutor(this.relationalDb, this.helperFactory, command, this.smtpSettings);
            executor.executeCommand();
            return;       
        };            

        // REGISTER USER
        commandHandlers[typeid(RegisterUserCommand)] = {
            auto executor = new RegisterUserExecutor(this.relationalDb, this.helperFactory, command, this.smtpSettings);
            executor.executeCommand();
            return;       
        };        

        // UPDATE USER (GENERAL)
        commandHandlers[typeid(UpdateUserCommand)] = {
            auto executor = new UpdateUserExecutor(this.relationalDb, command);
            executor.executeCommand();
            return;       
        };

        // ADD USER
        commandHandlers[typeid(AddUserCommand)] = {
            auto executor = new AddUserExecutor(this.relationalDb, this.helperFactory, command, this.smtpSettings);
            executor.executeCommand(this.eventMessages);
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