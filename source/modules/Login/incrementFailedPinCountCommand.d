module commands.incrementfailedpincount;

import command.abstractcommand;

struct IncrementFailedPinCountCommandMetadata
{
    ulong usrId;
}

class IncrementFailedPinCountCommand : AbstractCommand!IncrementFailedPinCountCommandMetadata
{
    this(
        ulong usrId
    ) @safe {
        IncrementFailedPinCountCommandMetadata meta;
        meta.usrId = usrId;
        
        super(meta);
    }
}