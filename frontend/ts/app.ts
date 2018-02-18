import { AppFactory } from "./appFactory";
import * as $ from "jquery";

const myWindow: any = window;
myWindow.AppFactory = new AppFactory();
myWindow.$ = $;
myWindow.jQuery = $;
