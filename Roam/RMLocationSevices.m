//
//  RMLocationSevices.m
//  Roam
//
//  Created by Vishal on 24/10/14.
//  Copyright (c) 2014 Vishal. All rights reserved.
//

#import "RMLocationSevices.h"


@implementation RMLocationSevices

@synthesize locationManager;
@synthesize RMLDelegate;
@synthesize geocoder;

#pragma mark - Singleton implementation in ARC

+ (id)sharedLocationServices {
    static RMLocationSevices *locationSevices = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationSevices = [[self alloc] init];
    });
    return locationSevices;
}

- (id) init {
    self = [super init];
    if (self != nil)
    {
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
        }
        [self.locationManager setPurpose:@"CLLocationManager..."];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 50;
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        
        if ([CLLocationManager locationServicesEnabled]) {
            [self.locationManager startUpdatingLocation];
        }
        
        //[self.locationManager startMonitoringSignificantLocationChanges];

        if (!self.geocoder){
            self.geocoder = [[CLGeocoder alloc] init];
        }
        updateEvents = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}




- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSDate *newLocationDate = [newLocation timestamp];
    NSTimeInterval recentLocatedTime = [newLocationDate timeIntervalSinceNow];
    
    if (newLocation != oldLocation && abs(recentLocatedTime) >= 15 && newLocation.horizontalAccuracy >= 35 ) {
        
        loctionDetails_array =[[NSMutableArray alloc] init];
        
        [self.geocoder reverseGeocodeLocation: locationManager.location completionHandler:
         ^(NSArray *placemarks, NSError *error) {
             if(!error){
                 if ([placemarks count] > 0){
                     CLPlacemark *placemark = [placemarks objectAtIndex:0];
                     NSString *locatedaddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                     if (![locatedaddress length] == 0) {
                         [loctionDetails_array addObject:placemark.addressDictionary];
                         [self.RMLDelegate locationUpdate:newLocation withlocation:loctionDetails_array];
                     }
                 }
             }
             else
             {
                 NSLog(@"\n\n Unable to PlaceMark (*reverseGeocodeLocation*)\n\n //There was a reverse geocoding error\n%@",[error localizedDescription]);
             }
         }];
    }
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error{
    [self.RMLDelegate locationError:error];
}


#pragma mark - Forward GeoLocationService

- (NSString*)getCordinatesfromAddress:(NSString*)address
{
    if (!self.geocoder) {
        self.geocoder  = [[CLGeocoder alloc] init];
    }
    [self.geocoder geocodeAddressString:address
                      completionHandler:^(NSArray* placemarks, NSError* error)
     {
         if ([placemarks count] > 0)
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             CLLocation *location = placemark.location;
             CLLocationCoordinate2D coordinate = location.coordinate;
             
             lat_longti = [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude];
             
             if ([placemark.areasOfInterest count] > 0)
             {
                 NSString *areaOfInterest = [placemark.areasOfInterest objectAtIndex:0];
             }
         }
         if ([lat_longti length] !=0)
         {
             [self addRegion:lat_longti];
         }
     }];
    
    return lat_longti;
}


#pragma mark - Region Monitoring Serives

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    NSString *event = [NSString stringWithFormat:@"didEnterRegion %@ at %@", region.identifier, [NSDate date]];
    [self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    NSString *event = [NSString stringWithFormat:@"didExitRegion %@ at %@", region.identifier, [NSDate date]];
    [self updateWithEvent:event];
}


- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error
{
    NSString *event = [NSString stringWithFormat:@"monitoringDidFailForRegion %@: %@", region.identifier, error];
    [self updateWithEvent:event];
}

- (void)addRegion:(NSString*)latiLog
{
    NSArray* array_longlati = [latiLog componentsSeparatedByString: @","];
    NSString *latitude  = [array_longlati objectAtIndex: 0];
    NSString *logitude = [array_longlati objectAtIndex:1];
    if ([CLLocationManager regionMonitoringAvailable] == TRUE) {
        // Create a new region based on the center of the map view.+37.55570213,-122.37937577
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([latitude floatValue], [logitude floatValue]);
        CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:coord
                                                                      radius:200.0
                                                                  identifier:[NSString stringWithFormat:@"%f, %f", [latitude floatValue],[logitude floatValue]]];
        // Start monitoring the newly created region.
        //[locationManager startMonitoringForRegion:newRegion desiredAccuracy:kCLLocationAccuracyBest];
        [locationManager startMonitoringForRegion:newRegion];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kVDidEnterRegionNotification" object:self];
    }
    else
    {
        NSLog(@"Region monitoring is not available.");
    }
}


- (void)updateWithEvent:(NSString *)event
{
    [updateEvents insertObject:event atIndex:0];
}
- (void)locationUpdate:(CLLocation *)location {
}

- (void)locationError:(NSError *)error {
}

- (void)locationUpdate:(CLLocation *)location withlocation:(NSMutableArray*)locationArray
{
    NSLog(@"arrayVishalkumar %@\n\n\n\n\n %@",locationArray,location);
}




@end
