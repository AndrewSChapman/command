module commands.deleteuser;

import command.abstractcommand;

struct DeleteUserCommandMetadata
{
    ulong usrId;
    ulong deletedByUsrId;
    bool hardDelete;
}

class DeleteUserCommand : AbstractCommand!DeleteUserCommandMetadata
{
    this(
        in ref ulong usrId,
        in ref ulong deletedByUsrId,
        in ref bool hardDelete
    ) @safe {
        DeleteUserCommandMetadata meta;
        meta.usrId = usrId;
        meta.deletedByUsrId = deletedByUsrId;
        meta.hardDelete = hardDelete;

        super(meta);
    }
}