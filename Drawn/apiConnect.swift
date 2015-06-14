//
//  apiConnect.swift
//  chatbook
//
//  Created by Jarom Vogel on 4/14/15.
//  Copyright (c) 2015 Jarom Vogel. All rights reserved.
//

import UIKit
import SwiftyJSON

class connect {
    func post(lines: Array<Line>) -> NSDictionary {
        
        // Create a reference to a Firebase location
        var myRootRef = Firebase(url:"https://drawn.firebaseio.com")
        // Write data to Firebase
        myRootRef.setValue("Some data goes here")
        
        var json = NSDictionary()
        var request = NSMutableURLRequest(URL: NSURL(string: "http://personal.jaromvogel.com/api/test/")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        // Get some real data to post here
        var AllLines: Array<AnyObject> = []
        for line in lines {
            var lineDict = Dictionary<String, AnyObject>()
            let index = find(lines.map({ $0 === line }), true)
            lineDict["startx"] = line.start.x
            lineDict["starty"] = line.start.y
            lineDict["endx"] = line.end.x
            lineDict["endy"] = line.end.y
            lineDict["ctr1x"] = line.ctr1.x
            lineDict["ctr1y"] = line.ctr1.y
            lineDict["ctr2x"] = line.ctr2.x
            lineDict["ctr2y"] = line.ctr2.y
            lineDict["color"] = line.color.description
            let lineCIColor = CIColor(color: line.color)!
            lineDict["colorRed"] = lineCIColor.red()
            lineDict["colorGreen"] = lineCIColor.green()
            lineDict["colorBlue"] = lineCIColor.blue()
            lineDict["weight"] = line.weight
            lineDict["opacity"] = line.opacity
            AllLines.append(lineDict)
        }
        
        let AllLinesData = JSON(AllLines).rawData()!
        
        var err: NSError?
        request.HTTPBody = AllLinesData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary

            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                if let parseJSON = json {
                    var success = parseJSON["test1"] as? String
                    println("Success: \(success)")
                }
                else {
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
        return json
    }
    
    func get(completionHandler: (results: NSDictionary) -> ()) {
    }
}