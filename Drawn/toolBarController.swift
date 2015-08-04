//
//  ToolBarController.swift
//  Drawn
//
//  Created by Jarom Vogel on 7/19/15.
//  Copyright © 2015 Jarom Vogel. All rights reserved.
//

import Foundation
import UIKit

class toolBarController: UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var toolbar: UIView!
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
    var colorsneedsscale = true
    var colorsneedsscale2 = true
    let pencilwhite = UIImage(named: "pencil_white") as UIImage!
    let pencilblack = UIImage(named: "pencil_black") as UIImage!
    let shapewhite = UIImage(named: "star_white") as UIImage!
    let shapeblack = UIImage(named: "star_black") as UIImage!
    let eraserwhite = UIImage(named: "eraser_white") as UIImage!
    let eraserblack = UIImage(named: "eraser_black") as UIImage!
    let eyedropperwhite = UIImage(named: "eyedropper_white") as UIImage!
    let eyedropperblack = UIImage(named: "eyedropper_black") as UIImage!
    
    
    // Actions for ToolPicker Button
    @IBAction func toolPickerGesture(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(toolPickerOuter)
        let buttonCenter = CGPoint(x: 20, y: 20)
        let offsetdistance = calcDistance(buttonCenter, point2: location)
        let offsetangle = calcAngle(buttonCenter, point2: location)
        
        if (offsetdistance > 10 && toolsneedsscale == true) {
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
        
        if (offsetdistance <= 10 && toolsneedsscale == false) {
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
            maskVisible.value = false
        }
    }
    @IBAction func toolPickerTouchUpInside(sender: AnyObject) {
        resetRadialMenu(toolPickerOuter)
        resetRadialMenu(toolPickerLayer2)
        addShadow(toolPickerOuter)
        removeBorder(toolPickerOuter)
        maskVisible.value = false
        resetTools()
    }
    @IBAction func toolPickerTouchDown(sender: AnyObject) {
        toolbar.bringSubviewToFront(toolPickerLayer2)
        toolbar.bringSubviewToFront(toolPickerOuter)
        toolbar.bringSubviewToFront(toolPickerButtonInner)
        expandRadialMenu(toolPickerOuter, scalefactor:7.0)
        expandRadialMenu(toolPickerLayer2, scalefactor: 7.0)
        maskVisible.value = true
    }
    
    
    // Actions for ColorPickerButton
    @IBAction func colorPickerGesture(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(colorPickerOuter)
        let buttonCenter = CGPoint(x: 20,y: 20)
        let offsetdistance = calcDistance(buttonCenter, point2: location)
        let offsetangle = calcAngle(buttonCenter, point2: location)

        if (offsetdistance > 10 && colorsneedsscale == true) {
            expandRadialMenu(colorPickerOuter, scalefactor: 1.05)
            expandRadialMenu(colorPickerLayer2, scalefactor: 1.05)
            colorsneedsscale = false
        }
        if (offsetdistance <= 10 && colorsneedsscale == false) {
            expandRadialMenu(colorPickerOuter, scalefactor: 0.95238095)
            expandRadialMenu(colorPickerLayer2, scalefactor: 0.95238095)
            colorsneedsscale = true
        }
        
        if offsetangle < 45 && offsetangle > -45 {
            colorPickerLayer2.backgroundColor = UIColor.whiteColor()
        } else if offsetangle <= 45 && offsetangle > -135 {
            colorPickerLayer2.backgroundColor = recentcolors.value[4]
        } else if offsetangle <= 135 && offsetangle > -225 {
            colorPickerLayer2.backgroundColor = recentcolors.value[3]
        } else if offsetangle <= 225 && offsetangle > -315 {
            colorPickerLayer2.backgroundColor = recentcolors.value[2]
        } else if offsetangle <= 315 && offsetangle > -405 {
            colorPickerLayer2.backgroundColor = recentcolors.value[1]
        } else {
            colorPickerLayer2.backgroundColor = UIColor.whiteColor()
        }
        
        if ( offsetdistance > 12 && colorsneedsscale2) {
            expandRadialMenu(colorPickerLayer2, scalefactor: 1.5)
            addBorder(colorPickerOuter)
            removeShadow(colorPickerOuter)
            colorsneedsscale2 = false
        }
        else if (offsetdistance <= 12 && colorsneedsscale2 == false) {
            expandRadialMenu(colorPickerLayer2, scalefactor: 0.66667)
            addShadow(colorPickerOuter)
            removeBorder(colorPickerOuter)
            colorsneedsscale2 = true
            resetTools()
        }
        
        // Close menu when gesture is ended
        if sender.state == UIGestureRecognizerState.Ended {
            resetRadialMenu(colorPickerOuter)
            resetRadialMenu(colorPickerLayer2)
            addShadow(colorPickerOuter)
            removeBorder(colorPickerOuter)
            colorsneedsscale2 = true

            maskVisible.value = false
            
            if offsetdistance > 12 {
                if offsetangle < 45 && offsetangle > -45 {
                    previousTool.value = selectedTool.value
                    selectedTool.value = "Eyedropper"
                    eyedropperActive.value = true
                } else if offsetangle <= 45 && offsetangle > -135 {
                    selectedcolor.value = recentcolors.value[4]
                } else if offsetangle <= 135 && offsetangle > -225 {
                    selectedcolor.value = recentcolors.value[3]
                } else if offsetangle <= 225 && offsetangle > -315 {
                    selectedcolor.value = recentcolors.value[2]
                } else if offsetangle <= 315 && offsetangle > -405 {
                    selectedcolor.value = recentcolors.value[1]
                }
            }
        }
    }
    @IBAction func displayColorPicker(sender: UIButton) {
        colorPickerHidden.value = !colorPickerHidden.value
        resetRadialMenu(colorPickerOuter)
        resetRadialMenu(colorPickerLayer2)
        addShadow(colorPickerOuter)
        removeBorder(colorPickerOuter)
        maskVisible.value = false
        self.addRecentColor(selectedcolor.value)
    }
    @IBAction func colorPickerTouchDown(sender: UIButton) {
        toolbar.bringSubviewToFront(colorPickerLayer2)
        toolbar.bringSubviewToFront(colorPickerOuter)
        toolbar.bringSubviewToFront(colorPickerInner)
        expandRadialMenu(colorPickerOuter, scalefactor: 7.0)
        expandRadialMenu(colorPickerLayer2, scalefactor: 7.0)
        maskVisible.value = true
    }
    func addRecentColor(newcolor: UIColor) {
        if recentcolors.value[0] != newcolor {
            recentcolors.value.insert(newcolor, atIndex: 0)
            recentcolors.value.removeLast()
        }
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
            maskVisible.value = false
        }
    }
    @IBAction func sizeOpacityTouchUpInside(sender: AnyObject) {
        resetRadialMenu(sizeOpacityPickerOuter)
        resetRadialMenu(sizeOpacityLayer2)
        addShadow(sizeOpacityPickerOuter)
        removeBorder(sizeOpacityPickerOuter)
        maskVisible.value = false
    }
    @IBAction func sizeOpacityPickerTouchDown(sender: AnyObject) {
        toolbar.bringSubviewToFront(sizeOpacityLayer2)
        toolbar.bringSubviewToFront(sizeOpacityPickerOuter)
        toolbar.bringSubviewToFront(sizeOpacityButton)
        expandRadialMenu(sizeOpacityPickerOuter, scalefactor:7.0)
        expandRadialMenu(sizeOpacityLayer2, scalefactor: 7.0)
        maskVisible.value = true
    }
    
    
    // Expand Radial Menus
    func expandRadialMenu(item:UIView, scalefactor:CGFloat) {
        spring(0.3, animations: {
            item.transform = CGAffineTransformScale(item.transform, scalefactor, scalefactor)
        })
        addShadow(item)
    }
    
    // Retract Radial Menus
    func resetRadialMenu(item:UIView) {
        spring(0.2, animations: {
            item.transform = CGAffineTransformIdentity
        })
        toolsneedsscale = true
        toolsneedsscale2 = true
        colorsneedsscale = true
        colorsneedsscale2 = true
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
        selectedTool.value = tool
        let toolBox: [[String:AnyObject]] = [
            ["name": "Pencil", "image": pencilImage, "white": pencilwhite, "black": pencilblack, "color": activecolor.value],
            ["name": "Shape", "image": shapeImage, "white": shapewhite, "black": shapeblack, "color": activecolor.value],
            ["name": "Eraser", "image": eraserImage, "white": eraserwhite, "black": eraserblack, "color": UIColor.whiteColor()]
        ]
        for (var i=0; i<toolBox.count; i++) {
            if toolBox[i]["name"] as! String == tool {
                selectedcolor.value = toolBox[i]["color"] as! UIColor
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
    
    
    func setEyedropperImage(color: UIColor!) {
        // Sets Color Picker Button to Black or White depending on selected color
        let darkbackground = colorIsDark(color)
        if darkbackground == true {
            if selectedTool.value == "Eyedropper" {
                colorPickerInner.setImage(eyedropperwhite, forState: .Normal)
            }
        } else {
            if selectedTool.value == "Eyedropper" {
                colorPickerInner.setImage(eyedropperblack, forState: .Normal)
            }
        }
    }
    
    func colorIsDark(color: UIColor!) -> Bool {
        let tempcolor = CIColor(color: color)
        let red = tempcolor.red
        let green = tempcolor.green
        let blue = tempcolor.blue
        let average = (red + blue + green) / 3
        if average > 0.5 {
            return false
        }
        else {
            return true
        }
    }
    
    func toggleEyedropperTool(active: Bool) {
        if active == true {
            setEyedropperImage(selectedcolor.value)
        } else {
            colorPickerInner.setImage(nil, forState: .Normal)
        }
    }
    
    func updateRecentColors() {
        // update recent colors when a new one is selected
        recentColor1.backgroundColor = recentcolors.value[1]
        recentColor2.backgroundColor = recentcolors.value[2]
        recentColor3.backgroundColor = recentcolors.value[3]
        recentColor4.backgroundColor = recentcolors.value[4]
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
        
        // Set Recent Colors to the ones chosen in storyboard
        recentcolors.value[0] = UIColor.blackColor()
        recentcolors.value[1] = recentColor1.backgroundColor!
        recentcolors.value[2] = recentColor2.backgroundColor!
        recentcolors.value[3] = recentColor3.backgroundColor!
        recentcolors.value[4] = recentColor4.backgroundColor!
        
        // Bind to color change
        backgroundcolor.bind {
            self.colorPickerInner.backgroundColor = $0
            self.sizeOpacityButton.backgroundColor = $0
            if selectedTool.value == "Eyedropper" {
                self.sizeOpacityButton.alpha = CGFloat(1.0)
            }
            self.setEyedropperImage($0)
        }
        
        // Bind to eyedropper tool change
        eyedropperActive.bind {
            self.toggleEyedropperTool($0)
        }
        
        //Update Recent colors on colorpicker
        recentcolors.bind {
            color in
            self.updateRecentColors()
        }
    }
}