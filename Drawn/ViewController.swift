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
    @IBOutlet weak var cacheDrawingView: UIImageView!
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var gestureControlView: UIView!
    @IBOutlet weak var menuBGMask: UIView!
    @IBOutlet weak var toolPickerLayer2: UIView!
    @IBOutlet weak var toolPickerButton: UIView!
    @IBOutlet weak var toolPickerButtonInner: UIButton!
    @IBOutlet weak var pencilImage: UIImageView!
    @IBOutlet weak var shapeImage: UIImageView!
    @IBOutlet weak var eraserImage: UIImageView!
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
    let pencilwhite = UIImage(named: "pencil_white") as UIImage!
    let pencilblack = UIImage(named: "pencil_black") as UIImage!
    let shapewhite = UIImage(named: "star_white") as UIImage!
    let shapeblack = UIImage(named: "star_black") as UIImage!
    let eraserwhite = UIImage(named: "eraser_white") as UIImage!
    let eraserblack = UIImage(named: "eraser_black") as UIImage!
    var offsetdistance = CGFloat(0)
    
    
    // Actions for ToolPicker Button
    @IBAction func toolPickerGesture(sender: UIPanGestureRecognizer) {
        if (offsetdistance > 4 && toolsneedsscale == true) {
            expandRadialMenu(toolPickerButton, scalefactor: 1.1)
            expandRadialMenu(toolPickerLayer2, scalefactor: 1.1)
            toolsneedsscale = false
        }
        
        let location = sender.locationInView(toolPickerButton)
        let center = CGPoint(x: 20, y: 20)
        offsetdistance = calcDistance(center, point2: location)
        let offsetangle = calcAngle(center, point2: location)

        if (offsetangle < -60 && offsetdistance > 12) {
            setPencilActive()
            resetEraser()
            resetShape()
        }
        else if (offsetangle < 0 && offsetangle >= -30 && offsetdistance > 12) {
            setEraserActive()
            resetPencil()
            resetShape()
        }
        else if (offsetangle < -30 && offsetangle >= -60 && offsetdistance > 12) {
            setShapeActive()
            resetEraser()
            resetPencil()
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
    
    // Actions for Size/Opacity Button
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
    }
    
    @IBAction func drawOnCanvas(sender: UIPanGestureRecognizer) {
        drawingFunctions().drawOnCanvas(self.canvasView, cache: self.cacheDrawingView, sender: sender)
    }
    
    @IBAction func clearCanvas(sender: UISwipeGestureRecognizer) {
        cacheDrawingView.image = nil
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
    
    func addShadow(item:UIView) {
        item.layer.shadowColor = UIColor.blackColor().CGColor
        item.layer.shadowOpacity = 0.05
        item.layer.shadowRadius = 1
        item.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func removeShadow(item:UIView) {
        item.layer.shadowColor = nil
        item.layer.shadowOpacity = 0
        item.layer.shadowRadius = 0
    }
    
    func addBorder(item:UIView) {
        item.layer.borderWidth = 0.15
        let lightgray = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).CGColor
        item.layer.borderColor = lightgray
    }
    
    func removeBorder(item:UIView) {
        item.layer.borderWidth = 0
        item.layer.borderColor = nil
    }
    
    func setEraserActive() {
        canvasView.lineColor = UIColor.whiteColor()
        eraserImage.layer.backgroundColor = UIColor.blackColor().CGColor
        eraserImage.image = eraserwhite
    }
    
    func setShapeActive() {
        shapeImage.layer.backgroundColor = UIColor.blackColor().CGColor
        shapeImage.image = shapewhite
    }
    
    func setPencilActive() {
        canvasView.lineColor = UIColor.blackColor()
        pencilImage.layer.backgroundColor = UIColor.blackColor().CGColor
        pencilImage.image = pencilwhite
    }
    
    func resetEraser() {
        eraserImage.layer.backgroundColor = defaultColor
        eraserImage.image = eraserblack
    }
    
    func resetShape() {
        shapeImage.layer.backgroundColor = defaultColor
        shapeImage.image = shapeblack
    }
    
    func resetPencil() {
        pencilImage.layer.backgroundColor = defaultColor
        pencilImage.image = pencilblack
    }
    
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
        var deltaX = point2.x - point2.y
        var deltaY = point2.y - point1.y

        var angle = atan2(deltaY, deltaX) * 360 / CGFloat(M_PI)
        return angle
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        defaultColor = pencilImage.layer.backgroundColor
        
        // Rotate Images 45 Degrees
        checkerBoardImage.transform = CGAffineTransformRotate(checkerBoardImage.transform, CGFloat(M_PI/4))
        toolPickerButtonInner.transform = CGAffineTransformRotate(toolPickerButtonInner.transform, CGFloat(M_PI/4))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

