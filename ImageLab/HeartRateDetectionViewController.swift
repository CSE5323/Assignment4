//
//  HeartRateDetectionViewController.swift
//  ImageLab
//
//  Created by Jenn Le on 10/15/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

class HeartRateDetectionViewController: UIViewController{
    
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
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        
        //processing block to return the raw image
        self.videoManager.setProcessingBlock(){(inputImage:CIImage)->(CIImage) in
            //analyze the image for the amount of red in it
            
            return inputImage
        }
        
    }
    
    //These two overrides ensure there is only one video manager running at a time in our application
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func toggle_camera(_ sender: AnyObject) {
        videoManager.toggleCameraPosition()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(self.videoManager.isRunning){
            self.videoManager.turnOffFlash()
            self.videoManager.stop()
            self.videoManager.shutdown()
        }
    }
    
    @IBAction func toggleFlash(_ sender: AnyObject) {
        self.videoManager.toggleFlash()
    }
    
    //MARK: Calculating Heart Rate and Displaying it
    
    
    
}
