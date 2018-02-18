import * as $ from "jquery";

/**
 * Injects an overlay into the domSelector
 * that shows a loader.  The overlay
 * will consume 100% height and width of the closet
 * parent element with a position type that is not "static".
 * (i.e. relation, absolute, etc).
 */
export class OverlayLoader
{
    private _domSelector: string;

    public constructor(domSelector: string)
    {
        this._domSelector = domSelector;
    }

    public render(): void
    {
        if (this.loaderAlreadyPresentInDOM()) {
            return;
        }

        $(this._domSelector).append(
            `<div class="overlayLoader">
                <img src="/images/loader.gif" width="80" height="80" />
            </div>`
        );
    }

    public remove(): void
    {
        $(this._domSelector + ' div.overlayLoader').remove();
    }

    private loaderAlreadyPresentInDOM(): boolean
    {
        return $(this._domSelector).find('div.overlayLoader').length > 0;
    }
}