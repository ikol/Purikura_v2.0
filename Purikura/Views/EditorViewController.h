//
//  EditorViewController.h
//  Purikura
//
//  Created by roanne mendoza on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"

@protocol FontModalDelegate <NSObject>

-(void)updateFont:(NSString*)font;

@end

@interface EditorViewController : BaseViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UIScrollViewDelegate>{
    BOOL isHidden;
    BOOL isEdit;
    
    CGPoint currentTextPoint;
    
    CGAffineTransform initialTransform;

    CGFloat firstY;
    CGFloat firstX;
    
    NSInteger maxWidth;
    NSInteger maxHeight;
    
    NSDictionary* mediaData;

    UILabel* currentLabel;
    UIImage* originalImage;
    UIView* selectedView;
    
    UIColor* selectedColor;
    NSMutableString* selectedFont;
    NSInteger selectedSize;
    
    IBOutlet UIImageView* picture;
    IBOutlet UIToolbar* toolbar;
    IBOutlet UIScrollView* sidePanel;
    IBOutlet UITextField* textInput;
    
    IBOutlet UIView* colorPalette;
    IBOutlet UIView* textPalette;
    IBOutlet UIView* sizePalette;
    IBOutlet UIView* logoPalette;
}

- (id)initWithImage:(UIImage*)image metaData:(NSDictionary*)metaData;
- (void)setupViews;

- (IBAction)buttonActions:(id)sender;


@end
