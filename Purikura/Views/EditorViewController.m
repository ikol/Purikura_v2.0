//
//  EditorViewController.m
//  Purikura
//
//  Created by roanne mendoza on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditorViewController.h"
#import <QuartzCore/CALayer.h>
#import "FontListViewController.h"


#define PANELHEIGHT             49
#define TOOLBARHEIGHT           44
#define TEXTFIELDHEIGHT         31

@implementation EditorViewController

- (id)initWithImage:(UIImage*)image metaData:(NSDictionary *)metaData{
    self = [super init];
    if (self) {
        originalImage = [image copy];
        isHidden = NO;
        mediaData = [[NSDictionary alloc] initWithDictionary:metaData];

        isEdit = NO;
        
        //reset transform struct
        initialTransform.a = 0;
        initialTransform.b = 0;
        initialTransform.c = 0;
        initialTransform.d = 0;
        initialTransform.tx = 0;
        initialTransform.ty = 0;
        
        currentLabel = nil;
        selectedView = nil;
        
        selectedFont = [[NSMutableString alloc] initWithString:@""];
        selectedSize = 12;
    }
    
    return self;
}

- (void)dealloc {
    selectedView = nil;
    currentLabel = nil;
    
    [mediaData release];
    [originalImage release];
    
    [selectedFont release];
    [selectedColor release];
    
    for (UIGestureRecognizer* gr in [colorPalette gestureRecognizers]) {
        [colorPalette removeGestureRecognizer:gr];
    } 
    [colorPalette release];
    
    for (UIGestureRecognizer* gr in [sizePalette gestureRecognizers]) {
        [sizePalette removeGestureRecognizer:gr];
    }
    [sizePalette release];
    
    for (UIGestureRecognizer* gr in [textPalette gestureRecognizers]) {
        [textPalette removeGestureRecognizer:gr];
    }
    [textPalette release];
    
    for (UIGestureRecognizer* gr in [logoPalette gestureRecognizers]) {
        [logoPalette removeGestureRecognizer:gr];
    }
    [logoPalette release];
    
    [textInput release];
    
    [picture release];
    [toolbar release];
    [sidePanel release];
    
    [super dealloc];
}

- (void)viewDidLoad {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        maxWidth = 1024;
        maxHeight = 768;
    } else {
        maxWidth = 480;
        maxHeight = 320;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabbar" object:nil];
    
    //add tap recognizer
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleToolbar:)];
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addText:)];
    [doubleTap setNumberOfTapsRequired:2];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [picture addGestureRecognizer:singleTap];
    [picture addGestureRecognizer:doubleTap];    
    
    [singleTap release];
    [doubleTap release];
    
    [textInput setFrame:CGRectMake(textInput.frame.origin.x, textInput.frame.origin.y, textInput.frame.size.width, 0)];
    
    [self setupViews];
    [super viewDidLoad];
}

- (void)setupViews {
    [picture setImage:originalImage];
    
    UITapGestureRecognizer* recognizer;
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateColor:)];
    [colorPalette addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateFont:)];
    [textPalette addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateSize:)];
    [sizePalette addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImage:)];
    [logoPalette addGestureRecognizer:recognizer];
    [recognizer release];

    //insert timestamp
    if ([mediaData count] > 0) {
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)] autorelease];
        [label setText:[[mediaData objectForKey:@"{TIFF}"] objectForKey:@"DateTime"]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [label sizeToFit];
        [label setFrame:CGRectOffset(label.frame, screenFrame.size.height - label.frame.size.width, 0)];
        
        [picture addSubview:label];
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0, label.frame.size.height + label.frame.origin.y, 10, 10)] autorelease];
        [label setText:[mediaData objectForKey:@"latitude"]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [label sizeToFit];
        [label setFrame:CGRectOffset(label.frame, screenFrame.size.height - label.frame.size.width, 0)];
        
        [picture addSubview:label];
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0, label.frame.size.height + label.frame.origin.y, 10, 10)] autorelease];
        [label setText:[mediaData objectForKey:@"longitude"]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [label sizeToFit];
        [label setFrame:CGRectOffset(label.frame, screenFrame.size.height - label.frame.size.width, 0)];
        
        [picture addSubview:label];
    }
}


