//
//  Measurement+CoreDataProperties.h
//  Grocery Dude
//
//  Created by Gerry on 7/18/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Measurement.h"

NS_ASSUME_NONNULL_BEGIN

@interface Measurement (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *abc;

@end

NS_ASSUME_NONNULL_END
