import { ApiClient } from "./apiClient";
import { LoginManager } from "./auth/LoginManager";
import { ErrorHelper } from "./helpers/errorHelper";
import { StorageHelper } from "./helpers/storageHelper";
import { RegisterManager } from "./auth/RegisterManager";
import { PasswordResetManager } from "./auth/PasswordResetManager";
import { ProfileManager } from "./auth/ProfileManager";

export class AppFactory
{
    private _apiClient: ApiClient;

    constructor() {
        this._apiClient = new ApiClient('/', new StorageHelper());
    }
    
    public GetApiClient(): ApiClient
    {
        return this._apiClient;
    }

    public LoginManager(): LoginManager
    {
        return new LoginManager(
            this._apiClient,
            new ErrorHelper(),
            new StorageHelper()
        );
    }

    public RegisterManager(): RegisterManager
    {
        return new RegisterManager(
            this._apiClient,
            new ErrorHelper(),
            new StorageHelper()
        );
    } 
    
    public PasswordResetManager(): PasswordResetManager
    {
        return new PasswordResetManager(
            this._apiClient,
            new ErrorHelper(),
            new StorageHelper()
        );
    }
    
    public ProfileManager(): ProfileManager
    {
        return new ProfileManager(
            this._apiClient,
            new ErrorHelper(),
            new StorageHelper()
        );
    }
}