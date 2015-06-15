//
//  Line.swift
//  Drawn
//
//  Created by Jarom Vogel on 4/10/15.
//  Copyright (c) 2015 Jarom Vogel. All rights reserved.
//

import UIKit

class Line {
    var start: CGPoint
    var end: CGPoint
    var ctr1: CGPoint
    var ctr2: CGPoint
    var color: UIColor
    var weight: CGFloat
    var opacity: CGFloat
    
    init(
        start _start: CGPoint,
        end _end: CGPoint,
        ctr1 _ctr1: CGPoint,
        ctr2 _ctr2: CGPoint,
        color _color: UIColor!,
        weight _weight: CGFloat!,
        opacity _opacity: CGFloat!
    ) {
        start = _start
        end = _end
        ctr1 = _ctr1
        ctr2 = _ctr2
        color = _color
        weight = _weight
        opacity = _opacity
    }
}