import * as $ from "jquery";
import { StorageHelper } from "./helpers/storageHelper";

export enum HttpMethod { POST = 'POST', GET = 'GET', PUT = 'PUT', DELETE = 'DELETE' }

/**
 * A client for making requests to the backend of the admin dashboard with form encoded data.
 */
export class ApiClient
{
    private _apiURL: string;
    private _storageHelper: StorageHelper;

    constructor(apiURL: string, storageHelper: StorageHelper)
    {
        this._apiURL = apiURL;
        this._storageHelper = storageHelper;
    }

    public async get(url: string): Promise<any>
    {
        return this.request(url, HttpMethod.GET, {});
    }

    public async post(url: string, params: object): Promise<any>
    {
        return this.request(url, HttpMethod.POST, params);
    }

    private async request(url: string, method: HttpMethod, params: object): Promise<any>
    {
        let data: string = '';

        if (method === HttpMethod.POST) {
            data = JSON.stringify(params);
        }

        const requestUrl = this._apiURL + url;

        return new Promise<any>((resolve, reject) => {
            $.ajax({
                contentType: 'application/json',
                data: data,
                url: requestUrl,
                method: method,
                beforeSend: (xhr: any) => {
                    const tokenCode = this._storageHelper.getCookie('tokenCode');
                    if (tokenCode != '') {
                        xhr.setRequestHeader("Token-Code", tokenCode);
                    }
                },                
                success: (response: any) => {
                    resolve(response);
                },
                error: (xhr: any, status: string, errorThrown: any) => {
                    var err = eval("(" + xhr.responseText + ")");                    
                    reject(err);
                }
            })
        });
    }
}