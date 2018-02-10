module commands.incrementfailedlogincount;

import command.abstractcommand;

struct IncrementFailedLoginCountCommandMetadata
{
    ulong usrId;
}

class IncrementFailedLoginCountCommand : AbstractCommand!IncrementFailedLoginCountCommandMetadata
{
    this(
        ulong usrId
    ) @safe {
        IncrementFailedLoginCountCommandMetadata meta;
        meta.usrId = usrId;
        
        super(meta);
    }
}