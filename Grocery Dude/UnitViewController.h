//
//  UnitViewController.h
//  Grocery Dude
//
//  Created by Gerry on 7/20/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface UnitViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) NSManagedObjectID *selectedObjectID;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@end
