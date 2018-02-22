import { ApiClient } from "../apiClient";
import { ErrorHelper } from "../helpers/errorHelper";
import { StorageHelper } from "../helpers/storageHelper";
import { LoginResponse } from "./valueObjects/loginResponse";
import { OverlayLoader } from "../ui/overlayLoader";

enum MessageType { ALERT, ERROR, INFO }

export class ProfileManager
{
    private _apiClient: ApiClient;
    private _errorHelper: ErrorHelper;
    private _storageHelper: StorageHelper;
    private _overlayLoader: OverlayLoader;

    private _$form: JQuery<HTMLElement>;
    private _$firstName: JQuery<HTMLElement>;
    private _$lastName: JQuery<HTMLElement>;
    private _$emailAddress: JQuery<HTMLElement>;    

    private _$changePasswordWrapper: JQuery<HTMLElement>;
    private _$formChangePassword: JQuery<HTMLElement>;
    private _$existingPassword: JQuery<HTMLElement>;
    private _$newPassword: JQuery<HTMLElement>;
    private _$newPasswordRepeat: JQuery<HTMLElement>;

    private _$changeEmailWrapper: JQuery<HTMLElement>;
    private _$formChangeEmail: JQuery<HTMLElement>;
    private _$newEmailAddress: JQuery<HTMLElement>;    

    private _$actionLinks: JQuery<HTMLElement>;
    
    private _$messages: JQuery<HTMLElement>;

    constructor(
        apiClient: ApiClient,
        errorHelper: ErrorHelper,
        storageHelper: StorageHelper
    ) {
        this._apiClient = apiClient;
        this._errorHelper = errorHelper;
        this._storageHelper = storageHelper;

        this._overlayLoader = new OverlayLoader('#frmProfile');

        this._$messages = $('div.messages');
        this._$form = $('#frmProfile');
        this._$firstName = this._$form.find('#firstName');
        this._$lastName = this._$form.find('#lastName');
        this._$emailAddress = this._$form.find('#emailAddress');
        
        this._$changePasswordWrapper = $('#changePasswordWrapper ');
        this._$formChangePassword = this._$changePasswordWrapper.find('#frmChangePassword');
        this._$existingPassword = this._$formChangePassword.find('#existingPassword');
        this._$newPassword = this._$formChangePassword.find('#newPassword');
        this._$newPasswordRepeat = this._$formChangePassword.find('#newPasswordRepeat');

        this._$changeEmailWrapper = $('#changeEmailWrapper ');
        this._$formChangeEmail = this._$changeEmailWrapper.find('#frmChangeEmail');
        this._$newEmailAddress = this._$formChangeEmail.find('#newEmailAddress');

        this._$actionLinks = $('ul.actions');

        this.attachListeners();
    }

    private attachListeners(): void
    {
        this.onProfileFormSubmit();
        this.onChangePasswordFormSubmit();
        this.onChangeEmailFormSubmit();
        this.onActionLinkClick();
    }

    private changePasswordFormIsValid(): boolean
    {
        if (this._$newPassword.val() != this._$newPasswordRepeat.val()) {
            this.showError("Your passwords do not match.  Please enter your new password again twice and ensure you type it correctly.");
            this._$newPassword.val("");
            this._$newPasswordRepeat.val("");

            return false;
        }
        
        return true;
    }

    private onActionLinkClick(): void
    {
        this._$actionLinks.find('a').on('click', (evt) => {
            evt.preventDefault();

            const $link = $(evt.target);
            const action: string = $link.data('action');

            switch(action) {
                case 'changePassword':
                    this._$changeEmailWrapper.addClass('hidden');
                    this._$changePasswordWrapper.removeClass('hidden');
                    break;

                    case 'changeEmail':
                    this._$changePasswordWrapper.addClass('hidden');
                    this._$changeEmailWrapper.removeClass('hidden');
                    break;                 

                default:
                    console.log('Unhandled action link: ' + action);
                    break;
            }
        });        
    }

    private onProfileFormSubmit(): void
    {
        this._$form.on('submit', async (evt) => {
            evt.preventDefault();

            this.hideMessage();
            this._overlayLoader.render();

            try {
                const request = {
                    'updateProfile': {
                        'firstName': this._$firstName.val(),
                        'lastName': this._$lastName.val()
                    }
                }

                this._apiClient.post('profile', request).then((response) => {
                    this._overlayLoader.remove();

                    this.showInfo(`Your account has been updated successfully.`);
                }, (error: any) => {
                    this._overlayLoader.remove();
                    this._errorHelper.resolveError(error);
                    const message: string = this._errorHelper.getMessage();
    
                    if (message != "") {
                        this.showError(message);
                    } else {
                        this.showError('Sorry, your request failed.  Please check your details and try again.');
                    }
                });
            } catch (error) {
                this._overlayLoader.remove();
                this.showError(error);
            }
        });      
    }

    private onChangePasswordFormSubmit(): void
    {
        this._$formChangePassword.on('submit', async (evt) => {
            evt.preventDefault();

            if (!this.changePasswordFormIsValid()) {
                return;
            }

            this.hideMessage();
            this._overlayLoader.render();

            try {
                const request = {
                    'changePassword': {
                        'existingPassword': this._$existingPassword.val(),
                        'newPassword': this._$newPassword.val(),
                        'newPasswordRepeated': this._$newPasswordRepeat.val()
                    }
                }

                this._apiClient.post('change_password', request).then((response) => {
                    this._overlayLoader.remove();
                    this.showInfo(`Your password has been updated successfully.`);
                    this._$changePasswordWrapper.addClass('hidden');
                }, (error: any) => {
                    this._overlayLoader.remove();
                    this._$existingPassword.val("");
                    this._$newPassword.val("");
                    this._$newPasswordRepeat.val("");

                    this._errorHelper.resolveError(error);
                    const message: string = this._errorHelper.getMessage();
    
                    if (message != "") {
                        this.showError(message);
                    } else {
                        this.showError('Sorry, your request failed.  Please check your details and try again.');
                    }
                });
            } catch (error) {
                this._overlayLoader.remove();
                this.showError(error);
            }
        });        
    }

    private onChangeEmailFormSubmit(): void
    {
        this._$formChangeEmail.on('submit', async (evt) => {
            evt.preventDefault();

            this.hideMessage();
            this._overlayLoader.render();

            try {
                const request = {
                    'changeEmail': {
                        'emailAddress': this._$newEmailAddress.val()
                    }
                }

                this._apiClient.post('change_email', request).then((response) => {
                    this._overlayLoader.remove();
                    this.showInfo(`Your email address has been updated successfully.`);
                    const newEmail: any = this._$newEmailAddress.val();
                    this._$newEmailAddress.val('');
                    this._$emailAddress.val(newEmail);
                    this._$changeEmailWrapper.addClass('hidden');
                }, (error: any) => {
                    this._overlayLoader.remove();
                    this._errorHelper.resolveError(error);
                    const message: string = this._errorHelper.getMessage();
    
                    if (message != "") {
                        this.showError(message);
                    } else {
                        this.showError('Sorry, your request failed.  Please check your details and try again.');
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