//
//  ItemViewController.h
//  Grocery Dude
//
//  Created by Gerry on 7/20/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "UnitPickerTF.h"
#import "LocationAtHomePickerTF.h"
#import "LocationAtShopPickerTF.h"

@interface ItemViewController : UIViewController
<UITextFieldDelegate, CoreDataPickerTFDelegate>
@property (strong, nonatomic) NSManagedObjectID *selectedItemID;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *quantityTextField;
@property (strong, nonatomic) IBOutlet UnitPickerTF *unitPickerTextField;
@property (strong, nonatomic) IBOutlet LocationAtHomePickerTF *homeLocationPickerTextField;
@property (strong, nonatomic) IBOutlet LocationAtShopPickerTF *shopLocationPickerTextField;
@property (strong, nonatomic) IBOutlet UITextField *activeField;

@end
