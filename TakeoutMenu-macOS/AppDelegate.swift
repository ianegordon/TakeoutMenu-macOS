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

//TODO: Support Modifier Keys: Command, Control, Shift, Option (alias Alternate)
// From: https://cool8jay.github.io/shortcut-nemenuitem-nsbutton/
// In Apple’s Human Interface Guidelines, this menu item is called Dynamic Menu Items, and invisible by default.

// LINK: Tracking modifier keys
// https://www.generacodice.com/en/articolo/4433510/hide-show-menu-item-in-application-s-main-menu-by-pressing-option-key

// LINK: Hacking NSMenu Keyboard Navigation  (Very helpful)
// https://kazakov.life/2017/05/18/hacking-nsmenu-keyboard-navigation/

import Cocoa
import Carbon

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  var eventHandlerRef: EventHandlerRef?
  var optionModifierEnabled: Bool = false
  
  var menu = NSMenu(title: "<unused>")
  var customMenuDelegate = CustomDelegate()
  var customMenuItems = [NSMenuItem]()
  
  let statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    debugPrint("App Delegate \(self)")
    
    // Setup Status Bar
    let iconImage = NSImage.init(named: "StatusBarIcon")
    self.statusItem.button?.image = iconImage
    self.statusItem.button?.title = "∞"
    self.statusItem.button?.imagePosition = .imageLeading
    self.statusItem.button?.target = self
    self.statusItem.button?.action = #selector(statusBarClicked) // This appears to never get called?
    
    // Setup Menu
    menu.autoenablesItems = false
    menu.delegate = customMenuDelegate
    self.populateMenu()
    self.statusItem.menu = menu
    
    
    // Attach Carbon Event Listener / Handler
    attachCarbonEventHandling( {
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
    // This appears to never get called?
    print("APP : statusBarClicked")
  }
  
  @objc func menuItemClicked(sender: Any) {
    let senderLabel: String
    if let menuItem = sender as? NSMenuItem {
      senderLabel = menuItem.debugDescription
    } else {
      senderLabel = "Unknown Sender"
    }
    
    let modifierFlags = NSApp.currentEvent?.modifierFlags
    let isOption = modifierFlags?.contains(.option)
    let isCommand = modifierFlags?.contains(.command)
    let isControl = modifierFlags?.contains(.control)
    
    print("APP : menuItemClicked \(senderLabel) - \(isCommand):\(isOption):\(isControl)")
  }
  
  @objc func optionMenuItemClicked(sender: Any) {
    let senderLabel: String
    if let menuItem = sender as? NSMenuItem {
      senderLabel = menuItem.debugDescription
    } else {
      senderLabel = "Unknown Sender"
    }
    print("APP : optionMenuItemClicked \(senderLabel)")
  }
  
  @objc func quitClicked() {
    print("APP : quitClicked")
    
    RemoveEventHandler(eventHandlerRef)
    
    NSApp.terminate(nil)
  }
  
  // MARK: Internal
  //TODO: Should this menu get generated once and then items added, removed, and adjusted?
  func populateMenu() {
    debugPrint("POPULATE MENU")

    // Deprecated
    // Useless after macOS 10.6
    // Disable partial changes
    // LINK
    // https://stackoverflow.com/a/3298494
    // self.statusItem.menu?.menuChangedMessagesEnabled = false
    
    // https://www.generacodice.com/en/articolo/4433510/hide-show-menu-item-in-application-s-main-menu-by-pressing-option-key
    // Get global modifier key flag, [[NSApp currentEvent] modifierFlags] doesn't update while menus are down
    //    CGEventRef event = CGEventCreate (NULL);
    //    CGEventFlags flags = CGEventGetFlags (event);
    //    BOOL optionKeyIsPressed = (flags & kCGEventFlagMaskAlternate) == kCGEventFlagMaskAlternate;
    //    CFRelease(event);
    
    //TODO: Capture modifer mask and utilize in the custom draw rather than just capturing the state of .option
    //???: Should this set optionModifierEnabled to false if the modifier flag does NOT contain .option?
    if let event = NSApplication.shared.currentEvent {
      if event.modifierFlags.contains(.option) {
        optionModifierEnabled = true
      }
    }
    
    if optionModifierEnabled {
      debugPrint("OPTION GENERATE MENU OPTION GENERATE MENU OPTION GENERATE MENU")
    } else {
      debugPrint("no option GENERATE MENU no option GENERATE MENU no option GENERATE MENU")
    }
    
    menu.removeAllItems()
    customMenuItems.removeAll()
    
    //KMKMKM
    //    let menu = NSMenu(title: "<Unused>")
    //    menu.autoenablesItems = false
    
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
      
      //NOTE: keyEquivalent handling is pushed to two hidden menuItems below (standard and option)
      let customItem = NSMenuItem(title: title, action: #selector(menuItemClicked), keyEquivalent: "")
      if Bundle.main.loadNibNamed("CustomMenuView", owner: self, topLevelObjects: &topLevelObjects) {
        let xibView = topLevelObjects!.first(where: { $0 is CustomMenuView }) as? CustomMenuView
        if let itemView = xibView {
          itemView.cursiveLabel.stringValue = title
          
          //!!! If we do not explicitly set the size, the menu will use the starting size from the XIB.
          itemView.frame = CGRect(origin: .zero, size: itemView.fittingSize)
          
          customItem.view = itemView
          //???: Do I need customItem.target = self
          // customItem.target = self
        }
      }
      menu.addItem(customItem)
      customMenuItems.append(customItem)
      
      // Hidden Entries to handle key equivalents
      let key = "\(index)"
      
      let standardItem = NSMenuItem(title: title, action: #selector(menuItemClicked), keyEquivalent: key)
      standardItem.isHidden = true
      standardItem.allowsKeyEquivalentWhenHidden = true
      menu.addItem(standardItem)
      
      let optionTitle = "OPTION + " + title
      let optionItem = NSMenuItem(title: optionTitle, action: #selector(optionMenuItemClicked), keyEquivalent: key)
      optionItem.keyEquivalentModifierMask = [ .option ]
      optionItem.isHidden = true
      optionItem.allowsKeyEquivalentWhenHidden = true
      menu.addItem(optionItem)
    }
    
    for index in 5...6 {
      var topLevelObjects : NSArray?
      
      let title: String
      if optionModifierEnabled {
        title = "OPTION + [Bulletin Menu Item \(index)]"
      } else {
        title = "ZZZ + [Bulletin Menu Item \(index)]"
      }
      
      //NOTE: keyEquivalent handling is pushed to two hidden menuItems below (standard and option)
      let customItem = NSMenuItem(title: title, action: #selector(menuItemClicked), keyEquivalent: "")
      if Bundle.main.loadNibNamed("BulletinMenuItemView", owner: self, topLevelObjects: &topLevelObjects) {
        let xibView = topLevelObjects!.first(where: { $0 is BulletinMenuItemView }) as? BulletinMenuItemView
        if let itemView = xibView {
          itemView.bulletinLabel.stringValue = title
          itemView.detailLabel.stringValue = "details, details, details"
          
          //!!! If we do not explicitly set the size, the menu will use the starting size from the XIB.
          itemView.frame = CGRect(origin: .zero, size: itemView.fittingSize)
          
          customItem.view = itemView
          //???: Do I need customItem.target = self
          // customItem.target = self
        }
      }
      menu.addItem(customItem)
      customMenuItems.append(customItem)
      
      // Hidden Entries to handle key equivalents
      let key = "\(index)"
      
      let standardItem = NSMenuItem(title: title, action: #selector(menuItemClicked), keyEquivalent: key)
//      standardItem.isHidden = true
      standardItem.allowsKeyEquivalentWhenHidden = true
      menu.addItem(standardItem)
      
      let optionTitle = "OPTION + " + title
      let optionItem = NSMenuItem(title: optionTitle, action: #selector(optionMenuItemClicked), keyEquivalent: key)
      optionItem.keyEquivalentModifierMask = [ .option ]
      optionItem.isHidden = true
      optionItem.allowsKeyEquivalentWhenHidden = true
      menu.addItem(optionItem)
    }
    
    menu.addItem(NSMenuItem.separator())
    
    //NOTE: Lowercase key equivalent is used to avoid adding the shift modifier
    let quitItem = NSMenuItem(title: "Quit", action: #selector(quitClicked), keyEquivalent: "q")
    quitItem.keyEquivalentModifierMask = [ .command ]
    menu.addItem(quitItem)
  }
  
  // Link: Possible solution from Daniel (Slack)
  // https://iosdevelopers.slack.com/archives/C035R3WTC/p1622598265061200
  private func attachCarbonEventHandling(_ block: () -> ()) {
    let eventTypes: [EventTypeSpec] = [
      // KEYBOARD
      EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventRawKeyModifiersChanged)),
      EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed)),
      EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyReleased)),
      EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventRawKeyDown)),
      // MENU
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuOpening)),
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuClosed)),
      // Use Populate instead of Opening according to the Carbon Reference
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuPopulate)),
      // Handle Hotkeys
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuMatchKey)),
      // Switch between keyboard and mouse tracking
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuChangeTrackingMode)),
      // Tracking
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuBeginTracking)),
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuEndTracking)),
      // Select Item
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuTargetItem)),
      // Draw Item
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: OSType(kEventMenuDrawItem)),
    ]
    
    // Link: Handling OSStatus (SO)
    // https://stackoverflow.com/questions/2196869/how-do-you-convert-an-iphone-osstatus-code-to-something-useful
    // Link: Carbon Event Handler status
    // http://mirror.informatimago.com/next/developer.apple.com/documentation/Carbon/Reference/Carbon_Event_Manager_Ref/CarbonEventsRef/ResultCodes.html#//apple_ref/doc/uid/TP30000135/RCM0141
    
    // GIST: Installing on Menu
    // https://gist.github.com/p0deje/da5e5cfda6be8cb87c2e7caad3a3df63
    
    // Install Carbon event handler for the application
    //   to hear about modifier keys and monitor menu tracking
    let appDelegateRaw = Unmanaged.passUnretained(self).toOpaque()
    let status = InstallEventHandler(GetApplicationEventTarget(),
                                     AppDelegate.menuTrackingEventHandler,
                                     eventTypes.count,
                                     eventTypes,
                                     appDelegateRaw,
                                     &eventHandlerRef)
    if status == noErr {
      debugPrint("InstallEventHandler success")
    } else {
      debugPrint("ERROR: InstallEventHandler : \(status)")
    }
    
  }
  
  //  (_ inHandlerCallRef: EventHandlerCallRef?, _ eventRef: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus in {
  static private let menuTrackingEventHandler: EventHandlerProcPtr = {
    (callRef: EventHandlerCallRef?, eventRef: EventRef?, rawPointer: UnsafeMutableRawPointer?) -> OSStatus in

    guard eventRef != nil && rawPointer != nil else {
      print("**** Nil eventRef or rawPointer")
      return noErr
    }

    let date = Date()
    
    let appDelegate: AppDelegate
    
    // Extract our appDelegate
    guard let appDelegateRaw = rawPointer?.assumingMemoryBound(to: AppDelegate.self) else {
      // YSNBH
      assert(false)
      return -1
    }
    appDelegate = Unmanaged<AppDelegate>.fromOpaque(appDelegateRaw).takeUnretainedValue()
    //FIXME    debugPrint("appDelegate : menuTrackingEventHandler : \(appDelegate)")
    
    // Extract Event types and parameters
    let eventClass = GetEventClass(eventRef)
    let eventKind = GetEventKind(eventRef)
    
    // KEYBOARD KEYBOARD KEYBOARD KEYBOARD
    
    if eventClass == OSType(kEventClassKeyboard) {
      if eventKind == OSType(kEventHotKeyPressed) {
        //???: WHY IS THIS NOT INVOKED?
        debugPrint("!!! kEventHotKeyPressed")
      } else if eventKind == OSType(kEventHotKeyReleased) {
        //???: WHY IS THIS NOT INVOKED?
        debugPrint("!!! kEventHotKeyReleased")
      } else if eventKind == OSType(kEventRawKeyDown) {
        debugPrint("!!! kEventRawKeyDown")
        // IFF this is enter AND a Custom Menu View is selected, invoke the menu item's action (including modifier values) and close menu
        if let itemSelected = appDelegate.menu.highlightedItem {
//           type(of: itemSelected.isLike) == CustomMenuView.Type {
          print("itemSelected - \(itemSelected)")
        }
      } else if eventKind == OSType(kEventRawKeyModifiersChanged) {
        //???: Why is this invoked twice?
        var regenerateMenu = false
        var modifierKeys: UInt32 = 0
        let status = GetEventParameter(eventRef,
                                       EventParamName(kEventParamKeyModifiers),
                                       EventParamType(typeUInt32),
                                       nil,
                                       MemoryLayout.size(ofValue: modifierKeys),
                                       nil,
                                       &modifierKeys)
        var commandOnly = false // Is command the only key engaged right now, if so skip
        var modifierKeysString = ""
        if modifierKeys & OSType(cmdKey) != 0 {
          modifierKeysString += " Command"
          commandOnly = true
        }
        if modifierKeys & OSType(controlKey) != 0 {
          modifierKeysString += " Control"
          commandOnly = false
        }
        
        if modifierKeys & OSType(optionKey) != 0 {
          modifierKeysString += " Option"
          commandOnly = false
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
        
        if !commandOnly {
          debugPrint("menuTrackingEventHandler - \(date) - kEventClassKeyboard - kEventRawKeyModifiersChanged - \(modifierKeysString)")
          if regenerateMenu {
            let title: String
            if appDelegate.optionModifierEnabled {
              title = "OPTION + [Custom Menu Item]"
            } else {
              title = "ZZZ + [Custom Menu Item]"
            }
            
            for menuItem in appDelegate.customMenuItems {
              if let customView = menuItem.view as? CustomMenuView {
                customView.cursiveLabel.stringValue = title
                menuItem.title = title
              }
            }
          }
        } else {
          debugPrint("menuTrackingEventHandler - \(date) - kEventClassKeyboard - kEventRawKeyModifiersChanged - COMMAND-ONLY")
        }
      }
      
      // MENU MENU MENU MENU MENU MENU MENU
    } else if eventClass == OSType(kEventClassMenu) {
      if eventKind == OSType(kEventMenuTargetItem) {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuTargetItem")
      } else if eventKind == OSType(kEventMenuBeginTracking) {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuBeginTracking")
      } else if eventKind == OSType(kEventMenuEndTracking) {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuEndTracking")
        appDelegate.optionModifierEnabled = false
      } else if eventKind == OSType(kEventMenuDrawItem) {
        //        *    --> kEventParamMenuItemIndex (in, typeMenuItemIndex)
        var drawIndex: MenuItemIndex = 0
        let status = GetEventParameter(eventRef,
                                       EventParamName(kEventParamMenuItemIndex),
                                       EventParamType(typeMenuItemIndex),
                                       nil,
                                       MemoryLayout.size(ofValue: drawIndex),
                                       nil,
                                       &drawIndex)
        
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuDrawItem")
      } else if eventKind == OSType(kEventMenuPopulate) {
        var menuContext: UInt32 = 0
        let contextStatus = GetEventParameter(eventRef,
                                              EventParamName(kEventParamMenuContext),
                                              EventParamType(typeUInt32),
                                              nil,
                                              MemoryLayout.size(ofValue: menuContext),
                                              nil,
                                              &menuContext)
        var menuCommand: MenuCommand = 0
        let commandStatus = GetEventParameter(eventRef,
                                              EventParamName(kEventParamMenuCommand),
                                              EventParamType(typeMenuCommand),
                                              nil,
                                              MemoryLayout.size(ofValue: menuCommand),
                                              nil,
                                              &menuCommand)
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuPopulate - \(menuContext) : \(menuCommand)")
        // TODO: Regenerate Menu
        appDelegate.populateMenu()
      } else if eventKind == OSType(kEventMenuOpening) {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuOpening")
      } else if eventKind == OSType(kEventMenuClosed) {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuClosed")
      } else if eventKind == OSType(kEventMenuChangeTrackingMode) {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuChangeTrackingMode")
      } else if eventKind == OSType(kEventMenuMatchKey) {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kEventMenuMatchKey")
      } else {
        debugPrint("menuTrackingEventHandler - \(date) - kEventClassMenu - kUKNOWN")
      }
    } else {
      debugPrint("menuTrackingEventHandler !!!UNHANDLED!!! - \(date) - \(eventClass) - \(eventKind)")
    }
    
    return CallNextEventHandler(callRef, eventRef)
  }
  
}


