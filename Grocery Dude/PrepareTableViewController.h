//
//  PrepareTableViewController.h
//  Grocery Dude
//
//  Created by Gerry on 7/19/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface PrepareTableViewController : CoreDataTableViewController <UIActionSheetDelegate>
@property (strong, nonatomic) UIActionSheet *clearConfirmActionSheet;

@end
