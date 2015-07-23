//
//  topBarController.swift
//  Drawn
//
//  Created by Jarom Vogel on 7/17/15.
//  Copyright © 2015 Jarom Vogel. All rights reserved.
//

import Foundation
import UIKit

class topBarController: UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBAction func tapToTest(sender: AnyObject) {
        print("works")
    }
    
    @IBAction func tappedSend(sender: AnyObject) {
        
    }
    
    @IBAction func tappedSave(sender: AnyObject) {
        print("should save")
    }
    
    @IBAction func tappedUndo(sender: AnyObject) {
        print("should undo")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}