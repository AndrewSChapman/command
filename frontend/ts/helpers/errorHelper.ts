export class ErrorHelper
{
    private message: string;
    private code: number;
    
    constructor()
    {
        this.message = '';
        this.code = 0;
    }

    public resolveError(error: any): void
    {
        this.message = '';
        this.code = 0;  

        if (typeof error === 'string')  {
            this.message = error;
            return;
        }         

        if (typeof error !== 'object') {
            return;
        }
        
        if (error.hasOwnProperty('message')) {
            this.message = error.message;
        }

        if (error.hasOwnProperty('info')) {
            if ((this.message != "") && (error.info != "")) {
                this.message += ' ';
            }
            this.message += error.info;
        }

        if (error.hasOwnProperty('statusMessage')) {
            this.message += error.statusMessage;
        }
        
        if (error.hasOwnProperty('code')) {
            this.code = error.code;
        }           
    }

    public getMessage(): string
    {
        return this.message;
    }

    public getCode(): number
    {
        return this.code;
    }
}