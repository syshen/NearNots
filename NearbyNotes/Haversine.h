//
//  Haversine.h
//  NearbyNotes
//
//  Created by Shen Steven on 4/21/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern float const HAVERSINE_RADS_PER_DEGREE;
extern float const HAVERSINE_MI_RADIUS;
extern float const HAVERSINE_KM_RADIUS;
extern float const HAVERSINE_M_PER_KM;
extern float const HAVERSINE_F_PER_MI;

@interface Haversine : NSObject

- (id) init;
- (id) initWithCoordinateSource:(CLLocationCoordinate2D)source coordinateDest:(CLLocationCoordinate2D)dest;
@property (nonatomic, assign) CLLocationCoordinate2D source;
@property (nonatomic, assign) CLLocationCoordinate2D dest;

- (float) distance;
- (float) toKilometers;
- (float) toMeters;
- (float) toMiles;
- (float) toFeet;
@end
