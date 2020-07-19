import Cocoa

class CustomMenuView: NSView {

  /// This toggle changes the background color and should be enabled if the parent menu item is set to isAlternate = true
  var enableAlternateBackgroundColor = false

  @IBOutlet weak var cursiveLabel: NSTextField!

  private var effectView: NSVisualEffectView
  private let standardColor = NSColor(red: 0xa6/255, green: 0xec/255, blue: 0xec/255, alpha: 1)
  private let alternativeColor = NSColor(red: 0xec/255, green: 0xec/255, blue: 0xa6/255, alpha: 1)

  required init?(coder decoder: NSCoder) {
    effectView = NSVisualEffectView()
    effectView.state = .active
    effectView.material = .selection
    effectView.isEmphasized = true
    effectView.blendingMode = .behindWindow
    effectView.autoresizingMask = [.width, .height]

    super.init(coder: decoder)

    self.addSubview(effectView, positioned: .below, relativeTo: nil)
    effectView.frame = self.bounds

    self.autoresizingMask = [.width, .height]
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    let foregroundColor: NSColor

    if self.enclosingMenuItem != nil,
      self.enclosingMenuItem!.isHighlighted {
      foregroundColor = NSColor.selectedMenuItemTextColor
      effectView.isHidden = false
    } else {
      foregroundColor = NSColor.labelColor
      effectView.isHidden = true
    }

    self.cursiveLabel.textColor = foregroundColor

    if self.enableAlternateBackgroundColor {
      alternativeColor.setFill()
    } else {
      standardColor.setFill()
    }

    dirtyRect.fill()
  }

  /// Custom implementation of mouseUp that will invoke the target/action from the enclosing menuitem
  override func mouseUp(with event: NSEvent) {
    if let menuItem = self.enclosingMenuItem,
      let menu = menuItem.menu {
      menu.cancelTracking()
      let itemIndex = menu.index(of: menuItem)
      menu.performActionForItem(at: itemIndex)
    }
  }
}
