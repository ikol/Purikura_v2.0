//
//  PurikuraAppDelegate.m
//  Purikura
//
//  Created by roanne mendoza on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PurikuraAppDelegate.h"

@implementation PurikuraAppDelegate

@synthesize window;
@synthesize cameraGallery;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotifyShowLoader" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotifyHideLoader" object:nil];
    
    [cameraGallery release];
    [loader release];
    
    [window release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self.window setRootViewController:cameraGallery];
    
    [self.window makeKeyAndVisible];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoader) name:@"NotifyShowLoader" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoader) name:@"NotifyHideLoader" object:nil];
    
    return YES;
}

- (void)showLoader {
//    NSLog(@"show loader");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [window setUserInteractionEnabled:NO];
    [loader setHidden:NO];
    
    [window bringSubviewToFront:loader];
}

- (void)hideLoader {
//    NSLog(@"hide loader");
    [self performSelector:@selector(enableTouch) withObject:nil afterDelay:0.6];
}

- (void)enableTouch {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [window setUserInteractionEnabled:YES];
    [loader setHidden:YES];
}

@end
