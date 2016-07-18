//
//  CoreDataHelper.h
//  Grocery Dude
//
//  Created by Gerry on 7/18/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MigrationViewController.h"

@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext        *context;
@property (nonatomic, readonly) NSManagedObjectModel          *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator  *coordinator;
@property (nonatomic, readonly) NSPersistentStore             *store;
@property (nonatomic, retain)   MigrationViewController       *migrationVC;

- (void)setupCoreData;
- (void)saveContext;
@end