#pragma mark - IBActions
- (IBAction)buttonActions:(id)sender {
    [colorPalette removeFromSuperview];
    [textPalette removeFromSuperview];
    [sizePalette removeFromSuperview];
    [logoPalette removeFromSuperview];
    [sidePanel setContentOffset:CGPointZero];
    switch ([sender tag]) {
        case 1:
        {
            [sidePanel addSubview:colorPalette];
            [sidePanel setContentSize:colorPalette.frame.size];
        }
            break;
        case 2:
        {
            [sidePanel addSubview:textPalette];
            [sidePanel setContentSize:textPalette.frame.size];
//            FontListViewController* fontViewer = [[[FontListViewController alloc] init] autorelease];
//            [self presentModalViewController:fontViewer animated:YES];
        }
            break;
        case 3:
        {
            [sidePanel addSubview:sizePalette];
            [sidePanel setContentSize:sizePalette.frame.size];
        }
            break;
        case 4:
        {
            [sidePanel addSubview:logoPalette];
            [sidePanel setContentSize:logoPalette.frame.size];
        }
            break;
        case 5:
        {
            [selectedView removeFromSuperview];
            selectedView = nil;
            [[[toolbar items] objectAtIndex:5] setEnabled:NO];
        }            
            break;
        case 6:
            if (currentLabel || selectedView) {
                promptWithButtons(@"discard_changes", @"ok", @"cancel", self);
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        case 7:
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[mediaData objectForKey:@"filename"]];
            UIGraphicsBeginImageContext(picture.frame.size);
            [picture.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *editedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [UIImagePNGRepresentation(editedImage) writeToFile:imagePath atomically:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }
        default:
            break;
    }
}


#pragma mark - Textfield delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currentLabel = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:0.3 animations:^{
        [textInput setFrame:CGRectMake(textInput.frame.origin.x, textInput.frame.origin.y, textInput.frame.size.width, 0)];
    }];
    
    if (!isEmpty([textField text])) {
        if (isEdit) {
            //TO DO
            [currentLabel removeFromSuperview];
            [currentLabel setText:[textField text]];
            [picture addSubview:currentLabel];
        } else {
            UILabel* label = [[[UILabel alloc] init] autorelease];
            [label setTextAlignment:UITextAlignmentCenter];
            [label setText:[textField text]];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont fontWithName:selectedFont size:selectedSize]];
            [label setTextColor:selectedColor];
            [label sizeToFit];
            [label setCenter:currentTextPoint];
            [label setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectText:)];
            [tapGesture setNumberOfTapsRequired:1];
            [tapGesture setDelegate:self];
            [label addGestureRecognizer:tapGesture];
            
            UITapGestureRecognizer* twoTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editText:)];
            [twoTapGesture setNumberOfTapsRequired:2];
            [twoTapGesture setDelegate:self];
            [label addGestureRecognizer:twoTapGesture];
            
            UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
            [panGesture setMinimumNumberOfTouches:1];
            [panGesture setMaximumNumberOfTouches:1];
            [panGesture setDelegate:self];
            [label addGestureRecognizer:panGesture];
            
            UIRotationGestureRecognizer* rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateElement:)];
            [label addGestureRecognizer:rotateGesture];
            
            [picture addSubview:label];
            
            currentLabel = label;
            selectedView = label;
            [[[toolbar items] objectAtIndex:5] setEnabled:YES];
            
            [tapGesture release];
            [panGesture release];
            [twoTapGesture release];
            [rotateGesture release];
        }
    }
    
    currentTextPoint = CGPointZero;
    isEdit = NO;
}


