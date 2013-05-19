//
//  Haversine.m
//  NearbyNotes
//
//  Created by Shen Steven on 4/21/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "Haversine.h"

float const HAVERSINE_RADS_PER_DEGREE = 0.0174532925199433;
float const HAVERSINE_MI_RADIUS = 3956.0;
float const HAVERSINE_KM_RADIUS = 6371.0;
float const HAVERSINE_M_PER_KM = 1000.0;
float const HAVERSINE_F_PER_MI = 5282.0;

@implementation Haversine

- (id) init {
  return [self initWithCoordinateSource:CLLocationCoordinate2DMake(0, 0) coordinateDest:CLLocationCoordinate2DMake(0, 0)];
}

- (id) initWithCoordinateSource:(CLLocationCoordinate2D)source coordinateDest:(CLLocationCoordinate2D)dest {
  self = [super init];
  if (self) {
    self.source = source;
    self.dest = dest;
  }
  return self;
}

- (float) distance {
  float lat1Rad = self.source.latitude * HAVERSINE_RADS_PER_DEGREE;
  float lat2Rad = self.dest.latitude * HAVERSINE_RADS_PER_DEGREE;
  float dLonRad = ((self.dest.longitude - self.source.longitude) * HAVERSINE_RADS_PER_DEGREE);
  float dLatRad = ((self.dest.latitude - self.source.latitude) * HAVERSINE_RADS_PER_DEGREE);
  float a = pow(sin(dLatRad / 2), 2) + cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLonRad / 2), 2);
  return (2 * atan2(sqrt(a), sqrt(1 - a)));
}

- (float) toKilometers {
  return [self distance] * HAVERSINE_KM_RADIUS;
}

- (float) toMeters {
  return [self toKilometers] * HAVERSINE_M_PER_KM;
}

- (float) toMiles {
  return [self distance] * HAVERSINE_MI_RADIUS;
}

- (float) toFeet {
  return [self toMiles] * HAVERSINE_F_PER_MI;
}
@end
