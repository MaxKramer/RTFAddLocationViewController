//
//  RTFAddLocationViewController.h
//  Forecastr
//
//  Created by Max Kramer on 03/07/2015.
//  Copyright (c) 2015 Max Kramer. All rights reserved.
//

@import UIKit;
@import MapKit;
@import CoreLocation;

@import GoogleMaps;

typedef void (^RTFAddLocationCompletionBlock)(CLPlacemark *location, NSError *error);
typedef NSString *(RTFAddLocationTitleBlock)(GMSPlace *place);

@interface RTFAddLocationViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithCompletionHandler:(RTFAddLocationCompletionBlock)completion;

- (void)dismiss;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) RTFAddLocationCompletionBlock completionHandler;

@property (nonatomic, copy) NSString *currentLocationPinTitle;
@property (nonatomic, copy) NSString *selectedLocationPinTitle;
@end
