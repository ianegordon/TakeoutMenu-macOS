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

// LINK: SO: How to get smooth corners with an NSVisualEffectsView
// https://stackoverflow.com/questions/26518520/how-to-make-a-smooth-rounded-volume-like-os-x-window-with-nsvisualeffectview

import Cocoa

class CustomMenuView: NSView {
  
  /// This toggle changes the background color and should be enabled if the parent menu item is set to isAlternate = true
  var enableAlternateBackgroundColor = false
  
  @IBOutlet weak var cursiveLabel: NSTextField!
  
  private let highlightEffectView: NSVisualEffectView
  
  //TODO Identify proper system colors for standard and highlighted background
//  private let standardColor = NSColor(red: 0xa6/0xff, green: 0xec/0xff, blue: 0xec/0xff, alpha: 1)
//  private let alternativeColor = NSColor(red: 0xec/0xff, green: 0xec/0xff, blue: 0xa6/0xff, alpha: 1)
//  private let standardColor = NSColor(red: 0xa6/0xff, green: 0x00/0xff, blue: 0xec/0xff, alpha: 1)
  private let standardColor = NSColor.textBackgroundColor
  private let alternativeColor = NSColor(red: 0xec/0xff, green: 0xec/0xff, blue: 0x00/0xff, alpha: 1)

  required init?(coder decoder: NSCoder) {
    highlightEffectView = NSVisualEffectView()
    highlightEffectView.state = .active
    highlightEffectView.material = .selection
    highlightEffectView.isEmphasized = true
    highlightEffectView.blendingMode = .behindWindow
    highlightEffectView.autoresizingMask = [.width, .height]
    //TODO: Identify way to inset round rect to bound the effect view
//    effectView.wantsLayer = true
//    effectView.layer?.frame = effectView.bounds
//    effectView.layer?.cornerRadius = 8
//    effectView.layer?.masksToBounds = true
//    effectView.layer?.maskedCorners = true
    
    super.init(coder: decoder)
    
    self.addSubview(highlightEffectView, positioned: .below, relativeTo: nil)
    highlightEffectView.frame = self.bounds
    
    self.autoresizingMask = [.width, .height]
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    let isHighlighted: Bool
    let isAlternativeBackground: Bool  // KMKMKM Used for logging only
    
    let foregroundColor: NSColor
    let backgroundColor: NSColor
    
    if self.enclosingMenuItem != nil,
       self.enclosingMenuItem!.isHighlighted {
      isHighlighted = true
      
      foregroundColor = NSColor.selectedMenuItemTextColor
      highlightEffectView.isHidden = false
    } else {
      isHighlighted = false
      
      foregroundColor = NSColor.labelColor
      highlightEffectView.isHidden = true
    }
    
    self.cursiveLabel.textColor = foregroundColor
    
    let backgroundRect = self.bounds
    let fillRect = self.bounds.insetBy(dx: 4, dy: 1)
    let path = NSBezierPath(roundedRect: fillRect, xRadius: 4, yRadius: 4)
//    backgroundColor.setFill()
//    path.fill()

    if self.enableAlternateBackgroundColor {
      isAlternativeBackground = true
    } else {
      isAlternativeBackground = false
    }
    
    if isHighlighted {
      debugPrint("Draw Custom HL - BG \(isAlternativeBackground)")
    } else {
      debugPrint("Draw Custom noHL - BG \(isAlternativeBackground)")
    }
    
  }
  
  /// Custom implementation of mouseUp that will invoke the target/action from the enclosing menuitem
  override func mouseUp(with event: NSEvent) {
    debugPrint("Custom MenuItemView mouseUp")
    if let menuItem = self.enclosingMenuItem,
       let menu = menuItem.menu {
      menu.cancelTracking()
      let itemIndex = menu.index(of: menuItem)
      menu.performActionForItem(at: itemIndex)
    }
    
    //TODO Should also set dirty flag for redraw since it current draws in a mouseOver state when the menu is re-shown
    self.setNeedsDisplay(self.bounds)
  }
  
  override func keyUp(with event: NSEvent) {
    debugPrint("Custom MenuItemView keyUp")
  }
}
