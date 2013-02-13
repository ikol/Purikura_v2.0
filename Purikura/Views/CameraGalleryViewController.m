//
//  CameraGalleryViewController.m
//  Purikura
//
//  Created by roanne mendoza on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraGalleryViewController.h"
#import "EditorViewController.h"

@implementation CameraGalleryViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        locationInfo = [[NSMutableDictionary alloc] init];
        savedPhotos = [[NSMutableArray alloc] init];
        toDelete = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [manager setDelegate:nil];
    [manager release];
    
    [savedPhotos release];
    [toDelete release];
    
    [locationInfo release];
    
    [scrollGallery release];
    [toolbar release];
    [editBtn release];
    
    [cancelBtn release];
    [trashBtn release];
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    firstLoad = YES;
    cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(barBtnAction:)];
    [cancelBtn setTag:2];
    trashBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(barBtnAction:)];
    [trashBtn setTag:4];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupView];
    
    if (firstLoad) {
        firstLoad = NO;
        [self initializeCamera];
    }
}

#pragma mark - View functions
- (void)initializeCamera {
    if (!manager) {
        manager = [[CLLocationManager alloc] init];
        [manager setDesiredAccuracy:kCLLocationAccuracyBest];
        [manager setDelegate:self];
        [manager setDistanceFilter:kCLDistanceFilterNone];
    }

    [manager startUpdatingLocation];
    
    UIImagePickerController *camera = [[UIImagePickerController alloc] init];
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.delegate = self;
    
    [self presentModalViewController:camera animated:YES];
}

- (void) setupView {
    [self.view setUserInteractionEnabled:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyShowLoader" object:nil];
    
    [savedPhotos removeAllObjects];
    NSError* error;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    for (NSString* imagePath in [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
        [savedPhotos addObject:[NSString stringWithFormat:@"%@/%@", documentsDirectory, imagePath]];
    }
    
    UIView* tempView = gallerySelection(savedPhotos, @selector(showFullscreen:), self, [[UIScreen mainScreen] bounds]);
//    [[scrollGallery.subviews lastObject] removeFromSuperview];
    for (UIView* subview in [scrollGallery subviews]) {
        if (![subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    [scrollGallery addSubview:tempView];
    [scrollGallery setContentSize:tempView.frame.size];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyHideLoader" object:nil];
    [self.view setUserInteractionEnabled:YES];
}


#pragma mark - Image picker delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [manager stopUpdatingLocation];
    
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSLog(@"width %f height %f", image.size.width, image.size.height);
    NSMutableDictionary* mediaData = [NSMutableDictionary dictionaryWithDictionary:[info objectForKey:@"UIImagePickerControllerMediaMetadata"]];
    [mediaData setObject:[NSString stringWithFormat:@"%@.png", [[mediaData objectForKey:@"{TIFF}"] objectForKey:@"DateTime"]] forKey:@"filename"];
    
    if ([locationInfo count]) {
        [mediaData setObject:[locationInfo objectForKey:@"latitude"] forKey:@"latitude"];
        [mediaData setObject:[locationInfo objectForKey:@"longitude"] forKey:@"longitude"];
    }
    
    EditorViewController* editor = [[[EditorViewController alloc] initWithImage:image metaData:mediaData] autorelease];
    [self.navigationController pushViewController:editor animated:NO];
    
	[self dismissModalViewControllerAnimated:YES];
    [picker release];
    
}


#pragma mark - Location services
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [locationInfo setObject:[NSString stringWithFormat:@"%f", newLocation.coordinate.latitude] forKey:@"latitude"];
    [locationInfo setObject:[NSString stringWithFormat:@"%f", newLocation.coordinate.longitude] forKey:@"longitude"];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

}


#pragma mark - Actions
- (IBAction)barBtnAction:(id)sender {
    switch ([sender tag]) {
        case 1:
            [self initializeCamera];
            break;
        case 2:
            //enable camera, hide cancel button, change trash button to edit
            //unselect all btns
            [toDelete removeAllObjects];
            clearGalleryButtons([scrollGallery.subviews lastObject]);
            NSMutableArray* toolbaritems = [[toolbar items] mutableCopy];
            [toolbaritems removeObject:cancelBtn];
            [toolbaritems removeObject:trashBtn];
            [toolbaritems addObject:editBtn];
            [[toolbaritems objectAtIndex:0] setEnabled:YES];
            [toolbar setItems:toolbaritems];
            isEditingMode = NO;
            break;
        case 3:
            //go to editing mode
            [toDelete removeAllObjects];
            toolbaritems = [[toolbar items] mutableCopy];
            [toolbaritems removeObject:editBtn];
            [toolbaritems addObject:cancelBtn];
            [toolbaritems addObject:trashBtn];
            [[toolbaritems objectAtIndex:0] setEnabled:NO];
            [toolbar setItems:toolbaritems];
            isEditingMode = YES;
            //disable camera button, change current button to trash, show cancel button
            break;
        case 4:
            //delete action
            deletePhotos(toDelete, savedPhotos, [scrollGallery.subviews lastObject]);
            toolbaritems = [[toolbar items] mutableCopy];
            [toolbaritems removeObject:cancelBtn];
            [toolbaritems removeObject:trashBtn];
            [toolbaritems addObject:editBtn];
            [[toolbaritems objectAtIndex:0] setEnabled:YES];
            [toolbar setItems:toolbaritems];
            isEditingMode = NO;
            [self setupView];
            break;
        default:
            break;
    }
    
}

- (void)showFullscreen:(id)sender {
    if (isEditingMode) {
        UIButton* btn = (UIButton*)sender;
        [btn setSelected:![btn isSelected]];
        if ([btn isSelected]) {
            [toDelete addObject:[NSString stringWithFormat:@"%d", [sender tag]]];
        } else {
            [toDelete removeObject:[NSString stringWithFormat:@"%d", [sender tag]]];
        }
    }  else {
        EditorViewController* editor = [[EditorViewController alloc] initWithImage:[UIImage imageWithContentsOfFile:[savedPhotos objectAtIndex:[sender tag]]] metaData:[NSDictionary dictionaryWithObject:[[savedPhotos objectAtIndex:[sender tag]] lastPathComponent] forKey:@"filename"]];
        [self.navigationController pushViewController:editor animated:YES];
    }
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated {
    [manager stopUpdatingLocation];
    
    [super dismissModalViewControllerAnimated:animated];
}


@end
