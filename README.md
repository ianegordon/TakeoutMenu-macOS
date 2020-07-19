# TakeoutMenu-macOS
Sample project to demonstrate unexpected behavior with NSMenuItems with custom views

This issue has been discussed on Stack Overflow, but I have not yet been able to find a solution.
[Stack Overflow: Alternative Menu Items in NSMenu](https://stackoverflow.com/questions/2606599/alternative-menu-items-in-nsmenu)

![Takeout Menu Screenshot](https://github.com/ianegordon/TakeoutMenu-macOS/blob/master/Docs/TakeoutMenuScreenshot.png?raw=true)

This example app attempts to demonstrate an issue I'm facing with NSMenuItem.  This app creates a menu in the status bar.  Using standard NSMenuItems, we are able to set isAlternate.  By holding OPTION we can switch out the default for the alternate.    When we enable a customView isAlternate doesn't work as expected.  Instead both the standard and alternate are displayed at all times.  Holding OPTION does not toggle between the two as it does with the standard NSMenuItems.
