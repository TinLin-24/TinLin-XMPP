//
//  TLAnnotationView.h
//  Demo
//
//  Created by Mac on 2018/12/5.
//  Copyright © 2018 TinLin. All rights reserved.
//

#import <MapKit/MapKit.h>

@class TLAnnotation;

@interface TLAnnotationView : MKAnnotationView

+ (instancetype)annotationViewWithMapView:(MKMapView *)mapView;

+ (instancetype)annotationViewWithMapView:(MKMapView *)mapView annotation:(TLAnnotation*)annotation;

@end
