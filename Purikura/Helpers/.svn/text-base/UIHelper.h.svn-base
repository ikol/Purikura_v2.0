//
//  UIHelper.h
//  Purikura
//
//  Created by roanne mendoza on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kGalleryMaxColumns          6
#define kTagButtonOffset            10

#import <tgmath.h>

static BOOL isEmpty(NSString *string) {
    
    if (string == nil) {
        return YES;
    } else {
        return [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] compare:@""] == NSOrderedSame;
    }
}

static BOOL isEqual(NSString *string1, NSString *string2, BOOL strict) {
    
    BOOL empty1 = isEmpty(string1);
    BOOL empty2 = isEmpty(string2);
    
    if (empty1 && empty2) {
        return YES;
        
    } else if (empty1 || empty2) {
        return NO;
        
    } else {
        
        if (strict && ([string1 compare:string2] == NSOrderedSame)) {
            return YES;
        } else if (!strict && [string1 caseInsensitiveCompare:string2] == NSOrderedSame) {
            return YES;
        }
        
        return NO;
    }
}

static UIView* gallerySelection(NSArray* imageList, SEL action, id target, CGRect frame) {
    UIView* gallery = [[[UIView alloc] initWithFrame:frame] autorelease];
    [gallery setBackgroundColor:[UIColor clearColor]];
    
    
    int maxColumns = frame.size.height > 480.0 ? 9 : 4;
    float spacing = (frame.size.height-(maxColumns*100)) / (maxColumns+1);

    int row = 0;
	int column = 0;
	for(int i = 0; i < [imageList count]; ++i) {
        UIImageView* thumbnail = [[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[imageList objectAtIndex:i]]] autorelease];
        [thumbnail setContentMode:UIViewContentModeScaleAspectFit];
		UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(spacing+column*(100+spacing), row*(100+spacing)+spacing, 100, 100);
        
        [thumbnail setFrame:frame];
		[button setFrame:frame];
        [button setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateSelected];
        [button setAlpha:0.75];
		[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		button.tag = i; 
        
        [gallery addSubview:thumbnail];
		[gallery addSubview:button];
        
		if (column == maxColumns-1) {
			column = 0;
			row++;
		} else {
			column++;
		}        

	}
    
    [gallery setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, (row+1) * (100+spacing) + spacing)];
    
    return gallery;

}

static void clearGalleryButtons(UIView* view) {
    for (UIView* subview in view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [((UIButton*)subview) setSelected:NO];
        }
    }
}

static BOOL deletePhotos(NSArray* photoIdx, NSMutableArray* photoList, UIView* view) {
    for (NSString* index in photoIdx) {
        [[NSFileManager defaultManager] removeItemAtPath:[photoList objectAtIndex:[index intValue]] error:nil];
        [photoList removeObjectAtIndex:[index intValue]];
    }
    
    clearGalleryButtons(view);
    
    return YES;
}

static UITableViewCell* fontCell(NSString* identifier) {
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
    cell.backgroundColor = [UIColor orangeColor];
    [cell.textLabel setText:@"abc&ABC123!"];
    
    return cell;
}

#pragma mark - Alert views
static void alertHandler(NSString *message, BOOL prompt, NSString *buttonLabel1, NSString *buttonLabel2, id target) {
    
    if (isEmpty(message)) {
        return;
    }
    
    if (isEmpty(buttonLabel1)) {
        buttonLabel1 = @"alert_ok";
    }
    if (isEmpty(buttonLabel2)) {
        buttonLabel2 = @"alert_cancel";
    }
    
    UIAlertView *alert = nil;
    
    if (prompt) {
        alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(message, nil) delegate:target cancelButtonTitle:NSLocalizedString(buttonLabel1, nil) otherButtonTitles:NSLocalizedString(buttonLabel2, nil), nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(message, nil) delegate:target cancelButtonTitle:NSLocalizedString(buttonLabel1, nil) otherButtonTitles:nil];
    } 
    
    [alert show];
    [alert release];
}

static void alert(NSString *message) {
    alertHandler(message, NO, nil, nil, nil);
}

static void alertWithTarget(NSString *message, NSString *buttonLabel, id target) {
    alertHandler(message, NO, buttonLabel, nil, target);
}

static void promptWithButtons(NSString *message, NSString *buttonLabel1, NSString *buttonLabel2, id target) {
    alertHandler(message, YES, buttonLabel1, buttonLabel2, target);
}


