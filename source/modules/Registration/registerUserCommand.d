module commands.registeruser;

import command.abstractcommand;

struct RegisterNewUserCommandMetadata
{
    string userFirstName;
    string userLastName;
    string email;
    string password;    
}

class RegisterUserCommand : AbstractCommand!RegisterNewUserCommandMetadata
{
    this(
        ref string userFirstName,
        ref string userLastName,
        ref string email,
        ref string password
    ) @safe {
        RegisterNewUserCommandMetadata meta;
        meta.userFirstName = userFirstName;
        meta.userLastName = userLastName;
        meta.email = email;
        meta.password = password;

        super(meta);
    }
}