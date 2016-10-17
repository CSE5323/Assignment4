//
//  OpenCVBridgeSub.m
//  ImageLab
//
//  Created by Eric Larson on 10/4/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "OpenCVBridgeSub.h"

#import "AVFoundation/AVFoundation.h"


using namespace cv;

@interface OpenCVBridgeSub()
@property (nonatomic) cv::Mat image;
@end

@implementation OpenCVBridgeSub
@dynamic image;

-(void)processImage{
    
    cv::Mat frame_gray,image_copy;
    
    // fine, adding scoping to case statements to get rid of jump errors
    char text[50];
    Scalar avgPixelIntensity;
    cv::Mat image = self.image;
    
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    avgPixelIntensity = cv::mean( image_copy );
    sprintf(text,"Avg. R: %.0f, G: %.0f, B: %.0f", avgPixelIntensity.val[2],avgPixelIntensity.val[1],avgPixelIntensity.val[0]);
    cv::putText(image, text, cv::Point(80, 40), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    
    self.image = image;
}

-(NSInteger)getAvgPixelIntensityRed{
    cv::Mat frame_gray,image_copy;
    
    // fine, adding scoping to case statements to get rid of jump errors
    char text[50];
    Scalar avgPixelIntensity;
    cv::Mat image = self.image;
    
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    avgPixelIntensity = cv::mean( image_copy );
    sprintf(text,"Avg. R: %.0f, G: %.0f, B: %.0f", avgPixelIntensity.val[2],avgPixelIntensity.val[1],avgPixelIntensity.val[0]);
    cv::putText(image, text, cv::Point(80, 40), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    NSInteger red = avgPixelIntensity.val[2];
    
    self.image = image;
    
    return red;
}
    
@end
