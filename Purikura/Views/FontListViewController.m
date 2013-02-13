//
//  FontListViewController.m
//  Purikura
//
//  Created by Roanne Mendoza on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FontListViewController.h"
#import "UIHelper.h"

@implementation FontListViewController

- (id)init {
    self = [super init];
    if (self) {
        fontBook = [[NSMutableArray alloc] init];
        
        NSArray* fontFamily = [[[NSArray alloc] initWithArray:[UIFont familyNames]] autorelease];
        
        for (NSString* family in fontFamily) {
            NSDictionary* fontGroup = [NSDictionary dictionaryWithObjectsAndKeys:family, @"font_family", [UIFont fontNamesForFamilyName:family], @"font_names", nil];
            [fontBook addObject:fontGroup];
        }

    }
    return self;
}

- (void)dealloc {
    
    [fontBook release];
    [fontList release];
    
    selectedFont = nil;
    delegate = nil;
    
    [super dealloc];
}

- (IBAction)navActions:(id)sender {
    if ([sender tag] == 2) {
        [delegate updateFont:selectedFont];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate functions
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [fontBook count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[fontBook objectAtIndex:section] objectForKey:@"font_names"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[fontBook objectAtIndex:section] objectForKey:@"font_family"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString* currentFont = [[[fontBook objectAtIndex:[indexPath section]] objectForKey:@"font_names"] objectAtIndex:[indexPath row]];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"font"];
    
    if (!cell) {
        cell = fontCell(@"font");
    }
    
    if (isEqual(currentFont, selectedFont, NO)) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:currentFont size:20]];
    [cell.detailTextLabel setText:currentFont];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [selectedFont setString:[[[fontBook objectAtIndex:[indexPath section]] objectForKey:@"font_names"] objectAtIndex:[indexPath row]]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
    
}



@end
