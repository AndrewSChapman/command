import { ApiClient } from "../apiClient";
import * as Cookies from 'js-cookie';

export class StorageHelper
{
    private _apiClient: ApiClient;
    private _prefix: string;
    
    constructor(apiClient: ApiClient)
    {
        this._apiClient = apiClient;

        if (typeof(Storage) == "undefined") {
            throw new Error('LocalStorage not supported in this browser');
        }

        this._prefix = '';
    }

    public setValue(key: string, value: any): void
    {
        localStorage.setItem(key, value);
    }

    public getString(key: string, defaultValue: string = ''): string
    {
        const val: any = localStorage.getItem(key);
        let result: string = '';

        if (typeof(val) == 'string') {
            result = val;
        }

        if (result === '') {
            result = defaultValue;
        }

        return result;
    }

    public async getPrefix(): Promise<string>
    {
        if (this._prefix != '') {
            return this._prefix;
        }
        
        let prefix = localStorage.getItem("prefix");
        if (prefix == null) {
            const response = await this._apiClient.get("prefix");
            prefix = response.prefix;
        }

        if ((!prefix) || (prefix.length == 0)) {
            throw new Error('Failed to load prefix');
        }

        localStorage.setItem("prefix", prefix);

        this._prefix = prefix;

        return this._prefix;
    }

    public setCookie(key: string, value: any): void
    {
        Cookies.set(key, value);
    }

    public getCookie(key: string): any
    {
        const result = Cookies.get(key);
        if (typeof(result) == "undefined") {
            return '';
        }

        return result;
    }
}