//
//  ViewController.swift
//  Drawn
//
//  Created by Jarom Vogel on 6/7/15.
//  Copyright (c) 2015 Jarom Vogel. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }

    @IBOutlet weak var canvasContainer: UIView!
    @IBOutlet weak var tempDrawingView: UIImageView!
    @IBOutlet weak var cacheDrawingView: UIImageView!
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var gestureControlView: UIView!
    @IBOutlet weak var colorPickerContainer: UIView!
    @IBOutlet weak var colorPickerBorder: UIView!
    @IBOutlet weak var colorPickerImage: UIImageView!
    @IBOutlet weak var menuBGMask: UIView!
    @IBOutlet weak var toolPickerLayer2: UIView!
    @IBOutlet weak var toolPickerButton: UIView!
    @IBOutlet weak var toolPickerButtonInner: UIButton!
    @IBOutlet weak var pencilImage: UIImageView!
    @IBOutlet weak var shapeImage: UIImageView!
    @IBOutlet weak var eraserImage: UIImageView!
    @IBOutlet weak var colorPickerLayer2: UIView!
    @IBOutlet weak var colorPickerButton: UIView!
    @IBOutlet weak var colorPickerButtonInner: UIButton!
    @IBOutlet weak var checkerBoardImage: UIImageView!
    @IBOutlet weak var sizeOpacityLayer2: UIView!
    @IBOutlet weak var sizeOpacityButton: UIView!
    @IBOutlet weak var sizeOpacityButtonInner: UIButton!
    @IBOutlet var panToolPicker: UIPanGestureRecognizer!
    
    var toolsneedsscale = true
    var toolsneedsscale2 = true
    var defaultColor = UIColor.blackColor().CGColor
    var selectedcolor = UIColor.blackColor()
    let pencilwhite = UIImage(named: "pencil_white") as UIImage!
    let pencilblack = UIImage(named: "pencil_black") as UIImage!
    let shapewhite = UIImage(named: "star_white") as UIImage!
    let shapeblack = UIImage(named: "star_black") as UIImage!
    let eraserwhite = UIImage(named: "eraser_white") as UIImage!
    let eraserblack = UIImage(named: "eraser_black") as UIImage!
    var offsetdistance = CGFloat(0)
    var canvasTranslation = CGPoint()
    var darkness = CGFloat(1)
    
    
    // Actions for ToolPicker Button
    @IBAction func toolPickerGesture(sender: UIPanGestureRecognizer) {
        
        let location = sender.locationInView(toolPickerButton)
        let buttonCenter = CGPoint(x: 20, y: 20)
        offsetdistance = calcDistance(buttonCenter, point2: location)
        let offsetangle = calcAngle(buttonCenter, point2: location)
        
        if (offsetdistance > 4 && toolsneedsscale == true) {
            expandRadialMenu(toolPickerButton, scalefactor: 1.1)
            expandRadialMenu(toolPickerLayer2, scalefactor: 1.1)
            toolsneedsscale = false
        }

        if (offsetangle < -60 && offsetdistance > 12) {
            setActive("Pencil")
        }
        else if (offsetangle < 0 && offsetangle >= -30 && offsetdistance > 12) {
            setActive("Eraser")
        }
        else if (offsetangle < -30 && offsetangle >= -60 && offsetdistance > 12) {
            setActive("Shape")
        }
        
        if ( offsetdistance > 12 && toolsneedsscale2) {
            expandRadialMenu(toolPickerLayer2, scalefactor: 1.5)
            addBorder(toolPickerButton)
            removeShadow(toolPickerButton)
            toolsneedsscale2 = false
        }
        else if (offsetdistance <= 12 && toolsneedsscale2 == false) {
            expandRadialMenu(toolPickerLayer2, scalefactor: 0.66667)
            addShadow(toolPickerButton)
            removeBorder(toolPickerButton)
            toolsneedsscale2 = true
            resetTools()
        }
        
        if (offsetdistance <= 4 && toolsneedsscale == false) {
            expandRadialMenu(toolPickerButton, scalefactor: 0.90909091)
            expandRadialMenu(toolPickerLayer2, scalefactor: 0.90909091)
            toolsneedsscale = true
        }
        // Close menu when gesture is ended
        if sender.state == UIGestureRecognizerState.Ended {
            resetRadialMenu(toolPickerButton)
            resetRadialMenu(toolPickerLayer2)
            addShadow(toolPickerButton)
            removeBorder(toolPickerButton)
            resetTools()
            offsetdistance = CGFloat(0.0)
            toggleMask(menuBGMask, hide: true, opacity: 0)
        }
    }
    @IBAction func toolPickerTouchUpInside(sender: AnyObject) {
        resetRadialMenu(toolPickerButton)
        resetRadialMenu(toolPickerLayer2)
        addShadow(toolPickerButton)
        removeBorder(toolPickerButton)
        resetTools()
        toggleMask(menuBGMask, hide: true, opacity: 0)
    }
    @IBAction func toolPickerTouchDown(sender: AnyObject) {
        expandRadialMenu(toolPickerButton, scalefactor:7.0)
        expandRadialMenu(toolPickerLayer2, scalefactor: 7.0)
        toggleMask(menuBGMask, hide: false, opacity: 0.2)
    }
    
    // Actions for ColorPickerButton
    @IBAction func colorPickerGesture(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(colorPickerButton)
        let buttonCenter = CGPoint(x: 20,y: 20)
        offsetdistance = calcDistance(buttonCenter, point2: location)
        let offsetangle = calcAngle(buttonCenter, point2: location)
        println("offsetangle")
        println(offsetangle)
        println("offsetdistance")
        println(offsetdistance)

        // Close menu when gesture is ended
        if sender.state == UIGestureRecognizerState.Ended {
            resetRadialMenu(colorPickerButton)
            resetRadialMenu(colorPickerLayer2)
            addShadow(colorPickerButton)
            removeBorder(colorPickerButton)
            toggleMask(menuBGMask, hide: true, opacity: 0)
        }
    }
    @IBAction func displayColorPicker(sender: UIButton) {
        colorPickerContainer.hidden = !colorPickerContainer.hidden
        resetRadialMenu(colorPickerButton)
        resetRadialMenu(colorPickerLayer2)
        addShadow(colorPickerButton)
        removeBorder(colorPickerButton)
        toggleMask(menuBGMask, hide: true, opacity: 0)
    }
    @IBAction func colorPickerTouchDown(sender: UIButton) {
        expandRadialMenu(colorPickerButton, scalefactor: 7.0)
        expandRadialMenu(colorPickerLayer2, scalefactor: 7.0)
        toggleMask(menuBGMask, hide: false, opacity: 0.2)
    }
    // Actions for Color Picker Wheel
    @IBAction func colorPickerPanGesture(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(colorPickerBorder)
        let pickerCenter = colorPickerImage.center
        offsetdistance = calcDistance(pickerCenter, point2: location)
        let offsetangle = calcAngle(pickerCenter, point2: location)
        let offsetpercent = (100 * offsetdistance / (colorPickerImage.frame.width / 2))
        var newColor = colorWheel().calcColor(offsetangle, distance: offsetpercent, darkness: darkness)
        canvasView.lineColor = newColor
        colorPickerButtonInner.backgroundColor = newColor
        sizeOpacityButtonInner.backgroundColor = newColor
    }
    @IBAction func tappedColorWheel(sender: UITapGestureRecognizer) {
    }
    @IBAction func darknessSlider(sender: UISlider) {
        // this sort of works, but definitely NEEDS work
        darkness = CGFloat(sender.value)
    }
    
    
    // Actions for Size/Opacity Button
    var lastoffsetdistance = CGFloat(0)
    @IBAction func sizeOpacityGesture(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(sizeOpacityButton)
        let center = CGPoint(x:20,y:20)
        offsetdistance = calcDistance(center, point2: location)
        let offsetangle = calcAngle(center, point2: location)
        canvasView.lineWeight = offsetdistance * 2
        if lastoffsetdistance > 0 {
            let sizeIndicatorScale = (offsetdistance/lastoffsetdistance)
            sizeOpacityButtonInner.transform = CGAffineTransformScale(sizeOpacityButtonInner.transform, sizeIndicatorScale, sizeIndicatorScale)
            println(sizeOpacityButtonInner.frame.width)
        }
        lastoffsetdistance = offsetdistance
        let adjustedangle = (offsetangle + 360) / 3
        if adjustedangle >= 0 && adjustedangle <= 270 {
            canvasView.lineOpacity = CGFloat(adjustedangle/90)
            sizeOpacityButtonInner.alpha = CGFloat(adjustedangle/90)
        }
        
        // Close menu when gesture is ended
        if sender.state == UIGestureRecognizerState.Ended {
            resetRadialMenu(sizeOpacityButton)
            resetRadialMenu(sizeOpacityLayer2)
            offsetdistance = CGFloat(0.0)
            toggleMask(menuBGMask, hide: true, opacity: 0)
        }
    }
    
    @IBAction func sizeOpacityTouchUpInside(sender: AnyObject) {
        resetRadialMenu(sizeOpacityButton)
        resetRadialMenu(sizeOpacityLayer2)
        addShadow(sizeOpacityButton)
        removeBorder(sizeOpacityButton)
        toggleMask(menuBGMask, hide: true, opacity: 0)
    }
    @IBAction func sizeOpacityPickerTouchDown(sender: AnyObject) {
        expandRadialMenu(sizeOpacityButton, scalefactor:7.0)
        expandRadialMenu(sizeOpacityLayer2, scalefactor: 7.0)
        toggleMask(menuBGMask, hide: false, opacity: 0.2)
    }
    
    
    @IBAction func rotateCanvas(sender: UIRotationGestureRecognizer) {
        canvasGestures().rotateCanvas(self.canvasContainer, containerView: self.view, sender: sender)
    }
    
    @IBAction func zoomCanvas(sender: UIPinchGestureRecognizer) {
        canvasGestures().zoomCanvas(self.canvasContainer, sender: sender)
    }
    
    @IBAction func panCanvas(sender: UIPanGestureRecognizer) {
        canvasGestures().panCanvas(self.canvasContainer, containerView: self.view, sender: sender)
        canvasTranslation = canvasContainer.center
    }
    
    @IBAction func drawOnCanvas(sender: UIPanGestureRecognizer) {
        drawingFunctions().drawOnCanvas(self.canvasView, cache: self.cacheDrawingView, tempCache: self.tempDrawingView, sender: sender)
    }
    @IBAction func tappedOnCanvas(sender: UITapGestureRecognizer) {
        drawingFunctions().tapOnCanvas(self.canvasView, cache: self.cacheDrawingView, sender: sender)
    }
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            cacheDrawingView.image = nil
        }
    }
    
    // Expand Radial Menus
    func expandRadialMenu(item:UIView, scalefactor:CGFloat) {
        UIView.animateWithDuration(0.15,
            delay: 0.1,
            options: .CurveEaseInOut | .AllowUserInteraction,
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
            options: .CurveEaseInOut | .AllowUserInteraction,
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
        UIView.animateWithDuration(0.5,
            delay: 0,
            options: .CurveEaseInOut | .AllowUserInteraction,
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
        let toolBox: [[String:AnyObject]] = [
            ["name": "Pencil", "image": pencilImage, "white": pencilwhite, "black": pencilblack, "color": UIColor.blackColor()],
            ["name": "Shape", "image": shapeImage, "white": shapewhite, "black": shapeblack, "color": UIColor.blackColor()],
            ["name": "Eraser", "image": eraserImage, "white": eraserwhite, "black": eraserblack, "color": UIColor.whiteColor()]
        ]
        for (var i=0; i<toolBox.count; i++) {
            if toolBox[i]["name"] as! String == tool {
                canvasView.lineColor = toolBox[i]["color"] as! UIColor
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
        eraserImage.layer.backgroundColor = defaultColor
        eraserImage.image = eraserblack
    }
    
    // Reset shape icon
    func resetShape() {
        shapeImage.layer.backgroundColor = defaultColor
        shapeImage.image = shapeblack
    }
    
    // Reset pencil icon
    func resetPencil() {
        pencilImage.layer.backgroundColor = defaultColor
        pencilImage.image = pencilblack
    }
    
    // Reset backgrounds and color on tool icons in picker
    func resetTools() {
        resetShape()
        resetEraser()
        resetPencil()
    }
    
    func calcDistance(point1:CGPoint, point2:CGPoint) -> CGFloat {
        var deltaX = point2.x - point1.x
        var deltaY = point2.y - point1.y
        var distance = sqrt(pow(deltaX, 2) + pow(deltaY, 2))
        
        return distance
    }
    
    func calcAngle(point1:CGPoint, point2:CGPoint) -> CGFloat {
        var deltaX = point2.x - point1.x
        var deltaY = point2.y - point1.y
        var angle = atan2(deltaY, deltaX) * 360 / CGFloat(M_PI)
        return angle
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        canvasTranslation = CGPoint(x: view.frame.width/2, y: (view.frame.height/2) + 10)
        
        defaultColor = pencilImage.layer.backgroundColor
        
        // Rotate Images 45 Degrees
        checkerBoardImage.transform = CGAffineTransformRotate(checkerBoardImage.transform, CGFloat(M_PI/4))
        toolPickerButtonInner.transform = CGAffineTransformRotate(toolPickerButtonInner.transform, CGFloat(M_PI/4))

        
    }
    
    override func viewDidLayoutSubviews() {
        canvasContainer.center = canvasTranslation
        colorPickerBorder.layer.cornerRadius = colorPickerBorder.frame.width/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

