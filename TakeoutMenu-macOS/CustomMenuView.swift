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

// LINK: SO: OS X NSMenuItem with custom NSView does not highlight swift
// https://www.titanwolf.org/Network/q/0db795e9-d432-456d-9ddf-29d87f2fcacf/y

// LINK: SO: Remove highlight from NSMenuItem after click?
// https://stackoverflow.com/questions/6169930/remove-highlight-from-nsmenuitem-after-click

// LINK: SO: NSMenuItem with custom view doesn't receive mouse events
// https://stackoverflow.com/questions/44527792/nsmenuitem-with-custom-view-doesnt-receive-mouse-events

// LINK: Event Monitors
// https://isapozhnik.com/articles/status-item/

// LINK: Hacking NSMenu keyboard navigation
// https://kazakov.life/2017/05/18/hacking-nsmenu-keyboard-navigation/

// LINK: Intercepting NSMenu key events
// https://stackoverflow.com/questions/31968959/intercepting-nsmenu-key-events

import Cocoa

class CustomMenuView: NSView {
  
  /// This toggle changes the background color and should be enabled if the parent menu item is set to isAlternate = true
  var enableAlternateBackgroundColor = false
  
  @IBOutlet weak var cursiveLabel: NSTextField!
  
  private let highlightEffectView: NSVisualEffectView
  
  required init?(coder decoder: NSCoder) {
    highlightEffectView = NSVisualEffectView()
    highlightEffectView.state = .active
    highlightEffectView.material = .selection
    highlightEffectView.isEmphasized = true
    highlightEffectView.blendingMode = .behindWindow
    highlightEffectView.autoresizingMask = [.width, .height]
    //TODO: Identify way to inset round rect to bound the effect view
    
    super.init(coder: decoder)
    
    self.addSubview(highlightEffectView, positioned: .below, relativeTo: nil)
    highlightEffectView.frame = self.bounds
    
    self.autoresizingMask = [.width, .height]
  }
  
  var highlighted : Bool = false {
    didSet {
      if oldValue != highlighted {
        debugPrint("CMV: highlighted changed to \(highlighted)")
        self.needsDisplay = true
      }
    }
  }

  override func viewWillMove(toSuperview newSuperview: NSView?) {
    super.viewWillMove(toSuperview: newSuperview)
    
    debugPrint("CMV: viewWillMove:toSuperview \(newSuperview)")
  }
  
  override func viewWillMove(toWindow newWindow: NSWindow?) {
    super.viewWillMove(toWindow: newWindow)
    
    debugPrint("CMV: viewWillMove:ToWindow \(newWindow)")
  }
  
  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    
    debugPrint("CMV: viewDidMoveToWindow")
    
    //TODO Implemnent https://kazakov.life/2017/05/18/hacking-nsmenu-keyboard-navigation/
  }
  
  /// Custom implementation of mouseUp that will invoke the target/action from the enclosing menuitem
  override func mouseUp(with event: NSEvent) {
    debugPrint("**** CMV: mouseUp")

    invokeAction()
    
    //TODO Should also set dirty flag for redraw since it current draws in a mouseOver state when the menu is re-shown
    self.setNeedsDisplay(self.bounds)
  }

  //  override func mouseEntered(with theEvent: NSEvent) { highlighted = true }
  //  override func mouseExited(with theEvent: NSEvent) { highlighted = false }
    
  
  /// Cancel tracking the menu and perform the item's action
  public func invokeAction() {
    if let menuItem = self.enclosingMenuItem,
       let menu = menuItem.menu {
      debugPrint("**** CMV: invokeAction")
      menu.cancelTracking()
      let itemIndex = menu.index(of: menuItem)
      menu.performActionForItem(at: itemIndex)
    }
  }
  
  // TODO override 'keyDown' equivalent with same code as mouseUp
  
  // The following key methods are NOT expected to be invoked
  override func keyUp(with event: NSEvent) {
    debugPrint("**** CMV: keyUp")
  }
  override func keyDown(with event: NSEvent) {
    debugPrint("**** CMV: keyDown")
  }
  
  override func flagsChanged(with event: NSEvent)  {
    debugPrint("**** CMV: flagsChanged(event)")
  }
  override func draw(_ dirtyRect: NSRect) {
    debugPrint("**** CMV: draw(dirtyRect)")

    super.draw(dirtyRect)
    
    
    // HighlightEffect visibility depends on the enclosing menu item
    let displayHighlightEffet = (self.enclosingMenuItem != nil && self.enclosingMenuItem!.isHighlighted)

    let foregroundColor: NSColor
    if displayHighlightEffet {
      foregroundColor = NSColor.selectedMenuItemTextColor
      highlightEffectView.isHidden = false
    } else {
      foregroundColor = NSColor.labelColor
      highlightEffectView.isHidden = true
    }
    self.cursiveLabel.textColor = foregroundColor

    // KMKMKM Used for logging only
//    let isHighlighted = !highlightEffectView.isHidden
//    if isHighlighted {
//      debugPrint("Draw Custom HL")
//    } else {
//      debugPrint("Draw Custom noHL")
//    }
    
  }
  
}
