//
//  ViewController.swift
//  Drawn
//
//  Created by Jarom Vogel on 6/7/15.
//  Copyright (c) 2015 Jarom Vogel. All rights reserved.
//

import UIKit
import Darwin
import SwiftyJSON


class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }


    @IBOutlet weak var menuBGMask: UIView!
    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var canvasContainer: UIView!
    
    @IBOutlet weak var containerCenterY: NSLayoutConstraint!
    @IBOutlet weak var containerCenterX: NSLayoutConstraint!
    @IBOutlet weak var canvasWidth: NSLayoutConstraint!
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    
    @IBOutlet weak var canvasTexture: UIImageView!
    @IBOutlet weak var tempDrawingView: UIImageView!
    @IBOutlet weak var cacheDrawingView: UIImageView!
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var tapToFinishButton: UIButton!
    @IBOutlet weak var gestureControlView: UIView!
    
    @IBOutlet weak var scaleLabel: UIView!
    @IBOutlet weak var scaleLabelText: UILabel!
    
    @IBOutlet weak var colorPickerContainer: UIView!
    @IBOutlet weak var colorPickerBorder: UIView!
    @IBOutlet weak var colorPickerImage: UIImageView!
    @IBOutlet weak var currentColorSlider: UIView!
    @IBOutlet weak var currentColor: UIView!
    @IBOutlet weak var brightnessGradient: UIView!
    @IBOutlet weak var brightnessCurrentColor: UIView!
    @IBOutlet weak var brightnessControl: UIView!
    @IBOutlet weak var brightnessSlider: UIView!
    
    // Views to gather and combine subviews for performance reasons
    @IBOutlet weak var gatherLayers: UIView!
    @IBOutlet weak var compositeImage: UIImageView!
    
    var toolsneedsscale = true
    var toolsneedsscale2 = true
    var paper_texture = UIImage(named: "paper-small") as UIImage!
    var muddy_colors = UIImage()
    var splatter_texture = UIImage(named: "splatter-texture") as UIImage!
    var muddy_tile = UIImage(named: "muddy-colors-tile") as UIImage!
    var splatter_tile = UIImage(named: "splatter-tile") as UIImage!
    var paper_tile = UIImage(named: "paper-tile") as UIImage!
    var pencil_tile = UIImage(named: "pencil-tile") as UIImage!
    var pencil_texture = UIImage()
    var light_paper_texture = UIImage()
    var offsetdistance = CGFloat(0)
    var coloroffsetdistance = CGFloat(0)
    var colorangle = CGFloat(0)
    var canvasTranslation = CGPoint()
    var brightness = CGFloat(1)
    var colorPicked = false
    var deviceRotation = Int(1)
    var panGestureActive = false
    
    var shapelayer = CAShapeLayer()
    
    
    // Actions for Color Chooser Wheel and Brightness Slider
    @IBAction func colorPickerPanGesture(sender: UIPanGestureRecognizer) {
        panGestureActive = true
        let location = sender.locationInView(colorPickerBorder)
        let pickerCenter = colorPickerImage.center
        offsetdistance = calcDistance(pickerCenter, point2: location)
        let checkdistance = (100 * offsetdistance / (colorPickerImage.frame.width / 2))
        if checkdistance <= 100 {
            coloroffsetdistance = checkdistance
            colorangle = calcAngle(pickerCenter, point2: location)
            setColor(true)
            if colorPicked == false {
                brightnessControl.center.x = brightnessSlider.frame.width - 18
                colorPicked = true
            }
        }
        if checkdistance <= 120 {
            currentColorSlider.hidden = false
            currentColorSlider.center = location
        }
        if sender.state == UIGestureRecognizerState.Ended {
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.panGestureActive = false
            }
        }
    }

    @IBAction func tappedColorWheel(sender: UITapGestureRecognizer) {
        if panGestureActive == false {
            let location = sender.locationInView(colorPickerBorder)
            let pickerCenter = colorPickerImage.center
            offsetdistance = calcDistance(pickerCenter, point2: location)
            let checkdistance = (100 * offsetdistance / (colorPickerImage.frame.width / 2))
            if checkdistance <= 100 {
                coloroffsetdistance = checkdistance
                colorangle = calcAngle(pickerCenter, point2: location)
                setColor(true)
                if colorPicked == false {
                    brightnessControl.center.x = brightnessSlider.frame.width - 18
                    colorPicked = true
                }
                currentColorSlider.hidden = false
                currentColorSlider.center = location
            }
        }
    }
    @IBAction func tappedBrightnessSlider(sender: UITapGestureRecognizer) {
        let sliderLocation = sender.locationInView(brightnessSlider).x
        brightness = sliderLocation / brightnessSlider.frame.width
        brightnessControl.center.x = sliderLocation
        setColor(false)
    }
    @IBAction func panBrightnessSlider(sender: UIPanGestureRecognizer) {
        // this sort of works, but definitely NEEDS work
        var sliderLocation = sender.locationInView(brightnessSlider).x
        brightness = sliderLocation / brightnessSlider.frame.width
        if sliderLocation >= brightnessSlider.frame.width - 18 {
            sliderLocation = brightnessSlider.frame.width - 18
        } else if sliderLocation <= 18 {
            sliderLocation = 18
        }
        brightnessControl.center.x = sliderLocation
        setColor(false)
    }
    
    // eyedropper Tool
    func eyedropperTool(location: CGPoint, sender: AnyObject) {
        if cacheDrawingView.image !== nil {
            let newColor = getPixelColor(location)
            selectedcolor.value = newColor
            activecolor.value = newColor
            lineOpacity = 1
        }
        
        if sender.state == UIGestureRecognizerState.Ended {
            selectedTool.value = previousTool.value
            eyedropperActive.value = false
            self.addRecentColor(selectedcolor.value)
            cacheDrawingView.image = nil
        }
    }
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixel = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = UInt32(CGImageAlphaInfo.PremultipliedLast.rawValue)

        let context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, bitmapInfo)
        
        CGContextTranslateCTM(context, -pos.x, -pos.y)
        cacheDrawingView.layer.renderInContext(context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0, green: CGFloat(pixel[1])/255.0, blue: CGFloat(pixel[2])/255.0, alpha: CGFloat(pixel[3])/255.0)
        
        pixel.dealloc(4)
        return color
    }
    
    
    // Manipulate the canvas
    @IBAction func rotateCanvas(sender: UIRotationGestureRecognizer) {
        canvasGestures().rotateCanvas(canvasView, canvasContainer: canvasContainer, gestureControlView: gestureControlView, sender: sender, centerX: containerCenterX, centerY: containerCenterY, scaleLabel: scaleLabel)
    }
    @IBAction func zoomCanvas(sender: UIPinchGestureRecognizer) {
        canvasGestures().zoomCanvas(canvasView, canvasContainer: canvasContainer, gestureControlView: gestureControlView, sender: sender, centerX: containerCenterX, centerY: containerCenterY, tapToFinishButton: tapToFinishButton, scaleLabel: scaleLabel, scaleLabelText: scaleLabelText)
    }
    @IBAction func panCanvas(sender: UIPanGestureRecognizer) {
        canvasGestures().panCanvas(self.canvasContainer, containerView: self.view, centerX: containerCenterX, centerY: containerCenterY, sender: sender, scaleLabel: scaleLabel)
    }
    
    // Functions for drawing on the canvas
    @IBAction func drawOnCanvas(sender: UIPanGestureRecognizer) {
        //This should make sure that shapelayer is always the last layer
        shapelayer.superlayer?.addSublayer(shapelayer)
        
        panGestureActive = true
        if selectedTool.value == "Pencil" || selectedTool.value == "Eraser" {
            drawingFunctions().drawOnCanvas(self.canvasView, canvasContainer: canvasContainer, cache: self.cacheDrawingView, tempCache: self.tempDrawingView, shapelayer: shapelayer, pencil_texture: pencil_texture, sender: sender)
        } else if selectedTool.value == "Shape" {
            drawingFunctions().drawShapeOnCanvas(self.canvasView, canvasContainer: canvasContainer, cache: self.cacheDrawingView, tempCache: self.tempDrawingView, shapelayer: shapelayer, sender: sender, tapToFinishButton: tapToFinishButton, paper_texture: paper_texture, muddy_colors: muddy_colors, splatter_texture: splatter_texture)
        } else if selectedTool.value == "Eyedropper" {
            let location = sender.locationInView(canvasContainer)
            eyedropperTool(location, sender: sender)
        }
        if selectedTool.value != "Eyedropper" {
            combineLayers(sender)
        }
        if sender.state == UIGestureRecognizerState.Ended {
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.panGestureActive = false
            }
        }
    }
    @IBAction func tappedOnCanvas(sender: UITapGestureRecognizer) {
        //This should make sure that shapelayer is always the last layer
        shapelayer.superlayer?.addSublayer(shapelayer)
        
        if panGestureActive == false {
            if selectedTool.value == "Pencil" || selectedTool.value == "Eraser" {
                drawingFunctions().tapOnCanvas(self.canvasView, canvasContainer: canvasContainer, cache: self.cacheDrawingView, tempCache: self.tempDrawingView, shapelayer: shapelayer, sender: sender)
            } else if selectedTool.value == "Shape" {
                drawingFunctions().buildShape(self.canvasView, canvasContainer: canvasContainer, cache: self.cacheDrawingView, tempCache: self.tempDrawingView, sender: sender, shapelayer: shapelayer, tapToFinishButton: tapToFinishButton, paper_texture: paper_texture, muddy_colors: muddy_colors, splatter_texture: splatter_texture)
            } else if selectedTool.value == "Eyedropper" {
                let location = sender.locationInView(canvasContainer)
                eyedropperTool(location, sender: sender)
            }
            if selectedTool.value != "Eyedropper" {
                combineLayers(sender)
            }
        }
    }
    @IBAction func doubleTappedCanvas(sender: UITapGestureRecognizer) {
        if selectedTool.value == "Shape" {
            finishShape()
        }
    }
    @IBAction func UndoButton(sender: UIButton) {
        //This should make sure that shapelayer is always the last layer
        shapelayer.superlayer?.addSublayer(shapelayer)
        
        if canvasView.layer.sublayers?.count > 2 {
            var selectedlayer: CALayer
            selectedlayer = (canvasView.layer.sublayers?[0] as CALayer?)!
            selectedlayer = (canvasView.layer.sublayers?[(canvasView.layer.sublayers?.count)! - 2] as CALayer?)!
            selectedlayer.removeFromSuperlayer()
            //canvasView.subviews.last?.removeFromSuperview()
        }
    }
    
    @IBAction func sendData(sender: UIButton) {
        drawingFunctions().renderLayersToCache(canvasView, canvasContainer: canvasContainer, cache: cacheDrawingView)
        connect().post(cacheDrawingView, canvasView: canvasView)
    }
    
    @IBAction func getData(sender: UIButton) {
        connect().get(compositeImage)
    }
    
    
    
    func combineLayers(sender: AnyObject) {
        // This gathers the lowest drawing layers and combines them into a single layer to help with performance
        if sender.state == UIGestureRecognizerState.Ended && canvasView.subviews.count > 21 {
            let lowestlayer = canvasView.subviews[1] as! UIImageView
            gatherLayers.insertSubview(lowestlayer, aboveSubview: gatherLayers.subviews.last!)
            UIGraphicsBeginImageContextWithOptions(canvasView.frame.size, false, 0.0)
            //gatherLayers.drawViewHierarchyInRect(canvasView.bounds, afterScreenUpdates: false)
            gatherLayers.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            compositeImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            for subview in gatherLayers.subviews {
                if subview != compositeImage {
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    // Finish building shape
    func finishShape() {
        drawingFunctions().finishShape(self.canvasView, canvasContainer: canvasContainer, cache: self.cacheDrawingView, tempCache: self.tempDrawingView, shapelayer: shapelayer, tapToFinishButton: tapToFinishButton, paper_texture: paper_texture, muddy_colors: muddy_colors, splatter_texture: splatter_texture)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            let newlayer = CALayer()
            newlayer.frame = canvasView.frame
            
            UIGraphicsBeginImageContextWithOptions(canvasView.frame.size, false, 2.0)
            
            let drawingRect = CGRect(x: 0, y: 0, width: canvasView.frame.size.width, height: canvasView.frame.size.height)
            
            UIColor.whiteColor().setFill()
            UIRectFillUsingBlendMode(drawingRect, CGBlendMode.Normal)
            
            newlayer.contents = UIGraphicsGetImageFromCurrentImageContext().CGImage
            canvasView.layer.insertSublayer(newlayer, below: shapelayer)
            
            UIGraphicsEndImageContext()
        }
    }
    
    @IBAction func saveToCameraRoll(sender: AnyObject) {
        drawingFunctions().renderLayersToCache(canvasView, canvasContainer: canvasContainer, cache: cacheDrawingView)
        UIImageWriteToSavedPhotosAlbum(cacheDrawingView.image!, nil, nil, nil)
    }
    
    
    func displayColorPicker(hidden: Bool) {
        colorPickerContainer.hidden = hidden
    }
    
    func setColor(updateBrightness: Bool) {
        let newColor = colorWheel().calcColor(colorangle, distance: coloroffsetdistance, brightness: brightness)
        let baseColor = colorWheel().calcBaseColor(colorangle, distance: coloroffsetdistance)
        if updateBrightness == true {
            brightnessGradient.backgroundColor = baseColor
            currentColor.backgroundColor = baseColor
        }
        brightnessCurrentColor.backgroundColor = newColor
        selectedcolor.value = newColor
        activecolor.value = newColor
    }
    
    func initializeTool(tool: String) {
        if tool == "Eyedropper" {
            drawingFunctions().renderLayersToCache(canvasView, canvasContainer: canvasContainer, cache: cacheDrawingView)
            eyedropperActive.value = true
        }
    }


    // Show/Hide Mask
    func toggleMask(visible: Bool) {
        if visible == true {
            // Adjust Menu Background Mask Size
            let screenSize = UIScreen.mainScreen().bounds
            menuBGMask.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
            spring(0.5, animations: {
                self.menuBGMask.layer.opacity = 0.2
                self.menuBGMask.hidden = false
            })
        } else {
            springComplete(0.5, animations: {
                self.menuBGMask.layer.opacity = 0
            }, completion: {
                (value: Bool) in
                self.menuBGMask.hidden = true
            })
        }
    }
    
    func addRecentColor(newcolor: UIColor) {
        if recentcolors.value[0] != newcolor {
            recentcolors.value.insert(newcolor, atIndex: 0)
            recentcolors.value.removeLast()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add shape layer to canvasView to draw into
        canvasView.layer.addSublayer(shapelayer)
        shapelayer.fillColor = nil
        shapelayer.name = "shapelayer"
        
        // Set size of canvas and scale it appropriately
        canvasWidth.constant = view.frame.width
        canvasHeight.constant = view.frame.height

        // Create Gradient for Brightness Slider
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: brightnessGradient.frame.size.width, height: brightnessGradient.frame.size.height)
        
        brightnessGradient.layer.insertSublayer(gradient, atIndex: 1)
        
        muddy_colors = makeImageFromTile(muddy_tile)
        splatter_texture = makeImageFromTile(splatter_tile)
        paper_texture = makeImageFromTile(paper_tile)
        pencil_texture = makeImageFromTile(pencil_tile)
        
        scaleLabel.layer.borderWidth = CGFloat(2.0)
        scaleLabel.layer.borderColor = UIColor.whiteColor().CGColor
        
        tapToFinishButton.frame = CGRectMake(0, 0, 25, 25)
        tapToFinishButton.layer.cornerRadius = CGFloat(12.5)
        
        // Bind Dynamic Variables
        maskVisible.bind {
            self.toggleMask($0)
        }
        
        selectedTool.bind {
            self.initializeTool($0)
        }
        
        selectedcolor.bind {
            backgroundcolor.value = $0
        }
        
        colorPickerHidden.bind {
            self.displayColorPicker($0)
        }
        
        // Register for Remote Push Notifications
        UIApplication.sharedApplication().registerForRemoteNotifications()

        
        // Prompt user to accept notifications
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)

    }
    
    func makeImageFromTile(tileImage: UIImage!) -> UIImage {
        // Create Images from tiles
        // let imagesize = UIScreen.mainScreen().bounds.size
        let imagesize = CGSizeMake(canvasView.frame.width, canvasView.frame.height)
        UIGraphicsBeginImageContextWithOptions(imagesize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawTiledImage(context, CGRectMake(0, 0, 200, 200), tileImage.CGImage)
        let full_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return full_image
    }
        
    override func viewDidLayoutSubviews() {
        //canvasContainer.center = canvasTranslation
        colorPickerBorder.layer.cornerRadius = colorPickerBorder.frame.width/2
        deviceRotation = UIDevice.currentDevice().orientation.rawValue

        // Prevent scale label from flickering
        scaleLabel.hidden = !scalelabel_visible
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        steadyCanvas(deviceRotation, newRotation: UIDevice.currentDevice().orientation.rawValue)
        deviceRotation = UIDevice.currentDevice().orientation.rawValue
    }
    
    func steadyCanvas(currentRotation: Int, newRotation: Int) {
        print(abs(currentRotation - newRotation))
        if (currentRotation == 1 && newRotation == 2) || (currentRotation == 2 && newRotation == 1) || (currentRotation == 3) && (newRotation == 4) || (currentRotation == 4) && (newRotation == 3) {
            print("should rotate 180 deg")
        } else  if currentRotation == 1 && newRotation == 3 || currentRotation == 3 && newRotation == 2 || currentRotation == 2 && newRotation == 4 || currentRotation == 4 && newRotation == 1 {
            print("should rotate negative 90 degrees")
        } else {
            print("should rotate 90 degrees")
        }
    }
    
}

