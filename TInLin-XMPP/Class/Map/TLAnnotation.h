//
//  TLAnnotation.h
//  Demo
//
//  Created by Mac on 2018/12/5.
//  Copyright © 2018 TinLin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface TLAnnotation : NSObject <MKAnnotation>

//
@property (nonatomic, assign, readonly)CLLocationCoordinate2D coordinate;

// 大头针图片
@property (nonatomic, strong, readonly)UIImage *image;

// Title and subtitle for use by selection UI.

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

- (instancetype)initWithImage:(UIImage *)image Coordinate:(CLLocationCoordinate2D)coordinate;

@end
