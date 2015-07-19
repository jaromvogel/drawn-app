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
var lineColor = UIColor.blackColor()
var lineWeight = CGFloat(2.0)
var lineOpacity = CGFloat(1.0)
var selectedcolor = UIColor.blackColor()
// used to set background of tools in toolpicker
var defaultcolor = UIColor.whiteColor().CGColor
var selectedTool = "Pencil"
var previousTool = ""
