//
//  ViewController.m
//  定位
//
//  Created by admin on 2017/9/20.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>
@property(nonatomic,strong)CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startLocation];
}
-(void)startLocation
{
    //判断用户是否打开了定位功能
    if([CLLocationManager locationServicesEnabled]){
        if(!_locationManager){
            _locationManager=[[CLLocationManager alloc]init];
            //设置代理
            [self.locationManager setDelegate:self];
            //设置定位精确度，精确度越高，越耗电
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
            //设置多远距离定位一次
            [self.locationManager setDistanceFilter:100];
            //开始获取授权，打开定位
            [self.locationManager requestWhenInUseAuthorization];
            //开始定位
            [self.locationManager startUpdatingLocation];
        }else{
            [self.locationManager startUpdatingLocation];
        }
    }else{
        NSLog(@"%d",666);
    }
}

#pragma mark -CLLocationManagerDelegate
//代理方法监听定位服务状态的变化
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
                [_locationManager requestAlwaysAuthorization];
                NSLog(@"用户还未决定授权");
            }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
                [_locationManager requestAlwaysAuthorization];
                NSLog(@"定位服务授权状态被允许在使用应用程序的时候");
            }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"访问受限");
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
            if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
                [_locationManager requestAlwaysAuthorization];
                NSLog(@"定位服务授权状态已经被用户允许在任何状态下获取位置信息。包括监测区域、访问区域、或者在有显著的位置变化的时候");
            }
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"被拒绝了");
            break;
        default:
            break;
    }
}
//代理方法返回locationd 信息
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"%@",locations);
    CLLocation *currLocation=locations.lastObject;
    NSTimeInterval locatinAge=-[currLocation.timestamp timeIntervalSinceNow];
    NSLog(@"%f----%f",[currLocation.timestamp timeIntervalSince1970],locatinAge);
    //关闭定位
    [self.locationManager stopUpdatingLocation];
    CLLocation *location=locations.lastObject;
    [self reverseGeocoder:location];
}
//地理反编码
-(void)reverseGeocoder:(CLLocation *)currentLocation{
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(error || placemarks.count==0){
            NSLog(@"反编码失败");
        }else{
            CLPlacemark *placemark=placemarks.firstObject;
            NSLog(@"placemark:%@",[placemark addressDictionary]);
            NSString *city=[[placemark addressDictionary]objectForKey:@"City"];
            NSLog(@"%@",city);
        }
    }];
}

@end
