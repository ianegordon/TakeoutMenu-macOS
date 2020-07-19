import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  let statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Setup Status Bar
    let iconImage = NSImage.init(named: "StatusBarIcon")
    self.statusItem.button?.image = iconImage
    self.statusItem.button?.title = "∞"
    self.statusItem.button?.imagePosition = .imageLeading
    self.statusItem.button?.target = self
    self.statusItem.button?.action = #selector(statusBarClicked)

    // Generate Menu
    self.generateMenu()
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

      let title = "[Custom Menu Item \(index)]"

      let key = "\(index)"

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

      let optionCustomItem = NSMenuItem(title: "<Unused>", action: #selector(optionMenuItemClicked), keyEquivalent: key)
      optionCustomItem.isAlternate = true
      optionCustomItem.keyEquivalentModifierMask = [ .option ]
      if Bundle.main.loadNibNamed("CustomMenuView", owner: self, topLevelObjects: &topLevelObjects) {
        let xibView = topLevelObjects!.first(where: { $0 is CustomMenuView }) as? CustomMenuView
        if let itemView = xibView {
          itemView.cursiveLabel.stringValue = "OPTION + " + title

          //!!! If we do not explicitly set the size, the menu will use the starting size from the XIB.
          itemView.frame = CGRect(origin: .zero, size: itemView.fittingSize)
          itemView.enableAlternateBackgroundColor = true

          optionCustomItem.view = itemView
        }
      }
      menu.addItem(optionCustomItem)

    }

    menu.addItem(NSMenuItem.separator())

    //NOTE: Lowercase key equivalent is used to avoid adding the shift modifier
    let quitItem = NSMenuItem(title: "Quit", action: #selector(quitClicked), keyEquivalent: "q")
    quitItem.keyEquivalentModifierMask = [ .command ]
    menu.addItem(quitItem)

    self.statusItem.menu = menu
  }

}

