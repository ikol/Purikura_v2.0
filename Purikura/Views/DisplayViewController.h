//
//  DisplayViewController.h
//  Purikura
//
//  Created by roanne mendoza on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import "ImageScrollView.h"

@interface DisplayViewController : BaseViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    NSInteger currentIndex;
    NSArray* imageList;
    NSMutableSet* recycledPages;
    NSMutableSet* visiblePages;
    
    UIScrollView* pagingScrollView;
    UIToolbar* toolbar;
    
    BOOL firstDraw;
}

- (id)initWithImageList:(NSArray*)list index:(NSInteger)index;
- (ImageScrollView*)dequeueRecycledPage;
- (void)tilePages;

@end
