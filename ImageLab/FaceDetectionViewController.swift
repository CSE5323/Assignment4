//
//  FaceDetectionViewController.swift
//  ImageLab
//
//  Created by Jenn Le on 10/15/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

class FaceDetectionViewController: UIViewController{
    
    //MARK: Class Properties
    var filters : [CIFilter]! = nil
    var videoManager:VideoAnalgesic! = nil
    let pinchFilterIndex = 2
    var detector:CIDetector! = nil
    let bridge = OpenCVBridgeSub()
    
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = nil
        
        self.videoManager = VideoAnalgesic.sharedInstance
        
        //We're only using the back camera for this
        self.videoManager.setCameraPosition(AVCaptureDevicePosition.back)
        
//        self.videoManager.setProcessingBlock(self.processImage)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        
    }
    
    //MARK: Process image output
//    func processImage(_ inputImage:CIImage) -> CIImage{
//        
//        // detect faces
//        let f = getFaces(inputImage)
//        
//        // if no faces, just return original image
//        if f.count == 0 { return inputImage }
//        
//        var retImage = inputImage
//        
//        // if you just want to process on separate queue use this code
//        // this is a NON BLOCKING CALL, but any changes to the image in OpenCV cannot be displayed real time
//        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
//        //            self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
//        //            self.bridge.processImage()
//        //        }
//        
//        // use this code if you are using OpenCV and want to overwrite the displayed image via OpenCv
//        // this is a BLOCKING CALL
//        //        self.bridge.setTransforms(self.videoManager.transform)
//        //        self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
//        //        self.bridge.processImage()
//        //        retImage = self.bridge.getImage()
//        
//        //HINT: you can also send in the bounds of the face to ONLY process the face in OpenCV
//        // or any bounds to only process a certain bounding region in OpenCV
//        self.bridge.setTransforms(self.videoManager.transform)
//        self.bridge.setImage(retImage,
//                             withBounds: f[0].bounds, // the first face bounds
//            andContext: self.videoManager.getCIContext())
//        
//        self.bridge.processImage()
//        retImage = self.bridge.getImageComposite() // get back opencv processed part of the image (overlayed on original)
//        
//        return retImage
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        if(self.videoManager.isRunning){
//            self.videoManager.turnOffFlash()
//            self.videoManager.stop()
//            self.videoManager.shutdown()
//        }
//    }
//    
//    func getFaces(_ img:CIImage) -> [CIFaceFeature]{
//        // this ungodly mess makes sure the image is the correct orientation
//        //let optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]
//        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
//        // get Face Features
//        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
//        
//    }
    

}
