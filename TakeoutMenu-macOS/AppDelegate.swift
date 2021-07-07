/*
 MIT License

 Copyright (c) 2020 Ian Gordon

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Cocoa
import Carbon

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var eventHandlerRef: EventHandlerRef?
  var optionModifierEnabled: Bool = false

  let statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)

  func applicationDidFinishLaunching(_ aNotification: Notification) {

    debugPrint("App Delegate \(self)")

    // Setup Status Bar
    let iconImage = NSImage.init(named: "StatusBarIcon")
    self.statusItem.button?.image = iconImage
    self.statusItem.button?.title = "∞"
    self.statusItem.button?.imagePosition = .imageLeading
    self.statusItem.button?.target = self
    self.statusItem.button?.action = #selector(statusBarClicked)

    // Generate Menu
    self.generateMenu()

    // Attach Carbon Event Listener / Handler
    performWithCarbonEventHandling( {
      debugPrint("Block")
    }
    )
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Remove Status Bar
    NSStatusBar.system.removeStatusItem(self.statusItem)
  }

  //MARK: Actions
  @objc func statusBarClicked() {
    print("statusBarClicked")
  }

  @objc func menuItemClicked() {
    print("menuItemClicked")
  }

  @objc func optionMenuItemClicked() {
    print("optionMenuItemClicked")
  }

  @objc func quitClicked() {
    print("quitClicked")

    RemoveEventHandler(eventHandlerRef)

    NSApp.terminate(nil)
  }

  // MARK: Internal
  func generateMenu() {
    let menu = NSMenu(title: "<Unused>")
    menu.autoenablesItems = false

    // Basic
    for index in 1...2 {
      let title = "[Standard Menu Item \(index)]"

      let key = "\(index)"
      let standardItem = NSMenuItem(title: title, action: #selector(menuItemClicked), keyEquivalent: key)
      menu.addItem(standardItem)

      let optionTitle = "OPTION + " + title
      let optionItem = NSMenuItem(title: optionTitle, action: #selector(optionMenuItemClicked), keyEquivalent: key)
      optionItem.isAlternate = true
      optionItem.keyEquivalentModifierMask = [ .option ]
      menu.addItem(optionItem)
    }

    for index in 3...4 {
      var topLevelObjects : NSArray?

      let title: String
      if optionModifierEnabled {
        title = "OPTION + [Custom Menu Item \(index)]"
      } else {
        title = "ZZZ + [Custom Menu Item \(index)]"
      }

      let key = "\(index)"

      //TODO: Identify why keyEquivalent isn't working
      let customItem = NSMenuItem(title: "<Unused>", action: #selector(menuItemClicked), keyEquivalent: key)
      if Bundle.main.loadNibNamed("CustomMenuView", owner: self, topLevelObjects: &topLevelObjects) {
        let xibView = topLevelObjects!.first(where: { $0 is CustomMenuView }) as? CustomMenuView
        if let itemView = xibView {
          itemView.cursiveLabel.stringValue = title

          //!!! If we do not explicitly set the size, the menu will use the starting size from the XIB.
          itemView.frame = CGRect(origin: .zero, size: itemView.fittingSize)

          customItem.view = itemView
        }
      }
      menu.addItem(customItem)

      // The following item does NOT work as expected
      // Rather than providing an alternative item if the OPTION modifer is pressed, this item is just added inline
      // to the standard menu.
//      let optionCustomItem = NSMenuItem(title: "<Unused>", action: #selector(optionMenuItemClicked), keyEquivalent: key)
//      optionCustomItem.isAlternate = true
//      optionCustomItem.keyEquivalentModifierMask = [ .option ]
//      if Bundle.main.loadNibNamed("CustomMenuView", owner: self, topLevelObjects: &topLevelObjects) {
//        let xibView = topLevelObjects!.first(where: { $0 is CustomMenuView }) as? CustomMenuView
//        if let itemView = xibView {
//          itemView.cursiveLabel.stringValue = "OPTION + " + title
//
//          //!!! If we do not explicitly set the size, the menu will use the starting size from the XIB.
//          itemView.frame = CGRect(origin: .zero, size: itemView.fittingSize)
//          itemView.enableAlternateBackgroundColor = true
//
//          optionCustomItem.view = itemView
//        }
//      }
//      menu.addItem(optionCustomItem)

    }

    menu.addItem(NSMenuItem.separator())

    //NOTE: Lowercase key equivalent is used to avoid adding the shift modifier
    let quitItem = NSMenuItem(title: "Quit", action: #selector(quitClicked), keyEquivalent: "q")
    quitItem.keyEquivalentModifierMask = [ .command ]
    menu.addItem(quitItem)

    self.statusItem.menu = menu
  }

  // Link: Possible solution from Daniel (Slack)
  // https://iosdevelopers.slack.com/archives/C035R3WTC/p1622598265061200
  private func performWithCarbonEventHandling(_ block: () -> ()) {
    let eventTypes: [EventTypeSpec] = [
      EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventRawKeyModifiersChanged)),
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuTargetItem)),
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuBeginTracking)),
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuEndTracking)),
    ]

    // Link: Handling OSStatus (SO)
    // https://stackoverflow.com/questions/2196869/how-do-you-convert-an-iphone-osstatus-code-to-something-useful
    // Link: Carbon Event Handler status
    // http://mirror.informatimago.com/next/developer.apple.com/documentation/Carbon/Reference/Carbon_Event_Manager_Ref/CarbonEventsRef/ResultCodes.html#//apple_ref/doc/uid/TP30000135/RCM0141

    // Install Carbon event handler to hear about modifier keys and monitor menu tracking
    let appDelegateRaw = Unmanaged.passUnretained(self).toOpaque()
    let status = InstallEventHandler(GetApplicationEventTarget(), AppDelegate.menuTrackingEventHandler, eventTypes.count, eventTypes, appDelegateRaw, &eventHandlerRef)
    if status == noErr {
      debugPrint("InstallEventHandler == noErr")
    } else {
      debugPrint("InstallEventHandler != noErr")
    }
  }

//  (_ inHandlerCallRef: EventHandlerCallRef?, _ eventRef: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus in {
  static private let menuTrackingEventHandler: EventHandlerProcPtr = {
    (callRef: EventHandlerCallRef?, eventRef: EventRef?, rawPointer: UnsafeMutableRawPointer?) in
    let date = Date()

    let appDelegate: AppDelegate

    guard let appDelegateRaw = rawPointer?.assumingMemoryBound(to: AppDelegate.self) else {
      // YSNBH
      return -1
    }

    appDelegate = Unmanaged<AppDelegate>.fromOpaque(appDelegateRaw).takeUnretainedValue()
    debugPrint("appDelegate : \(appDelegate)")

    let eventClass = GetEventClass(eventRef)
    let eventKind = GetEventKind(eventRef)
    //    EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventRawKeyModifiersChanged)),
    //    EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuTargetItem)),
    //    EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuBeginTracking)),
    //    EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuEndTracking)),
    if eventClass == OSType(kEventClassKeyboard) && eventKind == OSType(kEventRawKeyModifiersChanged) {
      var regenerateMenu = false
      var modifierKeys: UInt32 = 0
      let modifer = GetEventParameter(eventRef,
                                      EventParamName(kEventParamKeyModifiers),
                                      typeUInt32,
                                      nil,
                                      MemoryLayout.size(ofValue: modifierKeys),
                                      nil,
                                      &modifierKeys)
      var modifierKeysString = ""
      if modifierKeys & OSType(cmdKey) != 0 {
        modifierKeysString += " Command"
      }
      if modifierKeys & OSType(controlKey) != 0 {
        modifierKeysString += " Control"
      }
      if modifierKeys & OSType(optionKey) != 0 {
        modifierKeysString += " Option"
        if !appDelegate.optionModifierEnabled {
          appDelegate.optionModifierEnabled = true
          regenerateMenu = true
        }
      } else {
        if appDelegate.optionModifierEnabled {
          appDelegate.optionModifierEnabled = false
          regenerateMenu = true
        }
      }
      debugPrint("menuTrackingEventHandler - \(date) - kEventClassKeyboard - kEventRawKeyModifiersChanged - \(modifierKeysString)")
      if regenerateMenu {
        debugPrint("TODO: REGENERATE MENU")
        appDelegate.generateMenu()
      }
    } else if eventClass == OSType(kEventClassMenu) {
      if eventKind == OSType(kEventMenuTargetItem) {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuTargetItem")
      } else if eventKind == OSType(kEventMenuBeginTracking) {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuBeginTracking")
        // TODO: Add Modifier Watcher
      } else if eventKind == OSType(kEventMenuEndTracking) {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuEndTracking")
        // TODO: Remove Modifier Watcher
      } else {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kUKNOWN")
      }
    } else {
      debugPrint("menuTrackingEventHandler - \(date) - \(eventClass) - \(eventKind)")
    }
    return 0
  }
}


