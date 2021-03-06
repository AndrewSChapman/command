import { ApiClient } from "../apiClient";
import { ErrorHelper } from "../helpers/errorHelper";
import { StorageHelper } from "../helpers/storageHelper";
import { LoginResponse } from "./valueObjects/loginResponse";
import { OverlayLoader } from "../ui/overlayLoader";

enum MessageType { ALERT, ERROR, INFO }

export class RegisterManager
{
    private _apiClient: ApiClient;
    private _errorHelper: ErrorHelper;
    private _storageHelper: StorageHelper;
    private _overlayLoader: OverlayLoader;

    private _$form: JQuery<HTMLElement>;
    private _$firstName: JQuery<HTMLElement>;
    private _$lastName: JQuery<HTMLElement>;
    private _$emailAddress: JQuery<HTMLElement>;
    private _$username: JQuery<HTMLElement>;
    private _$password: JQuery<HTMLElement>;
    private _$passwordRepeat: JQuery<HTMLElement>;
    private _$messages: JQuery<HTMLElement>;

    constructor(
        apiClient: ApiClient,
        errorHelper: ErrorHelper,
        storageHelper: StorageHelper
    ) {
        this._apiClient = apiClient;
        this._errorHelper = errorHelper;
        this._storageHelper = storageHelper;

        this._overlayLoader = new OverlayLoader('#frmRegister');

        this._$messages = $('div.messages');
        this._$form = $('#frmRegister');
        this._$firstName = this._$form.find('#firstName');
        this._$lastName = this._$form.find('#lastName');
        this._$emailAddress = this._$form.find('#emailAddress');
        this._$username = this._$form.find('#username');
        this._$password = this._$form.find('#password');
        this._$passwordRepeat = this._$form.find('#passwordRepeat');

        this.attachListeners();
    }

    private attachListeners(): void
    {
        this.onFormSubmit();
    }

    private formIsValid(): boolean
    {
        if (this._$password.val() != this._$passwordRepeat.val()) {
            this.showError("Your passwords do not match.  Please enter your new password again twice and ensure you type it correctly twice.");
            this._$password.val("");
            this._$passwordRepeat.val("");

            return false;
        }
        
        return true;
    }

    private onFormSubmit(): void
    {
        this._$form.on('submit', async (evt) => {
            evt.preventDefault();

            if (!this.formIsValid()) {
                return;
            }

            this.hideMessage();
            this._overlayLoader.render();

            try {
                const request = {
                    'register': {
                        'userFirstName': this._$firstName.val(),
                        'userLastName': this._$lastName.val(),
                        'email': this._$emailAddress.val(),
                        'username': this._$username.val(),
                        'password': this._$password.val()
                    }
                }

                this._apiClient.post('register', request).then((response) => {
                    this._overlayLoader.remove();

                    this.showInfo(`Thank you!  Your account has been created successfully.  Please <a href="/login">click here to login</a>.`);
                }, (error: any) => {
                    this._overlayLoader.remove();
                    this._errorHelper.resolveError(error);
                    const message: string = this._errorHelper.getMessage();
    
                    if (message != "") {
                        this.showError(message);
                    } else {
                        this.showError('Sorry, your registration request failed.  Please check your details and try again.');
                    }
                });
            } catch (error) {
                this._overlayLoader.remove();
                this.showError(error);
            }
        })
    }

    private showError(message: string): void
    {
        this.showMessage(message, MessageType.ERROR);
    }

    private showAlert(message: string): void
    {
        this.showMessage(message, MessageType.ALERT);
    }
    
    private showInfo(message: string): void
    {
        this.showMessage(message, MessageType.INFO);
    }    

    private showMessage(message: string, messageType: MessageType = MessageType.INFO): void
    {
        this._$messages.html(message);

        this._$messages.removeClass('alert');
        this._$messages.removeClass('info');
        this._$messages.removeClass('error');

        if (messageType == MessageType.ALERT) {
            this._$messages.addClass('alert');
        } else if(messageType == MessageType.INFO) {
            this._$messages.addClass('info');
        } else {
            this._$messages.addClass('error');
        }

        this._$messages.show();
    }

    private hideMessage()
    {
        this._$messages.hide();
    }
}