//
//  RMLocationSevices.h
//  Roam
//
//  Created by Vishal on 24/10/14.
//  Copyright (c) 2014 Vishal. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol RMLocationSevicesDelegate

@required

- (void)locationUpdate:(CLLocation *)location withlocation:(NSMutableArray*)locationArray;
- (void)locationError:(NSError *)error;

@end


@interface RMLocationSevices : NSObject<CLLocationManagerDelegate>
{
    NSMutableArray *loctionDetails_array;
    NSMutableArray *updateEvents;
    NSString *lat_longti;
    
    __unsafe_unretained NSObject <RMLocationSevicesDelegate> *locationDelegate;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) id RMLDelegate;
@property (nonatomic, strong) CLGeocoder *geocoder;


+ (id)sharedLocationServices;

- (NSString*)getCordinatesfromAddress:(NSString*)address;

- (void)addRegion:(NSString*)latiLog;



@end
