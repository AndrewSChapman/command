module commands.assignprefix;

import commandlib.abstractcommand;

struct AssignPrefixCommandMetadata
{
    string prefix;
    ulong usrId;
}

class AssignPrefixCommand : AbstractCommand!AssignPrefixCommandMetadata
{
    this(ref string prefix, ref ulong usrId) @safe
    {
        AssignPrefixCommandMetadata meta;
        meta.prefix = prefix;
        meta.usrId = usrId;
        
        super(meta);
    }
}