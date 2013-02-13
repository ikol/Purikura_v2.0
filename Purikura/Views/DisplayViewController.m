//
//  DisplayViewController.m
//  Purikura
//
//  Created by roanne mendoza on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DisplayViewController.h"
#import "EditorViewController.h"

#define PADDING  10

@implementation DisplayViewController

- (id)initWithImageList:(NSArray*)list index:(NSInteger)index {
    self = [super init];
    if (self) {
        currentIndex = index;
        imageList = [[NSArray alloc] initWithArray:list];
        firstDraw = YES;
    }
    
    return self;
}

- (void)dealloc {
    pagingScrollView = nil;
    [pagingScrollView release];
    [imageList release];
    [recycledPages release];
    [visiblePages release];
    
    [super dealloc];
}

- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabbar" object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    //add edit toolbar
    CGRect mainscreen = [[UIScreen mainScreen] bounds];
    toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, mainscreen.size.height, 44)] autorelease];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar setItems:[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editImage)] autorelease], [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(goBack)] autorelease], nil]];
    
    [self.view addSubview:toolbar];
    [self.view bringSubviewToFront:toolbar];
    [toolbar setHidden:YES];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self tilePages];
}

- (void)loadView {
    CGRect pagingFrame = [[UIScreen mainScreen] bounds];
//    pagingFrame.size.width -= 20;
    
    UIView* view = [[UIView alloc] initWithFrame:pagingFrame];
    self.view = view;
    
    pagingFrame = [[UIScreen mainScreen] bounds];
    int temp = pagingFrame.size.width;
    pagingFrame.size.width = pagingFrame.size.height;
    pagingFrame.size.height = temp + 20;
//    pagingFrame.origin.x -= 10;

    pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingFrame];
    [pagingScrollView setPagingEnabled:YES];
    [pagingScrollView setBackgroundColor:[UIColor blackColor]];
    pagingScrollView.showsVerticalScrollIndicator = NO;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
    [pagingScrollView setContentSize:CGSizeMake(pagingFrame.size.width * [imageList count], pagingFrame.size.height)];

    pagingScrollView.delegate = self;
    [self.view addSubview:pagingScrollView];
    
    recycledPages = [[NSMutableSet alloc] init];
    visiblePages = [[NSMutableSet alloc] init];
    
    [self tilePages];
}

- (ImageScrollView *)dequeueRecycledPage {
    ImageScrollView *page = [recycledPages anyObject];
    if (page) {
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (ImageScrollView *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (UIImage*)imageAtIndex:(NSUInteger)index {
    return [UIImage imageWithContentsOfFile:[imageList objectAtIndex:index]];
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect bounds = pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index
{
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
    
    // Use tiled images
    [page displayImage:[self imageAtIndex:index]];
//    [page displayTiledImageNamed:[self imageNameAtIndex:index]
//                            size:[self imageSizeAtIndex:index]];

}

- (void)tilePages {
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
//    if (firstDraw) {
//        firstNeededPageIndex = currentIndex;
//        firstDraw = NO;
//    } else {
        firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
//    }
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [imageList count] - 1);
    
    // Recycle no-longer-visible pages 
    for (ImageScrollView *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            ImageScrollView *page = [self dequeueRecycledPage];
            if (page == nil) {
                UITapGestureRecognizer* tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTabbar:)];
                [tapped setNumberOfTapsRequired:1];
                page = [[[ImageScrollView alloc] init] autorelease];
                [page addGestureRecognizer:tapped];
            }
            [self configurePage:page forIndex:index];
            [pagingScrollView addSubview:page];
            [visiblePages addObject:page];
        }
    }    
    
    currentIndex = firstNeededPageIndex;
}
                  
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self tilePages];
}

- (void)showTabbar:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:![toolbar isHidden] withAnimation:UIStatusBarAnimationFade];
    [toolbar setHidden:![toolbar isHidden]];
}

-(void)editImage {
    EditorViewController* editor = [[EditorViewController alloc] initWithImage:[UIImage imageWithContentsOfFile:[imageList objectAtIndex:currentIndex]] metaData:[NSDictionary dictionaryWithObject:[[imageList objectAtIndex:currentIndex] lastPathComponent] forKey:@"filename"]];
    [self.navigationController pushViewController:editor animated:YES];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showTabbar" object:nil];
}

@end
