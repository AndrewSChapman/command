module commands.changepassword;

import command.abstractcommand;

struct ChangePasswordCommandMetadata
{
    long usrId;
    string password;
}

class ChangePasswordCommand : AbstractCommand!ChangePasswordCommandMetadata
{
    this(
        in ref ulong usrId,
        in ref string password
    ) @safe {
        ChangePasswordCommandMetadata meta;
        meta.usrId = usrId;
        meta.password = password;

        super(meta);
    }
}