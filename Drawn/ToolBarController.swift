//
//  ToolBarController.swift
//  Drawn
//
//  Created by Jarom Vogel on 7/19/15.
//  Copyright © 2015 Jarom Vogel. All rights reserved.
//

import Foundation
import UIKit

class ToolBarController: UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var menuBGMask: UIView!
    @IBOutlet weak var colorPickerLayer2: UIView!
    @IBOutlet weak var colorPickerOuter: UIView!
    @IBOutlet weak var recentColor1: UIView!
    @IBOutlet weak var recentColor2: UIView!
        @IBOutlet weak var recentColor2TopSpace: NSLayoutConstraint!
        @IBOutlet weak var recentColor2LeftSpace: NSLayoutConstraint!
    @IBOutlet weak var recentColor3: UIView!
    @IBOutlet weak var recentColor4: UIView!
        @IBOutlet weak var recentColor4TopSpace: NSLayoutConstraint!
        @IBOutlet weak var recentColor4RightSpace: NSLayoutConstraint!
    @IBOutlet weak var eyeDropper: UIView!
    @IBOutlet weak var eyedropperImageView: UIImageView!
    @IBOutlet weak var colorPickerInner: UIButton!
    @IBOutlet weak var sizeOpacityLayer2: UIView!
    @IBOutlet weak var sizeOpacityPickerOuter: UIView!
    @IBOutlet weak var checkerBoardImage: UIImageView!
    @IBOutlet weak var sizeOpacityButton: UIButton!
    @IBOutlet weak var toolPickerLayer2: UIView!
    @IBOutlet weak var toolPickerOuter: UIView!
    @IBOutlet weak var pencilImage: UIImageView!
    @IBOutlet weak var eraserImage: UIImageView!
    @IBOutlet weak var shapeImage: UIImageView!
    @IBOutlet weak var toolPickerButtonInner: UIButton!
    

    
    var toolsneedsscale = true
    var toolsneedsscale2 = true
    let pencilwhite = UIImage(named: "pencil_white") as UIImage!
    let pencilblack = UIImage(named: "pencil_black") as UIImage!
    let shapewhite = UIImage(named: "star_white") as UIImage!
    let shapeblack = UIImage(named: "star_black") as UIImage!
    let eraserwhite = UIImage(named: "eraser_white") as UIImage!
    let eraserblack = UIImage(named: "eraser_black") as UIImage!   
    
    // Actions for ToolPicker Button
    @IBAction func toolPickerGesture(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(toolPickerOuter)
        let buttonCenter = CGPoint(x: 20, y: 20)
        let offsetdistance = calcDistance(buttonCenter, point2: location)
        let offsetangle = calcAngle(buttonCenter, point2: location)
        
        if (offsetdistance > 4 && toolsneedsscale == true) {
            expandRadialMenu(toolPickerOuter, scalefactor: 1.1)
            expandRadialMenu(toolPickerLayer2, scalefactor: 1.1)
            toolsneedsscale = false
        }
        
        if (offsetangle < -120 && offsetdistance > 12) {
            setActive("Pencil")
        }
        else if (offsetangle < 0 && offsetangle >= -60 && offsetdistance > 12) {
            setActive("Eraser")
        }
        else if (offsetangle < -60 && offsetangle >= -180 && offsetdistance > 12) {
            setActive("Shape")
        }
        
        if ( offsetdistance > 12 && toolsneedsscale2) {
            expandRadialMenu(toolPickerLayer2, scalefactor: 1.5)
            addBorder(toolPickerOuter)
            removeShadow(toolPickerOuter)
            toolsneedsscale2 = false
        }
        else if (offsetdistance <= 12 && toolsneedsscale2 == false) {
            expandRadialMenu(toolPickerLayer2, scalefactor: 0.66667)
            addShadow(toolPickerOuter)
            removeBorder(toolPickerOuter)
            toolsneedsscale2 = true
            resetTools()
        }
        
        if (offsetdistance <= 4 && toolsneedsscale == false) {
            expandRadialMenu(toolPickerOuter, scalefactor: 0.90909091)
            expandRadialMenu(toolPickerLayer2, scalefactor: 0.90909091)
            toolsneedsscale = true
        }
        // Close menu when gesture is ended
        if sender.state == UIGestureRecognizerState.Ended {
            resetRadialMenu(toolPickerOuter)
            resetRadialMenu(toolPickerLayer2)
            addShadow(toolPickerOuter)
            removeBorder(toolPickerOuter)
            resetTools()
            toggleMask(menuBGMask, hide: true, opacity: 0)
        }
    }
    @IBAction func toolPickerTouchUpInside(sender: AnyObject) {
        resetRadialMenu(toolPickerButtonInner)
        resetRadialMenu(toolPickerLayer2)
        addShadow(toolPickerButtonInner)
        removeBorder(toolPickerButtonInner)
        resetTools()
//        toggleMask(menuBGMask, hide: true, opacity: 0)
    }
    @IBAction func toolPickerTouchDown(sender: AnyObject) {
        expandRadialMenu(toolPickerOuter, scalefactor:7.0)
        expandRadialMenu(toolPickerLayer2, scalefactor: 7.0)
        toggleMask(menuBGMask, hide: false, opacity: 0.2)
        dynamictest2.value = "updating value from toolbar"
    }
    
    
    // Actions for ColorPickerButton
    @IBAction func colorPickerGesture(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(colorPickerOuter)
        let buttonCenter = CGPoint(x: 20,y: 20)
        let offsetdistance = calcDistance(buttonCenter, point2: location)
        let offsetangle = calcAngle(buttonCenter, point2: location)
        
        // Close menu when gesture is ended
        if sender.state == UIGestureRecognizerState.Ended {
            resetRadialMenu(colorPickerOuter)
            resetRadialMenu(colorPickerLayer2)
            addShadow(colorPickerOuter)
            removeBorder(colorPickerOuter)
            toggleMask(menuBGMask, hide: true, opacity: 0)
            
            if offsetdistance > 12 && offsetangle < 50 && offsetangle > -45 {
                previousTool = selectedTool
                selectedTool = "Eyedropper"
//                setEyedropperImage(selectedcolor)
//                drawingFunctions().renderLayersToCache(canvasView, canvasContainer: canvasContainer, cache: cacheDrawingView)
            }
        }
    }
    @IBAction func displayColorPicker(sender: UIButton) {
//        colorPickerContainer.hidden = !colorPickerContainer.hidden
        resetRadialMenu(colorPickerOuter)
        resetRadialMenu(colorPickerLayer2)
        addShadow(colorPickerOuter)
        removeBorder(colorPickerOuter)
        toggleMask(menuBGMask, hide: true, opacity: 0)
    }
    @IBAction func colorPickerTouchDown(sender: UIButton) {
        expandRadialMenu(colorPickerOuter, scalefactor: 7.0)
        expandRadialMenu(colorPickerLayer2, scalefactor: 7.0)
        toggleMask(menuBGMask, hide: false, opacity: 0.2)
    }
    
    
    
    // Actions for Size/Opacity Button
    var lastoffsetdistance = CGFloat(0)
    @IBAction func sizeOpacityGesture(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(sizeOpacityPickerOuter)
        let center = CGPoint(x:20,y:20)
        let offsetdistance = calcDistance(center, point2: location)
        let offsetangle = calcAngle(center, point2: location)
        lineWeight = offsetdistance * 2
        if lastoffsetdistance > 0 {
            let sizeIndicatorScale = (offsetdistance/lastoffsetdistance)
            sizeOpacityButton.transform = CGAffineTransformScale(sizeOpacityButton.transform, sizeIndicatorScale, sizeIndicatorScale)
        }
        lastoffsetdistance = offsetdistance
        let adjustedangle = (offsetangle + 360) / 3
        if adjustedangle >= 0 && adjustedangle <= 60 {
            lineOpacity = CGFloat(adjustedangle/60)
        } else if (adjustedangle >= 60 && adjustedangle < 150) {
            lineOpacity = CGFloat(1.0)
        } else {
            lineOpacity = CGFloat(0)
        }
        sizeOpacityButton.alpha = lineOpacity

        
        // Close menu when gesture is ended
        if sender.state == UIGestureRecognizerState.Ended {
            resetRadialMenu(sizeOpacityPickerOuter)
            resetRadialMenu(sizeOpacityLayer2)
            toggleMask(menuBGMask, hide: true, opacity: 0)
        }
    }
    @IBAction func sizeOpacityTouchUpInside(sender: AnyObject) {
        resetRadialMenu(sizeOpacityPickerOuter)
        resetRadialMenu(sizeOpacityLayer2)
        addShadow(sizeOpacityPickerOuter)
        removeBorder(sizeOpacityPickerOuter)
        toggleMask(menuBGMask, hide: true, opacity: 0)
    }
    @IBAction func sizeOpacityPickerTouchDown(sender: AnyObject) {
        expandRadialMenu(sizeOpacityPickerOuter, scalefactor:7.0)
        expandRadialMenu(sizeOpacityLayer2, scalefactor: 7.0)
        toggleMask(menuBGMask, hide: false, opacity: 0.2)
    }
    
    
    // Expand Radial Menus
    func expandRadialMenu(item:UIView, scalefactor:CGFloat) {
        UIView.animateWithDuration(0.15,
            delay: 0.1,
            options: [.CurveEaseInOut, .AllowUserInteraction],
            animations: {
                item.transform = CGAffineTransformScale(item.transform, scalefactor, scalefactor)
            },
            completion: nil
        )
        addShadow(item)
    }
    
    // Retract Radial Menus
    func resetRadialMenu(item:UIView) {
        UIView.animateWithDuration(0.15,
            delay: 0,
            options: [.CurveEaseInOut, .AllowUserInteraction],
            animations: {
                item.transform = CGAffineTransformIdentity
            },
            completion: nil
        )
        toolsneedsscale = true
        toolsneedsscale2 = true
    }
    
    // Show/Hide Mask
    func toggleMask(item:UIView, hide:Bool, opacity: Float) {
        // Adjust Menu Background Mask Size
        let screenSize = UIScreen.mainScreen().bounds
        menuBGMask.frame = CGRectMake(0, -screenSize.height, screenSize.width, screenSize.height)
        UIView.animateWithDuration(0.5,
            delay: 0,
            options: [.CurveEaseInOut, .AllowUserInteraction],
            animations: {
                item.layer.opacity = opacity
                item.hidden = hide
            },
            completion: nil
        )
    }
    
    // Add drop shadow to radial menu
    func addShadow(item:UIView) {
        item.layer.shadowColor = UIColor.blackColor().CGColor
        item.layer.shadowOpacity = 0.05
        item.layer.shadowRadius = 1
        item.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    // Remove drop shadow from radial menu
    func removeShadow(item:UIView) {
        item.layer.shadowColor = nil
        item.layer.shadowOpacity = 0
        item.layer.shadowRadius = 0
    }
    
    // Add border to inner radial menu
    func addBorder(item:UIView) {
        item.layer.borderWidth = 0.15
        let lightgray = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).CGColor
        item.layer.borderColor = lightgray
    }
    
    // Remove border from inner radial menu
    func removeBorder(item:UIView) {
        item.layer.borderWidth = 0
        item.layer.borderColor = nil
    }
    
    func setActive(tool: String) {
        selectedTool = tool
        let toolBox: [[String:AnyObject]] = [
            ["name": "Pencil", "image": pencilImage, "white": pencilwhite, "black": pencilblack, "color": selectedcolor],
            ["name": "Shape", "image": shapeImage, "white": shapewhite, "black": shapeblack, "color": selectedcolor],
            ["name": "Eraser", "image": eraserImage, "white": eraserwhite, "black": eraserblack, "color": UIColor.whiteColor()]
        ]
        for (var i=0; i<toolBox.count; i++) {
            if toolBox[i]["name"] as! String == tool {
                lineColor = toolBox[i]["color"] as! UIColor
                let activeImage = toolBox[i]["white"] as! UIImage
                toolPickerButtonInner.setImage(activeImage, forState: UIControlState.Normal)
                let iconImage = toolBox[i]["image"] as! UIImageView
                iconImage.layer.backgroundColor = UIColor.blackColor().CGColor
                iconImage.image = activeImage
            }
            else {
                let inactiveImage = toolBox[i]["black"] as! UIImage
                let iconImage = toolBox[i]["image"] as! UIImageView
                iconImage.layer.backgroundColor = UIColor.whiteColor().CGColor
                iconImage.image = inactiveImage
            }
        }
    }
    
    // Reset eraser icon
    func resetEraser() {
        eraserImage.layer.backgroundColor = defaultcolor
        eraserImage.image = eraserblack
    }
    
    // Reset shape icon
    func resetShape() {
        shapeImage.layer.backgroundColor = defaultcolor
        shapeImage.image = shapeblack
    }
    
    // Reset pencil icon
    func resetPencil() {
        pencilImage.layer.backgroundColor = defaultcolor
        pencilImage.image = pencilblack
    }
    
    // Reset backgrounds and color on tool icons in picker
    func resetTools() {
        resetShape()
        resetEraser()
        resetPencil()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Rotate Images 45 Degrees
        checkerBoardImage.transform = CGAffineTransformRotate(checkerBoardImage.transform, CGFloat(M_PI/4))
        toolPickerButtonInner.transform = CGAffineTransformRotate(toolPickerButtonInner.transform, CGFloat(M_PI/4))
        
        // Fine Tune Spacing of recent color buttons
        recentColor2TopSpace.constant = 7.5
        recentColor2LeftSpace.constant = 7.5
        recentColor4TopSpace.constant = 7.5
        recentColor4RightSpace.constant = 7.5
        
    }
}