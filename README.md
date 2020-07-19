# TakeoutMenu-macOS
Sample project to demonstrate unexpected behavior with NSMenuItems with custom views

This example app attempts to demonstrate an issue I'm facing with NSMenuItem.  This app creates a menu in the status bar.  Using standard NSMenuItems, we are able to set isAlternate.  By holding OPTION we can switch out the default for the alternate.    When we enable a customView isAlternate doesn't work as expected.  Instead both the standard and alternate are displayed at all times.  Holding OPTION does not toggle between the two as it does with the standard NSMenuItems.
