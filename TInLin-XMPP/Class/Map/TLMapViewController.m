//
//  TLMapViewController.m
//  TinLin-XMPP
//
//  Created by Mac on 2018/12/26.
//  Copyright © 2018 xinchenglong. All rights reserved.
//

#import "TLMapViewController.h"
#import <MapKit/MapKit.h>

#import "TLAnnotation.h"
#import "TLAnnotationView.h"

@interface TLMapViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>

//
@property (nonatomic, strong)MKMapView *mapView;
//
@property (nonatomic, strong)CLLocationManager *locationManger;

@end

@implementation TLMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)configure {
    [super configure];
    
    [self _setup];
    [self _setupSubViews];
}

- (void)_setup {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManger requestWhenInUseAuthorization];
    }
//    // 每隔多少距离使用位置更新数据
//    self.locationManger.distanceFilter = 50;
//    // 定位的精度
//    self.locationManger.desiredAccuracy = kCLLocationAccuracyBest;
//    // 代理属性
//    self.locationManger.delegate = self;
//
//    [self.locationManger startUpdatingLocation];
    
    if (self.location) {
        //1 设置显示区域 121.318489,31.302382  ;0.1是初始的比例（跨度）
//        MKCoordinateRegion region = MKCoordinateRegionMake(self.location.coordinate, MKCoordinateSpanMake(0.1, 0.1));
        //2 通过距离来设置 地图的显示区域
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, 150, 150);
        //添加到地图上
        [self.mapView setRegion:[self.mapView regionThatFits:region]];
        
        TLAnnotation *annotation = [[TLAnnotation alloc] initWithImage:TLImageNamed(@"icon_location")
                                                            Coordinate:self.location.coordinate];
        [self.mapView addAnnotation:annotation];
    }
}

- (void)_setupSubViews {
    [self.view addSubview:self.mapView];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error:%@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count) {
        CLLocation *location = [locations firstObject];
        
        //1 设置显示区域 121.318489,31.302382  ;0.1是初始的比例（跨度）
        MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.1, 0.1));
        //2 通过距离来设置 地图的显示区域
        //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 10, 10);
        //添加到地图上
        [self.mapView setRegion:[self.mapView regionThatFits:region]];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(nonnull NSArray<MKAnnotationView *> *)views{
    //添加标注时调用的方法
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(nonnull MKAnnotationView *)view{
    //标注被选中时 执行的方法
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    //标注失去焦点时执行的方法
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView{
    //地图将要载入
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    //地图载入完成以后执行的方法
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error{
    //地图载入失败的时候的执行的方法
    NSLog(@"error:%@",[error description]);
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    //地图显示区域将要发生变化是执行的方法
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    //地图显示区域 发生变化 执行的方法
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[TLAnnotation class]]) {
        return [TLAnnotationView annotationViewWithMapView:mapView annotation:annotation];
    }
    
    // 重用ID
    static NSString *annotationId = @"annotationId";
    
    // 从重用队列中获取
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
    if (nil == annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
    }
    // 设置属性
    annotationView.canShowCallout = YES;
    
    // 弹出详情左侧视图
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, 50.f, 50.f);
    imageView.image = TLImageNamed(@"icon_location");
    annotationView.leftCalloutAccessoryView = imageView;
    
    // 弹出详情右侧视图
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = btn;
    
    // leftCalloutAccessoryView rightCalloutAccessoryView
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    /// 点击大头针, 在弹出的视图左右显示视图(如果是UIControl的子类的话, 点击调用的方法要实现代理方法
    NSLog(@"%s", __func__);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    userLocation.title = @"TinLin";
    //    self.mapView.centerCoordinate = userLocation.coordinate;
    //    [self.mapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.1, 0.1)) animated:NO];
    // 如果在ViewDidLoad中调用  添加大头针的话会没有掉落效果  定位结束后再添加大头针才会有掉落效果
    // loadData是添加大头针方法
    //[self loadData];
}

#pragma mark - Getter

- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.mapType = MKMapTypeStandard;
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        _mapView.zoomEnabled = YES;
        //_mapView.showsScale = YES;
        _mapView.delegate = self;
        /// 可以设置调用频率的
//        _mapView.distanceFilter = kCLLocationAccuracyNearestTenMeters;
//        _mapView.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
    }
    return _mapView;
}

- (CLLocationManager *)locationManger {
    if (!_locationManger) {
        _locationManger = [[CLLocationManager alloc] init];
    }
    return _locationManger;
}

@end
