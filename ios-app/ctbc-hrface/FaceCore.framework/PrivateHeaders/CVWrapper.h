//
//  CVWrapper.h
//  FaceCore
//
//  Created by joe joe on 2019/5/30.
//  Copyright © 2019 joe joe. All rights reserved.
//

#ifndef CVWrapper_h
#define CVWrapper_h

#endif /* CVWrapper_h */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/NSString.h>
#import <CoreML/CoreML.h>

NS_ASSUME_NONNULL_BEGIN

@class ODetectInfo;
@interface ODetectInfo: NSObject{
    
}
@property (atomic, strong) NSMutableArray * _Nullable face_list;
@property (atomic, strong) UIImage * _Nullable origin_image;

@end


@class OFaceInfo;
@interface OFaceInfo: NSObject{
    
}
@property (atomic, strong) NSNumber * _Nullable x1;
@property (atomic, strong) NSNumber * _Nullable y1;
@property (atomic, strong) NSNumber * _Nullable x2;
@property (atomic, strong) NSNumber * _Nullable y2;
@property (atomic, strong) NSNumber * _Nullable area;
@property (atomic, strong) NSMutableArray * _Nullable ppoint;
@property (atomic, strong) NSMutableArray * _Nullable regreCoord;
@property (atomic, assign) bool * _Nullable exist;
@property (atomic, strong) UIImage * _Nullable croped;
@property (atomic, strong) UIImage * _Nullable alignment;
@property (atomic, strong) UIImage * _Nullable depth;
@end

@interface CVWrapper : NSObject

//+(nonnull UIImage *)detectFace: (nonnull UIImage *)rawImage;

+(nonnull ODetectInfo *)detectFace: (nonnull UIImage *)rawImage draw_face:(NSNumber *) draw_face orientation:(NSNumber *) orientation min_size:(NSNumber *) min_size;

+(nonnull ODetectInfo *)detectFaceDepth: (nonnull UIImage *)rawImage depth_image:(nonnull UIImage *)depthImage draw_face:(NSNumber *) draw_face orientation:(NSNumber *) orientation min_size:(NSNumber *) min_size;


+ (UIImage *) color2Gray:(UIImage *)inputImage alphaExist:(bool)alphaExist;

+ (UIImage *) lbp_image:(UIImage *)inputImage alphaExist:(bool)alphaExist method:(NSNumber *) method;

+(MLMultiArray *) hist_lbp: (UIImage *)inputImage alphaExist:(bool)alphaExist method: (NSNumber *) method;

+(MLMultiArray *) hist_rgb_lbp: (UIImage *)inputImage alphaExist:(bool)alphaExist  method: (NSNumber *) method;


@end

NS_ASSUME_NONNULL_END
#ifdef __cplusplus
#include "Mtcnn.hpp"
std::string getBundleFilename(const char * _Nullable Path);
void extractFaces(cv::Mat& image, std::vector<Bbox>& finalBbox);


#endif
//
