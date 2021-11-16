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

class CustomMenuView: NSView {

  /// This toggle changes the background color and should be enabled if the parent menu item is set to isAlternate = true
  var enableAlternateBackgroundColor = false

  @IBOutlet weak var cursiveLabel: NSTextField!

  private var effectView: NSVisualEffectView
  private let standardColor = NSColor(red: 0xa6/0xff, green: 0xec/0xff, blue: 0xec/0xff, alpha: 1)
  private let alternativeColor = NSColor(red: 0xec/0xff, green: 0xec/0xff, blue: 0xa6/0xff, alpha: 1)

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

    debugPrint("Draw Custom")
    
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
