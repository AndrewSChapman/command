module entity.sessioninfo;

struct SessionInfo 
{
    string prefix;
    ulong usrId;
    long expiresAt;
    string userAgent;
    string ipAddress;    
}