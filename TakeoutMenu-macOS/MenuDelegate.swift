//
//  MenuDelegate.swift
//  TakeoutMenu-macOS
//
//  Created by Ian Gordon on 11/30/21.
//  Copyright © 2021 Ian Gordon. All rights reserved.
//

import AppKit

class CustomDelegate: NSObject, NSMenuDelegate {

  /// Handling Keyboard Equivalents

  // Invoked to allow the delegate to return the target and action for a key-down event.
  func menuHasKeyEquivalent(
      _ menu: NSMenu,
      for event: NSEvent,
      target: AutoreleasingUnsafeMutablePointer<AnyObject?>,
      action: UnsafeMutablePointer<Selector?>
  ) -> Bool {
    //???: Why is this NOT CALLED
    debugPrint("!!! THIS IS NEVER CALLED menuHasKeyEquivalent")
    return true
  }
  
  /// Updating Menu Layout
  
  func menu(
      _ menu: NSMenu,
      update item: NSMenuItem,
      at index: Int,
      shouldCancel: Bool
  ) -> Bool {
    debugPrint("MenuDelegate : menu:update:at:shouldCancel")
    return true
  }

  // Invoked to allow the delegate to specify a display location for the menu.
//  func confinementRect(
//      for menu: NSMenu,
//      on screen: NSScreen?
//  ) -> NSRect
  
  // Invoked to indicate that a menu is about to highlight a given item.
  func menu(_ menu: NSMenu,
            willHighlight item: NSMenuItem?) {
    debugPrint("MenuDelegate : menu:willHighlight:")
  }
  
  // Invoked when a menu is about to open.
  func menuWillOpen(_ menu: NSMenu) {
    debugPrint("MenuDelegate : menuWillOpen")
  }
  
  // Invoked after a menu closed.
  func menuDidClose(_ menu: NSMenu) {
    debugPrint("MenuDelegate : menuDidClose")
  }
  
  /// HANDLE TRACKING

  // Invoked when a menu is about to be displayed at the start of a tracking session so the delegate
  // can specify the number of items in the menu.
//  func numberOfItems(in menu: NSMenu) -> Int
  
  // Invoked when a menu is about to be displayed at the start of a tracking session.
  func menuNeedsUpdate(_ menu: NSMenu) {
    debugPrint("MenuDelegate : menuNeedsUpdate")
  }
}
