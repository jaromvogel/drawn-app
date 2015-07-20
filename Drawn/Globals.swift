//
//  Globals.swift
//  Drawn
//
//  Created by Jarom Vogel on 7/18/15.
//  Copyright © 2015 Jarom Vogel. All rights reserved.
//

import Foundation
import UIKit

class Shared {
    static let sharedInstance = Shared()
}

var test: String!
var lineWeight = CGFloat(2.0)
var lineOpacity = CGFloat(1.0)

// used to set background of tools in toolpicker
let defaultcolor = UIColor.whiteColor().CGColor

// Current Color
let selectedcolor = Dynamic(UIColor.blackColor())
// Update background colors on toolbar buttons
let backgroundcolor = Dynamic(UIColor.blackColor())
// Keep track of what the currently selected color is to reset after eraser tool
let activecolor = Dynamic(UIColor.blackColor())

// Tool setup
let selectedTool = Dynamic("Pencil")
var previousTool = Dynamic("")

// Dark mask when a radial menu is active
let maskVisible = Dynamic(false)

// Color Picker toggle
let colorPickerHidden = Dynamic(true)

// Keep track of whether eyedropper tool is active
let eyedropperActive = Dynamic(false)