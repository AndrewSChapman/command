module entity.sessioninfo;

struct SessionInfo 
{
    string prefix;
    ulong usrId;
    uint usrType;
    long expiresAt;
    string userAgent;
    string ipAddress;    
}