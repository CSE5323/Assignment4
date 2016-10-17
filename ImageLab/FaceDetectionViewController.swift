//
//  FaceDetectionViewController.swift
//  ImageLab
//
//  Created by Jenn Le on 10/15/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

@available(iOS 10.0, *)
class ViewController: UIViewController   {
    
    //MARK: Class Properties
    var filters : [CIFilter]! = nil
    var videoManager:VideoAnalgesic! = nil
    let pinchFilterIndex = 2
    var detector:CIDetector! = nil
    
    let face :CIFilter = CIFilter(name: "CIRadialGradient")!
    let eyes :CIFilter = CIFilter(name: "CIRadialGradient")!
    let mouth :CIFilter = CIFilter(name: "CIRadialGradient")!
    
    
    
    
    //MARK: ViewController Hierarchy
    //    @available(iOS 10.0, *)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        self.setupFilters()
        
        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(AVCaptureDevicePosition.front)
        
        //keep in mind that the limit does not exist
        //sorry it's late and i'm dying
        
        
        // create dictionary for face detection
        // HINT: you need to manipulate these proerties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        
        // setup a face detector in swift
        self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                   context: self.videoManager.getCIContext(), // perform on the GPU is possible
            options: optsDetector)
        
        self.videoManager.setProcessingBlock(self.processImage)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        
    }
    
    //MARK: Setup filtering
    func setupFilters(){
        filters = []
        
        //        let face :CIFilter = CIFilter(name: "CIRadialGradient")!
        //        let eyes :CIFilter = CIFilter(name: "CIRadialGradient")!
        //        let mouth :CIFilter = CIFilter(name: "CIRadialGradient")!
        //
        self.face.setValue(CIColor(red: 1, green: 1, blue: 1, alpha: 0.0), forKey: "inputColor0")
        self.face.setValue(CIColor(red: 0.2, green: 2.0, blue: 0.2, alpha: 0.2), forKey: "inputColor1")
        self.eyes.setValue(CIColor(red: 1, green: 1, blue: 1, alpha: 0.0), forKey: "inputColor0")
        self.eyes.setValue(CIColor(red: 2.0, green: 0.2, blue: 0.2, alpha: 0.5), forKey: "inputColor1")
        self.mouth.setValue(CIColor(red: 1, green: 1, blue: 1, alpha: 0.0), forKey: "inputColor0")
        self.mouth.setValue(CIColor(red: 0.2, green: 0.2, blue: 2.0, alpha: 0.5), forKey: "inputColor1")
        //
        //        filters.append(face)
        //        filters.append(eyes)
        //        filters.append(mouth)
        
    }
    
    //MARK: Apply filters and apply feature detectors
    func applyFiltersToFaces(inputImage:CIImage,features:[CIFaceFeature])->CIImage{
        var retImage = inputImage
        var filterCenter = CGPoint()
        
        for f in features {
            //set where to apply filter
            filterCenter.x = f.bounds.midX
            filterCenter.y = f.bounds.midY
            
            let f_width = f.bounds.size.width;
            //            let f_height = f.bounds.size.height;
            
            //do for each filter (assumes all filters have property, "inputCenter")
            for filt in filters{
                filt.setValue(retImage, forKey: "kCIInputImageKey")
                
                filt.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
                // could also manipualte the radius of the filter based on face size!
                retImage = filt.outputImage!
            }
            
            //setting up the face gradient
            self.face.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
            self.face.setValue(f_width/2 , forKey: "inputRadius0")
            self.face.setValue(f_width/2 - 10, forKey: "inputRadius1")
            let combineFilter :CIFilter = CIFilter(name: "CISourceOverCompositing")!
            combineFilter.setValue(self.face.outputImage, forKey: "inputImage")
            combineFilter.setValue(retImage, forKey: "inputBackgroundImage")
            retImage = combineFilter.outputImage!
            
            
            
            if (f.hasLeftEyePosition){
                //println("Left eye: ", f.leftEyePosition.x, f.leftEyePosition.y);
                filterCenter.x = f.leftEyePosition.x
                filterCenter.y = f.leftEyePosition.y
                self.eyes.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
                self.eyes.setValue(f_width/12, forKey: "inputRadius0")
                self.eyes.setValue(f_width/12 - 5, forKey: "inputRadius1")
                
                
                combineFilter.setValue(self.eyes.outputImage, forKey: "inputImage")
                combineFilter.setValue(retImage, forKey: "inputBackgroundImage")
                retImage = combineFilter.outputImage!
            }
            
            if (f.hasRightEyePosition){
                //println("Right eye: ", f.rightEyePosition.x, f.rightEyePosition.y);
                filterCenter.x = f.rightEyePosition.x
                filterCenter.y = f.rightEyePosition.y
                self.eyes.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
                self.eyes.setValue(f_width/12, forKey: "inputRadius0")
                self.eyes.setValue(f_width/12 - 5, forKey: "inputRadius1")
                
                
                combineFilter.setValue(self.eyes.outputImage, forKey: "inputImage")
                combineFilter.setValue(retImage, forKey: "inputBackgroundImage")
                retImage = combineFilter.outputImage!
            }
            
            
            if (f.hasMouthPosition){
                //print("Mouth: ", f.mouthPosition.x, f.mouthPosition.y);
                filterCenter.x = f.mouthPosition.x
                filterCenter.y = f.mouthPosition.y
                self.mouth.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
                self.mouth.setValue(f_width/7, forKey: "inputRadius0")
                self.mouth.setValue(f_width/7 - 10, forKey: "inputRadius1")
                
                
                combineFilter.setValue(self.mouth.outputImage, forKey: "inputImage")
                combineFilter.setValue(retImage, forKey: "inputBackgroundImage")
                retImage = combineFilter.outputImage!
            }
        }
        
        return retImage
    }
    
    
    
    
    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
        
    }
    
    //MARK: Process image output
    func processImage(inputImage:CIImage) -> CIImage{
        
        // detect faces
        let f = getFaces(img: inputImage)
        
        // if no faces, just return original image
        if f.count == 0 { return inputImage }
        
        //otherwise apply the filters to the faces
        return applyFiltersToFaces(inputImage: inputImage, features: f)
    }
}

