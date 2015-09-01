//
//  RTFAnnotation.m
//  Forecastr
//
//  Created by Max Kramer on 03/07/2015.
//  Copyright (c) 2015 Max Kramer. All rights reserved.
//

#import "RTFAnnotation.h"

@implementation RTFAnnotation

#pragma mark - Initialiser override

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        [self setCoordinate:coordinate];
    }
    return self;
}

@end
