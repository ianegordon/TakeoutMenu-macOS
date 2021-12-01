//
//  MenuDelegate.swift
//  TakeoutMenu-macOS
//
//  Created by Ian Gordon on 11/30/21.
//  Copyright © 2021 Ian Gordon. All rights reserved.
//

import AppKit

class CustomDelegate: NSObject, NSMenuDelegate {

  func menuWillOpen(_ menu: NSMenu) {
    debugPrint("Delegate : menuWillOpen")
  }
  
  func menuDidClose(_ menu: NSMenu) {
    debugPrint("Delegate : menuDidClose")
  }
  
  func menuHasKeyEquivalent(_ menu: NSMenu,
                                 for event: NSEvent,
                              target: AutoreleasingUnsafeMutablePointer<AnyObject?>,
                            action: UnsafeMutablePointer<Selector?>) -> Bool {
    //???: Why is this NOT CALLED
    debugPrint("!!! THIS IS NEVER CALLED menuHasKeyEquivalent")
    return false
  }
  
  func menu(_ menu: NSMenu,
            willHighlight item: NSMenuItem?) {
    debugPrint("Delegate : menu:willHighlight:")
  }
  
  func menuNeedsUpdate(_ menu: NSMenu) {
    debugPrint("Delegate : menuNeedsUpdate")
  }
}
