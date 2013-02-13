//
//  FontListViewController.h
//  Purikura
//
//  Created by Roanne Mendoza on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "EditorViewController.h"

@interface FontListViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>{
    id<FontModalDelegate> delegate;
    UITableView* fontList;
    NSMutableArray* fontBook;
    NSMutableString* selectedFont;
}

- (IBAction)navActions:(id)sender;

@end