#pragma mark - Editing functions
- (void)updateColor:(UITapGestureRecognizer*)sender {
    CGPoint tapped = [sender locationInView:colorPalette];
    UIView* tappedView = [colorPalette hitTest:tapped withEvent:nil];
    if (tappedView != colorPalette) {
        selectedColor = tappedView.backgroundColor;
        if (currentLabel) {
            [currentLabel setTextColor:selectedColor];
        }
    }
}

- (void)updateFont:(UITapGestureRecognizer*)sender {
    CGPoint tapped = [sender locationInView:textPalette];
    UIView* tappedView = [textPalette hitTest:tapped withEvent:nil];
    if (tappedView != textPalette) {
        [selectedFont setString:((UILabel*)tappedView).font.fontName];
        if (currentLabel) {
            [currentLabel setFont:[UIFont fontWithName:selectedFont size:selectedSize]];
            CGPoint center = currentLabel.center;
            [currentLabel sizeToFit];
            [currentLabel setCenter:center];
        }
    }
}

/* Delegate function if modal is implemented for font selection
 *
 - (void)updateFont:(NSString*)font {
    [selectedFont setString:font];
    if (currentLabel) {
        CGPoint center = currentLabel.center;
        [currentLabel setFont:[UIFont fontWithName:font size:selectedSize]];
        [currentLabel sizeToFit];
        [currentLabel setCenter:center];
    }
}*/

- (void)updateSize:(UITapGestureRecognizer*)sender {
    CGPoint tapped = [sender locationInView:sizePalette];
    UIView* tappedView = [sizePalette hitTest:tapped withEvent:nil];
    if (tappedView != sizePalette) {
        selectedSize = (int)((UILabel*)tappedView).font.pointSize;
        if (currentLabel) {
            [currentLabel setFont:[UIFont fontWithName:selectedFont size:selectedSize]];
            CGPoint center = currentLabel.center;
            [currentLabel sizeToFit];
            [currentLabel setCenter:center];
        }
    }
}

- (void)addImage:(UITapGestureRecognizer*)sender {
    CGPoint tapped = [sender locationInView:logoPalette];
    UIView* tappedView = [logoPalette hitTest:tapped withEvent:nil];
    NSLog(@"%@", tappedView);
    if (tappedView != logoPalette) {
        NSLog(@"not palette");
        UIImageView* logo = [[[UIImageView alloc] initWithImage:[((UIImageView*)tappedView) image]] autorelease];
        
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
        UIPinchGestureRecognizer* pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(resizeImage:)];
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage:)];
        UIRotationGestureRecognizer* rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateElement:)];
        
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        [panGesture setDelegate:self];
        
        [pinchGesture setDelegate:self];
        [tapGesture setDelegate:self];
        [rotateGesture setDelegate:self];
        
        
        [logo addGestureRecognizer:panGesture];
        [logo addGestureRecognizer:pinchGesture];
        [logo addGestureRecognizer:tapGesture];
        [logo addGestureRecognizer:rotateGesture];
        
        [logo setUserInteractionEnabled:YES];
        [logo setCenter:picture.superview.center];
        
        [picture addSubview:logo];
        
        selectedView = logo;
        [[[toolbar items] objectAtIndex:5] setEnabled:YES];
        
        [panGesture release];
        [pinchGesture release];
        [tapGesture release];
        [rotateGesture release];
    }
}

#pragma mark - Gesture recognizer delegate
- (void)toggleToolbar:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (isHidden) {
        [UIView animateWithDuration:0.3 animations:^{
            [sidePanel setFrame:CGRectOffset([sidePanel frame], 0, (PANELHEIGHT+TOOLBARHEIGHT)*(-1))];
            [toolbar setFrame:CGRectOffset([toolbar frame], 0, TOOLBARHEIGHT*(-1))];
        }];
        isHidden = NO;
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            [sidePanel setFrame:CGRectOffset([sidePanel frame], 0, PANELHEIGHT+TOOLBARHEIGHT)];
            [toolbar setFrame:CGRectOffset([toolbar frame], 0, TOOLBARHEIGHT)];
        }];
        isHidden = YES;
    }
}

