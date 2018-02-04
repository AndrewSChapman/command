module commands.updateuser;
import command.abstractcommand;
import entity.user;

struct UpdateUserCommandMetadata
{
    ulong usrId;
    uint usrType;
    string firstName;
    string lastName;
}

class UpdateUserCommand : AbstractCommand!UpdateUserCommandMetadata
{
    this(
        ref ulong usrId,
        ref UserType usrType,
        ref string firstName,
        ref string lastName
    ) @safe {
        UpdateUserCommandMetadata meta;
        meta.usrId = usrId;
        meta.usrType = usrType;
        meta.firstName = firstName;
        meta.lastName = lastName;

        super(meta);
    }
}