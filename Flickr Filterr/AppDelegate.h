//
//  FFAppDelegate.h
//  Flickr Filterr
//
//  Created by William Wu on 12/1/13.
//  Copyright (c) 2013 William Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"
#import "DetailViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;

@property (strong, nonatomic) SearchViewController * mainViewController;
@property (strong, nonatomic) DetailViewController * filterViewController;

@end
