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
    let bridge = OpenCVBridge()
    @IBOutlet weak var heartRateLabel: UILabel!
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        self.setupFilters()
        
        self.bridge.loadHaarCascade(withFilename: "nose")
        
        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(AVCaptureDevicePosition.back)
        
        // create dictionary for face detection
        // HINT: you need to manipulate these proerties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow,CIDetectorTracking:true] as [String : Any]
        
        // setup a face detector in swift
        self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                   context: self.videoManager.getCIContext(), // perform on the GPU is possible
            options: (optsDetector as [String : AnyObject]))
        
        self.videoManager.setProcessingBlock(self.processImage)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        
    }
    
    //MARK: Process image output
    func processImage(_ inputImage:CIImage) -> CIImage{
        
        
        var retImage = inputImage
        
        //HINT: you can also send in the bounds of the face to ONLY process the face in OpenCV
        // or any bounds to only process a certain bounding region in OpenCV
        self.bridge.setTransforms(self.videoManager.transform)
        self.bridge.setImage(retImage,
                             withBounds: retImage.extent, // the first face bounds
            andContext: self.videoManager.getCIContext())
        retImage = self.bridge.getImageComposite() // get back opencv processed part of the image (overlayed on original)
        
        return retImage
    }
    
    //MARK: Setup filtering
    func setupFilters(){
        filters = []
        
        let filterPinch = CIFilter(name:"CIBumpDistortion")!
        filterPinch.setValue(-0.5, forKey: "inputScale")
        filterPinch.setValue(75, forKey: "inputRadius")
        filters.append(filterPinch)
        
    }
    
    //MARK: Calculating heart rate
    func calculateHeartRate() {
        var heartRate: Int
        var redValues = [Int]()
        let frameRate = 441
        var avgPeakIndexDifference = 0
        var meanOfChosenData = 0
        
        //recording average red values
        for _ in 0..<1000 {
            self.videoManager.setProcessingBlock(self.processImage)
            redValues.append(self.bridge.getAvgPixelIntensityRed())
        }
        
        //to take out the values when the image is just white/yellow
        for index in 0..<30 {
            redValues.remove(at: index)
        }
        
        var peakIndices = [Int]()
        //finding the peaks in the data
        for index in 0..<redValues.endIndex {
            if isPeak(data: redValues, peakCandidate: index, maxRange: 20) {
                peakIndices.append(index)
            }
        }
        
        var distances = [Int]()
        //finding distances between the peaks
        for index in 0..<(peakIndices.endIndex - 1) {
            let peakDistance = peakIndices[index + 1] - peakIndices[index]
            distances.append(peakDistance)
            avgPeakIndexDifference += peakDistance
        }
        
        avgPeakIndexDifference = avgPeakIndexDifference / peakIndices.endIndex
        
        //removing the indices of values that prob aren't real peaks
        for index in 0..<peakIndices.endIndex - 1{
            if distances[index] < avgPeakIndexDifference {
                peakIndices.remove(at: index)
            }
        }
        
        //getting mean of our chosen data
        for index in 0..<peakIndices.endIndex {
            meanOfChosenData += redValues[peakIndices[index]]
        }
        meanOfChosenData = meanOfChosenData / peakIndices.endIndex
        
        heartRate = 60 * frameRate / meanOfChosenData
        heartRateLabel.text = String(heartRate)
    }
    
    //tests if this index is a peak
    func isPeak(data: [Int], peakCandidate: Int, maxRange: Int) -> Bool {
        var peak = peakCandidate
        var startIndex: Int
        var endIndex: Int
        
        if peakCandidate < maxRange {
            startIndex = 0
        } else {
            startIndex = peakCandidate - maxRange
        }
        
        if peakCandidate + maxRange < data.endIndex - 1 {
            endIndex = peakCandidate + maxRange
        } else {
            endIndex = data.endIndex - 1
        }
        
        for index in startIndex...endIndex {
            if data[index] > data[peak] {
                peak = index
            }
        }
        
        if peak == peakCandidate {
            return true
        }
        
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !self.videoManager.isRunning{
            self.videoManager.start()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(self.videoManager.isRunning){
            self.videoManager.turnOffFlash()
            self.videoManager.stop()
            self.videoManager.shutdown()
        }
    }
    
    @IBAction func toggleFlash(_ sender: AnyObject) {
        if self.videoManager.toggleFlash() {
            calculateHeartRate()
        }
    }
    
    
}
