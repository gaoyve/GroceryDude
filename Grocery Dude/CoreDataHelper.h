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

@interface CoreDataHelper : NSObject <UIAlertViewDelegate, NSXMLParserDelegate>

@property (nonatomic, readonly) NSManagedObjectContext        *context;
@property (nonatomic, readonly) NSManagedObjectModel          *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator  *coordinator;
@property (nonatomic, readonly) NSPersistentStore             *store;
@property (nonatomic, retain)   MigrationViewController       *migrationViewController;
@property (nonatomic, retain)   UIAlertView                   *importAlertView;
@property (nonatomic, strong)   NSXMLParser                   *parser;
@property (nonatomic, readonly) NSManagedObjectContext        *importContext;
@property (nonatomic, readonly) NSManagedObjectContext        *sourceContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator  *sourceCoordinator;
@property (nonatomic, readonly) NSPersistentStore             *sourceStore;
@property (nonatomic, strong)   NSTimer                       *importTimer;

- (void)setupCoreData;
- (void)saveContext;
@end
