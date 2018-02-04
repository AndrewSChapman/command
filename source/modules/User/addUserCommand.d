module commands.adduser;

import command.abstractcommand;

struct AddUserCommandMetadata
{
    uint usrType;
    string username;
    string userFirstName;
    string userLastName;
    string email;
    string password;
}

class AddUserCommand : AbstractCommand!AddUserCommandMetadata
{
    this(
        in ref uint usrType,
        in ref string username,
        in ref string userFirstName,
        in ref string userLastName,
        in ref string email,
        in ref string password
    ) @safe {
        AddUserCommandMetadata meta;
        meta.usrType = usrType;
        meta.username = username;
        meta.userFirstName = userFirstName;
        meta.userLastName = userLastName;
        meta.email = email;
        meta.password = password;

        super(meta);
    }
}