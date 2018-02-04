module commands.registeruser;

import command.abstractcommand;

struct RegisterNewUserCommandMetadata
{
    string username;
    string userFirstName;
    string userLastName;
    string email;
    string password;
}

class RegisterUserCommand : AbstractCommand!RegisterNewUserCommandMetadata
{
    this(
        in ref string username,
        in ref string userFirstName,
        in ref string userLastName,
        in ref string email,
        in ref string password
    ) @safe {
        RegisterNewUserCommandMetadata meta;
        meta.username = username;
        meta.userFirstName = userFirstName;
        meta.userLastName = userLastName;
        meta.email = email;
        meta.password = password;

        super(meta);
    }
}