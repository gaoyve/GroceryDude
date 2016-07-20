//
//  CoreDataPickerTF.h
//  Grocery Dude
//
//  Created by Gerry on 7/20/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@class CoreDataPickerTF;

@protocol  CoreDataPickerTFDelegate<NSObject>

- (void)selectedObjectID:(NSManagedObjectID*)objectID
      changedForPickerTF:(CoreDataPickerTF*)pickerTF;
@optional
- (void)selectedObjectClearedForPickerTF:(CoreDataPickerTF*)pickerTF;

@end

@interface CoreDataPickerTF : UITextField <UIKeyInput, UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, weak) id <CoreDataPickerTFDelegate> pickerDelegate;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic) BOOL showToolbar;
@property (nonatomic, strong) NSManagedObjectID *selectedObjectID;

@end
