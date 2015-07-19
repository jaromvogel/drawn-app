//
//  sharedFunctions.swift
//  Drawn
//
//  Created by Jarom Vogel on 7/19/15.
//  Copyright © 2015 Jarom Vogel. All rights reserved.
//

import Foundation
import UIKit
import Darwin

func calcAngle(point1:CGPoint, point2:CGPoint) -> CGFloat {
    let deltaX = point2.x - point1.x
    let deltaY = point2.y - point1.y
    let angle = atan2(deltaY, deltaX) * 360 / CGFloat(M_PI)
    return angle
}

func calcDistance(point1:CGPoint, point2:CGPoint) -> CGFloat {
    let deltaX = point2.x - point1.x
    let deltaY = point2.y - point1.y
    let distance = sqrt(pow(deltaX, 2) + pow(deltaY, 2))
    
    return distance
}