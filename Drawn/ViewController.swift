//
//  ViewController.swift
//  Drawn
//
//  Created by Jarom Vogel on 6/7/15.
//  Copyright (c) 2015 Jarom Vogel. All rights reserved.
//

import UIKit
import Darwin

// Extend UIImage to be able to check the color of a pixel
extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}


class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }


    @IBOutlet weak var menuBGMask: UIView!
    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var canvasContainer: UIView!
    @IBOutlet weak var canvasTexture: UIImageView!
    @IBOutlet weak var tempDrawingView: UIImageView!
    @IBOutlet weak var cacheDrawingView: UIImageView!
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var tapToFinishButton: UIButton!
    @IBOutlet weak var gestureControlView: UIView!
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
    var light_paper_texture = UIImage()
    var offsetdistance = CGFloat(0)
    var coloroffsetdistance = CGFloat(0)
    var colorangle = CGFloat(0)
    var canvasTranslation = CGPoint()
    var brightness = CGFloat(1)
    var colorPicked = false
    var deviceRotation = Int(1)
    
    
    // Actions for Color Chooser Wheel and Brightness Slider
    @IBAction func colorPickerPanGesture(sender: UIPanGestureRecognizer) {
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
    }
    @IBAction func tappedColorWheel(sender: UITapGestureRecognizer) {
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
        canvasGestures().rotateCanvas(self.canvasContainer, containerView: self.view, sender: sender)
    }
    @IBAction func zoomCanvas(sender: UIPinchGestureRecognizer) {
        canvasGestures().zoomCanvas(self.canvasContainer, sender: sender, tapToFinishButton: tapToFinishButton)
    }
    @IBAction func panCanvas(sender: UIPanGestureRecognizer) {
        canvasGestures().panCanvas(self.canvasContainer, containerView: self.view, sender: sender)
        canvasTranslation = canvasContainer.center
    }
    
    // Functions for drawing on the canvas
    @IBAction func drawOnCanvas(sender: UIPanGestureRecognizer) {
        if selectedTool.value == "Pencil" || selectedTool.value == "Eraser" {
            drawingFunctions().drawOnCanvas(self.canvasView, canvasContainer: canvasContainer, cache: self.cacheDrawingView, tempCache: self.tempDrawingView, sender: sender)
        } else if selectedTool.value == "Shape" {
            drawingFunctions().drawShapeOnCanvas(self.canvasView, canvasContainer: canvasContainer, cache: self.cacheDrawingView, tempCache: self.tempDrawingView, sender: sender, tapToFinishButton: tapToFinishButton, paper_texture: paper_texture, muddy_colors: muddy_colors, splatter_texture: splatter_texture)
        } else if selectedTool.value == "Eyedropper" {
            let location = sender.locationInView(canvasContainer)
            eyedropperTool(location, sender: sender)
        }
        if selectedTool.value != "Eyedropper" {
            combineLayers(sender)
        }
    }
    @IBAction func tappedOnCanvas(sender: UITapGestureRecognizer) {
        if selectedTool.value == "Pencil" || selectedTool.value == "Eraser" {
            drawingFunctions().tapOnCanvas(self.canvasView, canvasContainer: canvasContainer, cache: self.cacheDrawingView, tempCache: self.tempDrawingView, sender: sender)
        } else if selectedTool.value == "Shape" {
            drawingFunctions().buildShape(self.canvasView, canvasContainer: canvasContainer, cache: self.cacheDrawingView, tempCache: self.tempDrawingView, sender: sender, tapToFinishButton: tapToFinishButton, paper_texture: paper_texture, muddy_colors: muddy_colors, splatter_texture: splatter_texture)
        } else if selectedTool.value == "Eyedropper" {
            let location = sender.locationInView(canvasContainer)
            eyedropperTool(location, sender: sender)
        }
        if selectedTool.value != "Eyedropper" {
            combineLayers(sender)
        }
    }
    @IBAction func doubleTappedCanvas(sender: UITapGestureRecognizer) {
        if selectedTool.value == "Shape" {
            finishShape()
        }
    }
    @IBAction func UndoButton(sender: UIButton) {
        if canvasView.subviews.count > 1 {
            canvasView.subviews.last?.removeFromSuperview()
        }
    }
    
    func combineLayers(sender: AnyObject) {
        // This gathers the lowest drawing layers and combines them into a single layer to help with performance
        if sender.state == UIGestureRecognizerState.Ended && canvasView.subviews.count > 21 {
            let lowestlayer = canvasView.subviews[2] as! UIImageView
            gatherLayers.insertSubview(lowestlayer, aboveSubview: gatherLayers.subviews.last!)
            
            UIGraphicsBeginImageContextWithOptions(canvasView.frame.size, false, 0.0)
            gatherLayers.drawViewHierarchyInRect(canvasView.bounds, afterScreenUpdates: true)
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
        drawingFunctions().finishShape(self.canvasView, canvasContainer: canvasContainer, cache: self.cacheDrawingView, tempCache: self.tempDrawingView, tapToFinishButton: tapToFinishButton, paper_texture: paper_texture, muddy_colors: muddy_colors, splatter_texture: splatter_texture)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            let whiteView = UIImageView()
            whiteView.backgroundColor = UIColor.whiteColor()
            whiteView.image = light_paper_texture
            whiteView.frame = canvasView.frame
            if canvasView.subviews.count > 0 {
                canvasView.insertSubview(whiteView, aboveSubview: canvasView.subviews.last!)
            } else {
                canvasView.insertSubview(whiteView, atIndex: 0)
            }
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        canvasTranslation = CGPoint(x: view.frame.width/2, y: (view.frame.height/2) + 10)
        canvasContainer.center = canvasTranslation
        
        // Create Gradient for Brightness Slider
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: brightnessGradient.frame.size.width, height: brightnessGradient.frame.size.height)
        
        brightnessGradient.layer.insertSublayer(gradient, atIndex: 1)
        
        // Create Paper texture to use for canvas background
        UIGraphicsBeginImageContextWithOptions(canvasView.frame.size, false, 0.0)
        
        paper_texture.drawInRect(CGRectMake(0, 0, canvasView.frame.size.width, canvasView.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 0.2)
        light_paper_texture = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        canvasTexture.image = light_paper_texture
        
        muddy_colors = makeImageFromTile(muddy_tile)
        splatter_texture = makeImageFromTile(splatter_tile)

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
    }
    
    func makeImageFromTile(tileImage: UIImage!) -> UIImage {
        // Create Images from tiles
        let imagesize = CGSizeMake(canvasView.frame.size.width, canvasView.frame.size.height)
        UIGraphicsBeginImageContextWithOptions(imagesize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawTiledImage(context, CGRectMake(0, 0, 200, 200), tileImage.CGImage)
        let full_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return full_image
    }
        
    override func viewDidLayoutSubviews() {
        canvasContainer.center = canvasTranslation
        colorPickerBorder.layer.cornerRadius = colorPickerBorder.frame.width/2
        deviceRotation = UIDevice.currentDevice().orientation.rawValue
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

