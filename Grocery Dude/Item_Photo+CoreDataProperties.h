//
//  Item_Photo+CoreDataProperties.h
//  Grocery Dude
//
//  Created by Gerry on 7/22/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item_Photo.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item_Photo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) Item *item;

@end

NS_ASSUME_NONNULL_END
