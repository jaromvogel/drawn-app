//
//  apiConnect.swift
//  Drawn
//
//  Created by Jarom Vogel on 4/14/15.
//  Copyright (c) 2015 Jarom Vogel. All rights reserved.
//

import UIKit
import SwiftyJSON

class connect {
    func post() {
        // Create a reference to a Firebase location
        let myRootRef = Firebase(url:"https://drawn.firebaseio.com")
        // Write data to Firebase
        myRootRef.setValue("Some data goes here")
    }
    
    func get(completionHandler: (results: NSDictionary) -> ()) {
    }
}