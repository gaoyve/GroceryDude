//
//  ItemViewController.m
//  Grocery Dude
//
//  Created by Gerry on 7/20/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import "ItemViewController.h"
#import "AppDelegate.h"
#import "Item.h"
#import "LocationAtHome.h"
#import "LocationAtShop.h"
#import "Unit.h"
#import "Item_Photo.h"

@interface ItemViewController ()

@end

@implementation ItemViewController
#define debug 1

#pragma mark - INTERACTION
- (IBAction)done:(id)sender {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self hideKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)hideKeyboardWhenBackgroundIsTapped {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITapGestureRecognizer *tgr =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(hideKeyboard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}
- (void)hideKeyboard {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self.view endEditing:YES];
}
- (void)keyboardDidShow:(NSNotification *)n {
    
    // Find top of keyboard input view (i.e. picker)
    CGRect keyboardRect =
    [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    // Resize scroll view
    CGRect newScrollViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, keyboardTop);
    newScrollViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    [self.scrollView setFrame:newScrollViewFrame];
    
    // Scroll to the active Text-Field
    [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
}
- (void)keyboardWillHide:(NSNotification *)n {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CGRect defaultFrame =
    CGRectMake(self.scrollView.frame.origin.x,
               self.scrollView.frame.origin.y,
               self.view.frame.size.width,
               self.view.frame.size.height);
    
    // Reset Scrollview to the same size as the containing view
    [self.scrollView setFrame:defaultFrame];
    
    // Scroll to the top again
    [self.scrollView scrollRectToVisible:self.nameTextField.frame
                                animated:YES];
}

#pragma mark - DELEGATE: UITextField
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (textField == self.nameTextField) {
        
        if ([self.nameTextField.text isEqualToString:@"New Item"]) {
            self.nameTextField.text = @"";
        }
    }
    if (textField == _unitPickerTextField && _unitPickerTextField.picker) {
        [_unitPickerTextField fetch];
        [_unitPickerTextField.picker reloadAllComponents];
    } else if (textField == _homeLocationPickerTextField &&
               _homeLocationPickerTextField.picker) {
        [_homeLocationPickerTextField fetch];
        [_homeLocationPickerTextField.picker reloadAllComponents];
    } else if (textField == _shopLocationPickerTextField &&
               _shopLocationPickerTextField.picker) {
        [_shopLocationPickerTextField fetch];
        [_shopLocationPickerTextField.picker reloadAllComponents];
    }
    _activeField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    Item *item =
    (Item*)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
    
    if (textField == self.nameTextField) {
        if ([self.nameTextField.text isEqualToString:@""]) {
            self.nameTextField.text = @"New Item";
        }
        item.name = self.nameTextField.text;
    }
    else if (textField == self.quantityTextField) {
        item.quantity =
        [NSNumber numberWithFloat:self.quantityTextField.text.floatValue];
    }
    _activeField = nil;
}

#pragma mark - VIEW
- (void)refreshInterface {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedItemID) {
        CoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item =
        (Item*)[cdh.context existingObjectWithID:self.selectedItemID
                                           error:nil];
        self.nameTextField.text = item.name;
        self.quantityTextField.text = item.quantity.stringValue;
        self.unitPickerTextField.text = item.unit.name;
        self.unitPickerTextField.selectedObjectID = item.unit.objectID;
        self.homeLocationPickerTextField.text = item.locationAtHome.storeIn;
        self.homeLocationPickerTextField.selectedObjectID = item.locationAtHome.objectID;
        self.shopLocationPickerTextField.text = item.locationAtShop.aisle;
        self.shopLocationPickerTextField.selectedObjectID = item.locationAtShop.objectID;
        [cdh.context performBlock:^{
            self.photoImageView.image = [UIImage imageWithData:item.photo.data];
        }];
    }
}
- (void)viewDidLoad {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    [self hideKeyboardWhenBackgroundIsTapped];
    self.nameTextField.delegate = self;
    self.quantityTextField.delegate = self;
    
    self.unitPickerTextField.delegate = self;
    self.unitPickerTextField.pickerDelegate = self;
    self.homeLocationPickerTextField.delegate = self;
    self.homeLocationPickerTextField.pickerDelegate = self;
    self.shopLocationPickerTextField.delegate = self;
    self.shopLocationPickerTextField.pickerDelegate = self;
}
- (void)viewWillAppear:(BOOL)animated {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    // Register for keyboard notifications while the view is visible.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    [self ensureItemHomeLocationIsNotNull];
    [self ensureItemShopLocationIsNotNull];
    
    [self refreshInterface];
    if ([self.nameTextField.text isEqual:@"New Item"]) {
        self.nameTextField.text = @"";
        [self.nameTextField becomeFirstResponder];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self ensureItemHomeLocationIsNotNull];
    [self ensureItemShopLocationIsNotNull];
    
    CoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [cdh backgroundSaveContext];
    
    // Unregister for keyboard notifications while the view is not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    // Turn item & item photo into a fault
    NSError *error = nil;
    Item *item = (Item*)[cdh.context existingObjectWithID:self.selectedItemID error:&error];
    if (error) {
        NSLog(@"Error!!! --> %@", error.localizedDescription);
    } else {
        [cdh.context refreshObject:item.photo mergeChanges:NO];
        [cdh.context refreshObject:item mergeChanges:NO];
    }
}

