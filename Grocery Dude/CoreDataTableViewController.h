//
//  CoreDataTableViewController.h
//  Grocery Dude
//
//  Created by Gerry on 7/19/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface CoreDataTableViewController : UITableViewController

<NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *frc;
- (void)performFetch;

@end
