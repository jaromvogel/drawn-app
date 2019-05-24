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
    
    let drawnRef = Firebase(url:"https://drawn.firebaseio.com/canvas/data/canvasdata")
    
    func login(username: String, password: String, loginview: UIViewController) {
        drawnRef.authUser(username, password: password) {
            error, authData in
            if error != nil {
                // an error occured while attempting login
                print("Couldn't log in, sorry!")
            } else {
                // user is logged in, check authData for data
                print(authData.uid)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainview = storyboard.instantiateViewControllerWithIdentifier("mainView") as UIViewController!
                loginview.presentViewController(mainview, animated: true, completion: nil)
            }
        }
    }
    
    func post(cacheDrawingView: UIImageView, canvasView: CanvasView) {
        // Encode full image to send
        let imageData = UIImagePNGRepresentation(cacheDrawingView.image!)
        let base64String = imageData?.base64EncodedStringWithOptions([])

        // Write data to Firebase
        var layerdata = [String: AnyObject]()
        layerdata["layerwidth"] = canvasView.frame.width
        layerdata["layerheight"] = canvasView.frame.height
        layerdata["id"] = "2" // needs auto generated id
        layerdata["layerimage"] = "data:image/png;base64," + base64String!
        
        let layerRef = drawnRef.childByAppendingPath("0") // needs to increment depending on number of layers
        layerRef.setValue(layerdata)
    }
    
    func get(compositeImage: UIImageView!) {
        // Create a reference to a Firebase location
        let layerRef = drawnRef
        layerRef.observeEventType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                let layerdata = rest.value
                if let layerimage = layerdata["layerimage"] {
                    let base64image = layerimage!.stringByReplacingOccurrencesOfString("data:image/png;base64,", withString: "")
                    
                    let decodedData = NSData(base64EncodedString: base64image, options: NSDataBase64DecodingOptions(rawValue: 0))
                    let decodedimage = UIImage(data: decodedData!)
                    // needs to draw to different layers instead of the same one over and over
                    compositeImage.image = decodedimage as UIImage?
                } else {
                    print("null")
                }
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
}