//
//  Item+CoreDataProperties.h
//  Grocery Dude
//
//  Created by Gerry on 7/22/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item.h"
#import "LocationAtHome.h"
#import "LocationAtShop.h"
#import "Unit.h"
#import "Item_Photo.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *colletced;
@property (nullable, nonatomic, retain) NSNumber *listed;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *quantity;
@property (nullable, nonatomic, retain) NSData *thumbnail;
@property (nullable, nonatomic, retain) LocationAtHome *locationAtHome;
@property (nullable, nonatomic, retain) LocationAtShop *locationAtShop;
@property (nullable, nonatomic, retain) Unit *unit;
@property (nullable, nonatomic, retain) Item_Photo *photo;

@end

NS_ASSUME_NONNULL_END
