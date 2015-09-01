//
//  RTFAnnotation.h
//  Forecastr
//
//  Created by Max Kramer on 03/07/2015.
//  Copyright (c) 2015 Max Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;
@import MapKit;

@interface RTFAnnotation : NSObject <MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, copy) NSString *title, *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
