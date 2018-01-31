module commands.updateuser;
import command.abstractcommand;

struct UpdateUserCommandMetadata
{
    long usrId;
    string firstName;
    string lastName;
}

class UpdateUserCommand : AbstractCommand!UpdateUserCommandMetadata
{
    this(
        ref ulong usrId,
        ref string firstName,
        ref string lastName
    ) @safe {
        UpdateUserCommandMetadata meta;
        meta.usrId = usrId;
        meta.firstName = firstName;
        meta.lastName = lastName;

        super(meta);
    }
}