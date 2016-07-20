//
//  UnitPickerTF.m
//  Grocery Dude
//
//  Created by Gerry on 7/20/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import "UnitPickerTF.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "Unit.h"

@implementation UnitPickerTF
#define debug 1

- (void)fetch {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper *cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request =
    [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],nil];
    [request setFetchBatchSize:50];
    NSError *error = nil;
    self.pickerData = [cdh.context executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Error pupolating picker: %@, %@", error, error.localizedDescription);
    }
    [self selectDefaultRow];
}

- (void)selectDefaultRow {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedObjectID && [self.pickerData count] > 0) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Unit *selectedObject = (Unit*)[cdh.context existingObjectWithID:self.selectedObjectID
                                                                  error:nil];
        [self.pickerData enumerateObjectsUsingBlock:^(
         Unit *unit, NSUInteger idx, BOOL *stop) {
            if ([unit.name compare:selectedObject.name] == NSOrderedSame) {
                [self.picker selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate selectedObjectID:self.selectedObjectID changedForPickerTF:self];
                *stop = YES;
            }
        }];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Unit *unit = [self.pickerData objectAtIndex:row];
    return unit.name;
}
@end