#pragma mark - DATA
- (void)ensureItemHomeLocationIsNotNull {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedItemID) {
        CoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item =
        (Item*)[cdh.context existingObjectWithID:self.selectedItemID
                                           error:nil];
        if (!item.locationAtHome) {
            NSFetchRequest *request =
            [[cdh model]
             fetchRequestTemplateForName:@"UnknownLocationAtHome"];
            NSArray *fetchedObjects =
            [cdh.context executeFetchRequest:request error:nil];
            
            if ([fetchedObjects count] > 0) {
                item.locationAtHome = [fetchedObjects objectAtIndex:0];
            }
            else {
                LocationAtHome *locationAtHome =
                [NSEntityDescription
                 insertNewObjectForEntityForName:@"LocationAtHome"
                 inManagedObjectContext:cdh.context];
                NSError *error = nil;
                if (![cdh.context obtainPermanentIDsForObjects:
                      [NSArray arrayWithObject:locationAtHome] error:&error]) {
                    NSLog(@"Couldn't obtain a permanent ID for object %@",
                          error);
                }
                locationAtHome.storeIn = @"..Unknown Location..";
                item.locationAtHome = locationAtHome;
            }
        }
    }
}
- (void)ensureItemShopLocationIsNotNull {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedItemID) {
        CoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item =
        (Item*)[cdh.context existingObjectWithID:self.selectedItemID
                                           error:nil];
        if (!item.locationAtShop) {
            NSFetchRequest *request =
            [[cdh model]
             fetchRequestTemplateForName:@"UnknownLocationAtShop"];
            NSArray *fetchedObjects =
            [cdh.context executeFetchRequest:request error:nil];
            
            if ([fetchedObjects count] > 0) {
                item.locationAtShop = [fetchedObjects objectAtIndex:0];
            }
            else {
                LocationAtShop *locationAtShop =
                [NSEntityDescription
                 insertNewObjectForEntityForName:@"LocationAtShop"
                 inManagedObjectContext:cdh.context];
                NSError *error = nil;
                if (![cdh.context obtainPermanentIDsForObjects:
                      [NSArray arrayWithObject:locationAtShop] error:&error]) {
                    NSLog(@"Couldn't obtain a permanent ID for object %@",
                          error);
                }
                locationAtShop.aisle = @"..Unknown Location..";
                item.locationAtShop = locationAtShop;
            }
        }
    }
}

#pragma mark - PICKERS
- (void)selectedObjectID:(NSManagedObjectID *)objectID
      changedForPickerTF:(CoreDataPickerTF *)pickerTF {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedItemID) {
        CoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        
        Item *item =
        (Item*)[cdh.context existingObjectWithID:self.selectedItemID
                                           error:nil];;
        NSError *error;
        if (pickerTF == self.unitPickerTextField) {
            Unit *unit = (Unit*)[cdh.context existingObjectWithID:objectID
                                                            error:&error];
            item.unit = unit;
            self.unitPickerTextField.text = item.unit.name;
        }
        else if (pickerTF == self.homeLocationPickerTextField) {
            LocationAtHome *locationAtHome =
            (LocationAtHome*)[cdh.context existingObjectWithID:objectID
                                                         error:&error];
            item.locationAtHome = locationAtHome;
            self.homeLocationPickerTextField.text =
            item.locationAtHome.storeIn;
        }
        else if (pickerTF == self.shopLocationPickerTextField) {
            LocationAtShop *locationAtShop =
            (LocationAtShop*)[cdh.context existingObjectWithID:objectID
                                                         error:&error];
            item.locationAtShop = locationAtShop;
            self.shopLocationPickerTextField.text =
            item.locationAtShop.aisle;
        }
        [self refreshInterface];
        if (error) {
            NSLog(@"Error selecting object on picker: %@, %@",
                  error, error.localizedDescription);
        }
    }
}

- (void)selectedObjectClearedForPickerTF:(CoreDataPickerTF *)pickerTF {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedItemID) {
        CoreDataHelper *cdh =
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *item =
        (Item*)[cdh.context existingObjectWithID:self.selectedItemID
                                           error:nil];
        
        if (pickerTF == self.unitPickerTextField) {
            item.unit = nil;
            self.unitPickerTextField.text = @"";
        }
        else if (pickerTF == self.homeLocationPickerTextField) {
            item.locationAtHome = nil;
            self.homeLocationPickerTextField.text = @"";
        }
        else if (pickerTF == self.shopLocationPickerTextField) {
            item.locationAtShop = nil;
            self.shopLocationPickerTextField.text = @"";
        }
        [self refreshInterface];
    }
}

#pragma mark - CAMERA
- (void)checkCamera {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self.cameraButton.enabled = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)showCamera:(id)sender {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"Camera is available");
        _camera = [[UIImagePickerController alloc] init];
        _camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        _camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        _camera.allowsEditing = YES;
        _camera.delegate = self;
        [self.navigationController presentViewController:_camera animated:YES completion:nil];
    } else {
        NSLog(@"Camera not available");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    Item *item = (Item*)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
    UIImage *photo = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    
    NSLog(@"Captured %f x %f photo", photo.size.height, photo.size.width);
    
    if (!item.photo) {
        Item_Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Item_Photo"
                                                             inManagedObjectContext:cdh.context];
        [cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:newPhoto] error:nil];
        item.photo = newPhoto;
    }
    item.thumbnail = nil;
    item.photo.data = UIImageJPEGRepresentation(photo, 0.5);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end