//TEXT-RELATED GESTURES
- (void)addText:(UITapGestureRecognizer *)tapGestureRecognizer {
    
    currentTextPoint = [tapGestureRecognizer locationInView:picture];
    [textInput setText:@""];
    
    [UIView animateWithDuration:0.3 animations:^{
        [textInput setFrame:CGRectMake(textInput.frame.origin.x, textInput.frame.origin.y, textInput.frame.size.width, TEXTFIELDHEIGHT)];
//        [textInput setFrame:CGRectOffset(textInput.frame, 0, TEXTFIELDHEIGHT)];
    }];
    
    [textInput becomeFirstResponder];
    
}

- (void)selectText:(UIGestureRecognizer*)sender {
    [picture bringSubviewToFront:currentLabel];
    selectedView = [sender view];
    currentLabel = (UILabel*)[sender view];
    
    [[[toolbar items] objectAtIndex:5] setEnabled:YES];
}

- (void)editText:(UIGestureRecognizer*)sender {
    currentLabel = (UILabel*)[sender view];
    [textInput setText:[currentLabel text]];
    [UIView animateWithDuration:0.3 animations:^{
        [textInput setFrame:CGRectMake(textInput.frame.origin.x, textInput.frame.origin.y, textInput.frame.size.width, TEXTFIELDHEIGHT)];
    }];
    [textInput becomeFirstResponder];
    isEdit = YES;
}

//IMAGE-RELATED GESTURES
- (void)resizeImage:(UIGestureRecognizer*)sender {
    UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)sender;
    UIImageView* image = (UIImageView*)[pinch view];

    if (initialTransform.a == 0) {
        initialTransform = [image transform];
    }
    
    CGAffineTransform newTransform = CGAffineTransformScale(initialTransform,[pinch scale], [pinch scale]);
    image.transform = newTransform;
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        //reset transform struct
        initialTransform.a = 0;
        initialTransform.b = 0;
        initialTransform.c = 0;
        initialTransform.d = 0;
        initialTransform.tx = 0;
        initialTransform.ty = 0;
    }
}

- (void)selectImage:(UIGestureRecognizer*)sender {
    
    [picture bringSubviewToFront:[sender view]];
    
    selectedView = [sender view];
    [[[toolbar items] objectAtIndex:5] setEnabled:YES];
}

//GENERAL GESTURES
- (void)dragging:(UIPanGestureRecognizer*)recognizer {
    UIView* element = [recognizer view];
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint delta = [recognizer translationInView:[element superview]];
        CGPoint center = [element center];
        center.x += delta.x;
        center.y += delta.y;
        if (center.x > maxWidth) {
            center.x = maxWidth;
        } else if (center.x < 0) {
            center.x = 0;
        }
        
        if (center.y > maxHeight) {
            center.y = maxHeight;
        } else if (center.y < 0) {
            center.y =  0;
        }
        
        [element setCenter:center];
        [recognizer setTranslation:CGPointZero inView:[element superview]];
    }
}

- (void)rotateElement:(UIGestureRecognizer*)sender {
    UIView* viewToRotate = [sender view];
    UIRotationGestureRecognizer* gesture = (UIRotationGestureRecognizer*)sender;
    if (initialTransform.a == 0) {
        initialTransform = [viewToRotate transform];
    }
    CGAffineTransform newTransform = CGAffineTransformRotate(initialTransform, gesture.rotation);
    [viewToRotate setTransform:newTransform];
    if (sender.state == UIGestureRecognizerStateEnded) {
        //reset transform struct
        initialTransform.a = 0;
        initialTransform.b = 0;
        initialTransform.c = 0;
        initialTransform.d = 0;
        initialTransform.tx = 0;
        initialTransform.ty = 0;
    }
}


#pragma mark - Alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Scrollview delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return picture;
}


@end
