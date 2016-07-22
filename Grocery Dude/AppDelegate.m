//
//  AppDelegate.m
//  Grocery Dude
//
//  Created by Tim Roadley on 18/09/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import "AppDelegate.h"
#import "Item.h"
//#import "Measurement.h"
//#import "Amount.h"
#import "Unit.h"
#import "LocationAtHome.h"
#import "LocationAtShop.h"

@implementation AppDelegate

#define debug 1

- (void)showUnitAndItemCount {
    // List how many items there are in the database
    NSFetchRequest *items = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSError *itemsError = nil;
    NSArray *fetchedItems = [[[self cdh] context] executeFetchRequest:items error:&itemsError];
    if (!fetchedItems) {
        NSLog(@"%@", itemsError);
    } else {
        NSLog(@"Found %lu item(s) ", (unsigned long)[fetchedItems count]);
    }
    
    // List how many units there are in the database
    NSFetchRequest *units = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSError *unitsError = nil;
    NSArray *fetchedUnits = [[[self cdh] context] executeFetchRequest:units error:&unitsError];
    if (!fetchedUnits) {
        NSLog(@"%@", unitsError);
    } else {
        NSLog(@"Found %lu unit(s)", (unsigned long)[fetchedUnits count]);
    }
}

- (void)demo {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
//
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
////    NSFetchRequest *request = [[[_coreDataHelper model] fetchRequestTemplateForName:@"Test"] copy];
//    
////    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
////    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
//    
////    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name != %@", @"Coffee"];
////    [request setPredicate:filter];
//    
//    NSArray *fetchedObjects = [_coreDataHelper.context executeFetchRequest:request error:nil];
//    
//    for (Item *item in fetchedObjects) {
//        NSLog(@"Fetched Object = %@ ", item.name);
//        NSLog(@"Deleting Object '%@'", item.name);
//        [_coreDataHelper.context deleteObject:item];
//    }
//    for (int i = 0; i < 5000; i++) {
//        Measurement *newMeasurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:_coreDataHelper.context];
//        
//        newMeasurement.abc = [NSString stringWithFormat:@"-->> LOTS OF TEST DATA x%i", i];
//        NSLog(@"Inserted %@",newMeasurement.abc);
//    }
//    [_coreDataHelper saveContext];
    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
//    [request setFetchLimit:50];
//    NSError *error = nil;
//    NSArray *fetchedObjects = [_coreDataHelper.context executeFetchRequest:request error:&error];
//    
//    if (error) NSLog(@"%@", error);
//    else {
//        for (Unit *unit in fetchedObjects) {
//            NSLog(@"Fetched Object = %@", unit.name);
//        }
//    }
//    Unit *kg = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:[[self cdh] context]];
//    Item *oranges = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:[[self cdh] context]];
//    Item *bananas = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:[[self cdh] context]];
//    
//    kg.name          = @"Kg";
//    oranges.name     = @"Oranges";
//    bananas.name     = @"Bananas";
//    oranges.quantity = [NSNumber numberWithInteger:1];
//    bananas.quantity = [NSNumber numberWithInteger:4];
//    oranges.listed   = [NSNumber numberWithBool:YES];
//    bananas.listed   = [NSNumber numberWithBool:YES];
//    oranges.unit     = kg;
//    bananas.unit     = kg;
//    
//    NSLog(@"Inserted %@%@ %@", oranges.quantity, oranges.unit.name, oranges.name);
//    NSLog(@"Inserted %@%@ %@", bananas.quantity, bananas.unit.name, bananas.name);
//    
//    [[self cdh] saveContext];
//    NSLog(@"Before deletion of the unit entity:");
//    [self showUnitAndItemCount];
//    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
//    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name == %@", @"Kg"];
//    [request setPredicate:filter];
//    NSArray *kgUnit = [[[self cdh] context] executeFetchRequest:request error:nil];
//    for (Unit *unit in kgUnit) {
//        NSError *error;
//        if ([unit validateForDelete:&error]) {
//            NSLog(@"Deleting '%@'", unit.name);
//            [_coreDataHelper.context deleteObject:unit];
//        } else {
//            NSLog(@"Failed to delete %@, Error: %@", unit.name, error.localizedDescription);
//        }
//    }
//    
//    NSLog(@"After deletion of the unit entity");
//    [self showUnitAndItemCount];
//    
//    [[self cdh] saveContext];
    
//    CoreDataHelper *cdh = [self cdh];
//    NSArray *homeLocations = [NSArray arrayWithObjects:@"Fruit Bowl", @"Pantry", @"Nursery", @"Bathroom", @"Fridge", nil];
//    NSArray *shopLocations = [NSArray arrayWithObjects:@"Produce", @"Aisle 1", @"Aisle 2", @"Aisle 3", @"Deli", nil];
//    NSArray *unitNames = [NSArray arrayWithObjects:@"g", @"pkt", @"box", @"ml", @"kg", nil];
//    NSArray *itemNames = [NSArray arrayWithObjects:@"Grapes", @"Biscuits", @"Nappies", @"Shampoo", @"Sausages", nil];
//    int i = 0;
//    for (NSString *itemName in itemNames) {
//        if (debug == 1) {
//            NSLog(@"Running %@ '%@' i = %i", self.class, NSStringFromSelector(_cmd), i);
//        }
//        LocationAtHome *locationAtHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome" inManagedObjectContext:cdh.context];
//        LocationAtShop *locationAtShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop" inManagedObjectContext:cdh.context];
//        Unit *unit = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:cdh.context];
//        Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:cdh.context];
//        
//        locationAtHome.storeIn = [homeLocations objectAtIndex:i];
//        locationAtShop.aisle   = [shopLocations objectAtIndex:i];
//        unit.name = [unitNames objectAtIndex:i];
//        item.name = [itemNames objectAtIndex:i];
//        
//        item.locationAtHome = locationAtHome;
//        item.locationAtShop = locationAtShop;
//        item.unit = unit;
//        
//        i++;
//    }
//    [cdh saveContext];
}

- (CoreDataHelper *)cdh {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!_coreDataHelper) {
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _coreDataHelper = [CoreDataHelper new];
        });
        [_coreDataHelper setupCoreData];
    }
    return _coreDataHelper;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[self cdh] backgroundSaveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self cdh];
    [self demo];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[self cdh] backgroundSaveContext];
}

@end
