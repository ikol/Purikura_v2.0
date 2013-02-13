//
//  PurikuraAppDelegate.h
//  Purikura
//
//  Created by roanne mendoza on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraGalleryViewController.h"

@interface PurikuraAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UIView* loader;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController* cameraGallery;

@end
