import { ApiClient } from "../apiClient";
import { ErrorHelper } from "../helpers/errorHelper";
import { StorageHelper } from "../helpers/storageHelper";
import { LoginResponse } from "./valueObjects/loginResponse";
import { OverlayLoader } from "../ui/overlayLoader";

enum MessageType { ALERT, ERROR, INFO }

export class PasswordResetManager
{
    private _apiClient: ApiClient;
    private _errorHelper: ErrorHelper;
    private _storageHelper: StorageHelper;
    private _overlayLoader: OverlayLoader;

    private _$form: JQuery<HTMLElement>;
    private _$username: JQuery<HTMLElement>;
    private _$password: JQuery<HTMLElement>;
    private _$passwordRepeat: JQuery<HTMLElement>;
    private _$messages: JQuery<HTMLElement>;

    private _$formPin: JQuery<HTMLElement>;
    private _$emailAddress: JQuery<HTMLElement>;
    private _$newPasswordPin: JQuery<HTMLElement>;

    constructor(
        apiClient: ApiClient,
        errorHelper: ErrorHelper,
        storageHelper: StorageHelper
    ) {
        this._apiClient = apiClient;
        this._errorHelper = errorHelper;
        this._storageHelper = storageHelper;

        this._overlayLoader = new OverlayLoader('#frmPasswordReset');

        this._$messages = $('div.messages');
        this._$form = $('#frmPasswordReset');
        this._$username = this._$form.find('#username');
        this._$password = this._$form.find('#password');
        this._$passwordRepeat = this._$form.find('#passwordRepeat');

        this._$formPin = $('#frmPasswordResetPin');
        this._$emailAddress = this._$formPin.find('#emailAddress');
        this._$newPasswordPin = this._$formPin.find('#newPasswordPin');

        this.attachListeners();
        this.showResetForm();
    }

    private attachListeners(): void
    {
        this.onFormSubmit();
    }

    private showResetForm(): void
    {
        this._$form.show();
        this._$formPin.hide();
    }

    private showPinForm(): void
    {
        this._$form.hide();
        this._$formPin.show();
        this._$formPin.removeClass('hidden');
        this.clearPinForm();
    }
    
    private clearPinForm(): void
    {
        // Ensure input fields are emptied.
        this._$newPasswordPin.val("");
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
    
    private formPinIsValid(): boolean
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
                    'passwordResetRequest': {
                        'username': this._$username.val(),
                        'newPassword': this._$password.val(),
                        'newPasswordRepeated': this._$passwordRepeat.val(),
                    }
                }

                this._apiClient.post('password_reset', request).then((response) => {
                    this._overlayLoader.remove();
                    this.showMessage("Thank you.  We have sent you an email containing a password reset pin number.  Please enter your email address and the pin number to complete your password reset.");
                    this.showPinForm();
                }, (error: any) => {
                    this._overlayLoader.remove();
                    this._errorHelper.resolveError(error);
                    const message: string = this._errorHelper.getMessage();
    
                    if (message != "") {
                        this.showError(message);
                    } else {
                        this.showError('Sorry, your password reset request.  Please check your details and try again.');
                    }
                });
            } catch (error) {
                this._overlayLoader.remove();
                this.showError(error);
            }
        });

        this._$formPin.on('submit', async (evt) => {
            evt.preventDefault();

            if (!this.formPinIsValid()) {
                return;
            }            

            this.hideMessage();
            this._overlayLoader.render();

            try {
                const pinVal = this._$newPasswordPin.val();
                let numVal: number = 0;

                if(typeof(pinVal) !== 'undefined') {
                    numVal = parseInt(pinVal.toString());
                }

                const request = {
                    'passwordResetCompleteRequest': {
                        'emailAddress': this._$emailAddress.val(),
                        'newPasswordPin': numVal
                    }
                }

                this._apiClient.post('password_reset_complete', request).then((response) => {
                    this._overlayLoader.remove();
                    this.showMessage(`Thank you.  Your password has been successfully reset.  Please <a href="/login">click here to login</a>.`);
                    this.clearPinForm();
                }, (error: any) => {
                    this._overlayLoader.remove();
                    this._errorHelper.resolveError(error);
                    const message: string = this._errorHelper.getMessage();
                    this.clearPinForm();
                        
                    if (message != "") {
                        this.showError(message);
                    } else {
                        this.showError('Sorry, your password reset request could not be completed.  Please try again.');
                    }
                });
            } catch (error) {
                this._overlayLoader.remove();
                this.showError(error);
            }
        });        
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