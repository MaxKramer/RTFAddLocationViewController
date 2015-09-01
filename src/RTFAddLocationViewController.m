//
//  RTFAddLocationViewController.m
//  Forecastr
//
//  Created by Max Kramer on 03/07/2015.
//  Copyright (c) 2015 Max Kramer. All rights reserved.
//

#import "RTFAddLocationViewController.h"
#import "RTFAnnotation.h"
#import "RTFLocation.h"

static NSString *const RTFReuseIdentifier = @"AddLocationReuseIdentifier";

@interface RTFAddLocationViewController ()

@property (nonatomic, strong) GMSPlacesClient *placesClient;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSMutableArray *autocompletionResults;
@property (nonatomic, strong) CLGeocoder *geocoder;
@end
 
@implementation RTFAddLocationViewController

#pragma mark - Custom Initialiser

- (instancetype)initWithCompletionHandler:(RTFAddLocationCompletionBlock)completion {
    self = [super init];
    self.completionHandler = completion;
    [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self commonInit];
    return self;
}

#pragma mark - Common Init

- (void)commonInit {
    self.selectedLocationPinTitle = NSLocalizedString(@"Selected Location", nil);
    self.currentLocationPinTitle = NSLocalizedString(@"Current Location", nil);
}

#pragma mark - Dismiss VC

- (void)dismiss {
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (self.tabBarController) {
        [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - ViewDidLoad

- (void)viewDidLoad {
    self.placesClient = [[GMSPlacesClient alloc] init];
    self.autocompletionResults = [NSMutableArray array];
    
    [self.mapView setShowsUserLocation:YES];
    [super viewDidLoad];
}

- (UITableView *)searchTableView {
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.searchBar.frame)) style:UITableViewStylePlain];
        [_searchTableView setDelegate:self];
        [_searchTableView setDataSource:self];
        [_searchTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:RTFReuseIdentifier];
        [_searchTableView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
    }
    return _searchTableView;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

#pragma mark - ViewDidDisappear

- (void)viewWillDisappear:(BOOL)animated {
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
    if (self.geocoder.isGeocoding) {
        [self.geocoder cancelGeocode];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [UIView animateWithDuration:0.2f animations:^{
        [self.mapView setAlpha:0.5f];
        [searchBar setShowsCancelButton:YES];
        [self showTableView];
    }];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self queryAutocompletionWithQuery:searchText];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self endSearchBarEditing:searchBar];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self endSearchBarEditing:searchBar];
}

- (void)endSearchBarEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self hideTableView];
    [UIView animateWithDuration:0.2f animations:^{
        [self.mapView setAlpha:1.0f];
        [searchBar setShowsCancelButton:NO animated:NO];
    }];
}

#pragma mark - Show and hide the table view

- (void)showTableView {
    [self.searchTableView setAlpha:0.0f];
    [self.view addSubview:self.searchTableView];
    [UIView animateWithDuration:0.2f animations:^{
        [self.searchTableView setAlpha:1.0f];
    }];
}

- (void)hideTableView {
    [self.searchTableView setAlpha:1.0f];
    [UIView animateWithDuration:0.4f animations:^{
        [self.searchTableView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.searchTableView removeFromSuperview];
    }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.autocompletionResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RTFReuseIdentifier forIndexPath:indexPath];
    
    GMSAutocompletePrediction *result = self.autocompletionResults[indexPath.row];
    [cell.textLabel setAttributedText:result.attributedFullText];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self endSearchBarEditing:self.searchBar];
    
    GMSAutocompletePrediction *result = self.autocompletionResults[indexPath.row];
    [self.placesClient lookUpPlaceID:result.placeID callback:^(GMSPlace *place, NSError *error) {
        if (place != nil) {
            [self.mapView removeAnnotations:[self.mapView annotations]];

            [self addAndZoomToCoordinate:place.coordinate withTitle:place.name ?: self.selectedLocationPinTitle  subtitle:place.formattedAddress];
            
            [self geocodeCoordinate:place.coordinate withCompletion:^(CLPlacemark *placemark, NSError *error) {
                if (self.completionHandler) {
                    self.completionHandler(placemark, error);
                }
            }];
        }
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)geocodeCoordinate:(CLLocationCoordinate2D)coord withCompletion:(void (^) (CLPlacemark *placemark, NSError *error))completion {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (completion) {
            completion(placemarks[0], error);
        }
    }];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation && CLLocationCoordinate2DIsValid(userLocation.coordinate)) {
        if (mapView.showsUserLocation) {
            [mapView setShowsUserLocation:NO];
        }
        
        [self addAndZoomToCoordinate:userLocation.coordinate withTitle:self.currentLocationPinTitle subtitle:nil];
            
        [self geocodeCoordinate:userLocation.coordinate withCompletion:^(CLPlacemark *placemark, NSError *error) {
            if (self.completionHandler) {
                self.completionHandler(placemark, error);
            }
        }];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MapViewAnnotation"];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapViewAnnotation"];
    }
    [annotationView setAnimatesDrop:YES];
    [annotationView setCanShowCallout:YES];
    [annotationView setDraggable:YES];
    [annotationView setPinColor:MKPinAnnotationColorPurple];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKPinAnnotationView *annotationView = views[0];
    [mapView selectAnnotation:annotationView.annotation animated:YES];
}

#pragma mark - MapView Zooming

- (void)addAndZoomToCoordinate:(CLLocationCoordinate2D)coord withTitle:(NSString *)title subtitle:(NSString *)subtitle {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 15000, 15000);
    [self.mapView setRegion:region animated:YES];
    
    RTFAnnotation *annotation = [[RTFAnnotation alloc] initWithCoordinate:coord];
    [annotation setTitle:title];
    [annotation setSubtitle:subtitle];
    [self.mapView addAnnotation:annotation];
}

#pragma mark - Perform the autocompletion query

- (void)queryAutocompletionWithQuery:(NSString *)query {
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    [filter setType:kGMSPlacesAutocompleteTypeFilterGeocode];
    
    [self.placesClient autocompleteQuery:query bounds:nil filter:filter callback:^(NSArray *results, NSError *error) {
        if (error != nil) {
            NSLog(@"Autocompletion error %@", [error localizedDescription]);
            return;
        }
        [self.autocompletionResults removeAllObjects];
        [self.autocompletionResults addObjectsFromArray:results];
        [self.searchTableView reloadData];
    }];
}

@end
