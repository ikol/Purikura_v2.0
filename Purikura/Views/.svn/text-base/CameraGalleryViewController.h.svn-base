//
//  CameraGalleryViewController.h
//  Purikura
//
//  Created by roanne mendoza on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface CameraGalleryViewController : BaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate> {
    BOOL firstLoad;
    BOOL isEditingMode;
    
    CLLocationManager* manager;
    
    NSMutableDictionary* locationInfo;
    
    NSMutableArray* savedPhotos;
    NSMutableArray* toDelete;
    
    UIBarButtonItem* cancelBtn;
    UIBarButtonItem* trashBtn;
    
    IBOutlet UIScrollView* scrollGallery;
    IBOutlet UIToolbar* toolbar;
    IBOutlet UIBarButtonItem* editBtn;
}

- (IBAction)barBtnAction:(id)sender;
- (void)initializeCamera;
- (void)setupView;


@end
