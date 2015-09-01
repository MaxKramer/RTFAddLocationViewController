//
//  ViewController.m
//  Example Project
//
//  Created by Max Kramer on 31/08/2015.
//  Copyright (c) 2015 Max Kramer. All rights reserved.
//

#import "ViewController.h"
#import <RTFAddLocationViewController/RTFAddLocationViewController.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    RTFAddLocationViewController *addLocation = [[RTFAddLocationViewController alloc] initWithCompletionHandler:^(CLPlacemark *location, NSError *error) {
        if (error || !location) {
            NSLog(@"There was an error: %@", error);
        }
        else {
            NSLog(@"Selected location:\n\n%@", location);
            
        }
    }];
    [self presentViewController:addLocation animated:YES completion:nil];
}

@end
