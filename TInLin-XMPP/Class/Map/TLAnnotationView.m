//
//  TLAnnotationView.m
//  Demo
//
//  Created by Mac on 2018/12/5.
//  Copyright © 2018 TinLin. All rights reserved.
//

#import "TLAnnotationView.h"
#import "TLAnnotation.h"

@implementation TLAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        //设置自己的属性
        //如果是自定义大头针，标题的显示需要手动设置
        self.canShowCallout = YES;
        //添加自己的控件
        self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];//设置辅助视图
    }
    return self;
}

+ (instancetype)annotationViewWithMapView:(MKMapView *)mapView{
    static NSString *identifier = @"TLAnnotationView";
    TLAnnotationView *tmp = (TLAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (tmp == nil) {
        tmp = [[TLAnnotationView alloc]initWithAnnotation:nil reuseIdentifier:identifier];
    }
    return tmp;
}

+(instancetype)annotationViewWithMapView:(MKMapView *)mapView annotation:(TLAnnotation *)annotation{
    TLAnnotationView *tmp = [self annotationViewWithMapView:mapView];
    tmp.annotation = annotation;
    return tmp;
}

- (void)setAnnotation:(TLAnnotation*)annotation{
    [super setAnnotation:annotation];
    // 处理自己的特性
    self.image = annotation.image;
}

@end
