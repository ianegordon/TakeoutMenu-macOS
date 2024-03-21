import AppKit

class BulletinMenuItemView: NSView {
  @IBOutlet weak var leadingImageView: NSImageView!
  @IBOutlet weak var bulletinLabel: NSTextField!
  @IBOutlet weak var detailLabel: NSTextField!
  @IBOutlet weak var progressIndicator: NSProgressIndicator!
  @IBOutlet weak var sealImage: NSImageView!
  @IBOutlet weak var shieldImage: NSImageView!
  
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }

  override func draw(_ dirtyRect: NSRect) {
    let foregroundColor: NSColor

    if self.enclosingMenuItem != nil,
      self.enclosingMenuItem!.isHighlighted
    {

      foregroundColor = NSColor.selectedMenuItemTextColor

      // Explicitly render the background to mimic standard menu item behavior
      // TODO: NSColor.selectedMenuItemColor is deprecated
      let backgroundColor = NSColor.selectedMenuItemColor

      backgroundColor.set()
      NSBezierPath.fill(dirtyRect)
    } else {
      foregroundColor = NSColor.labelColor
    }

    self.leadingImageView.contentTintColor = foregroundColor
    self.bulletinLabel.textColor = foregroundColor
    self.detailLabel.textColor = foregroundColor

    super.draw(dirtyRect)
  }

  // To enable mouse handling with a custom view
  // https://stackoverflow.com/questions/1395556/custom-nsview-in-nsmenuitem-not-receiving-mouse-events
  //  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
  //    return true
  //  }

  // To enable mouse handling with a custom view
  // https://stackoverflow.com/questions/1395556/custom-nsview-in-nsmenuitem-not-receiving-mouse-events
  override func mouseUp(with event: NSEvent) {
    print("BMI - Left Event: \(event)")
    if let menuItem = self.enclosingMenuItem,
      let menu = menuItem.menu
    {
      menu.cancelTracking()
      let itemIndex = menu.index(of: menuItem)
      menu.performActionForItem(at: itemIndex)

      // HACKHACKHACK
      // We remove then re-insert the menu item so it will return to a non-highlighted state
      // https://stackoverflow.com/questions/6169930/remove-highlight-from-nsmenuitem-after-click
      menu.removeItem(menuItem)
      menu.insertItem(menuItem, at: itemIndex)
    }
  }

  override func rightMouseUp(with event: NSEvent) {
    print("BMI - Right Event: \(event)")
  }
}
