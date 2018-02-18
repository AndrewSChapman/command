import { UsrType } from "../usrType";

export class LoginResponse
{
    private _tokenCode: string;
    private _ipAddress: string;
    private _userAgent: string;
    private _prefix: string;
    private _expiresAt: number;
    private _usrId: number;
    private _usrType: UsrType;

    constructor(tokenCode: string, ipAddress: string, userAgent: string, prefix: string, expiresAt: number, usrId: number, usrType: UsrType) {
        this._tokenCode = tokenCode;
        this._ipAddress = ipAddress;
        this._userAgent = userAgent;
        this._prefix = prefix;
        this._expiresAt = expiresAt;
        this._usrId = usrId;
        this._usrType = usrType;
    }

    public static fromResponse(response: any): LoginResponse
    {
        return new LoginResponse(
            response.tokenCode,
            response.ipAddress,
            response.userAgent,
            response.prefix,
            response.expiresAt,
            response.usrId,
            response.usrType == UsrType.ADMIN ? UsrType.ADMIN : UsrType.GENERAL
        )
    }

    get tokenCode(): string {
        return this._tokenCode;
    }

    get ipAddress(): string {
        return this._ipAddress;
    }

    get userAgent(): string {
        return this._userAgent;
    }

    get prefix(): string {
        return this._prefix;
    }

    get expiresAt(): number {
        return this._expiresAt;
    }    

    get usrId(): number {
        return this._usrId;
    }

    get usrType(): UsrType {
        return this._usrType;
    }
}