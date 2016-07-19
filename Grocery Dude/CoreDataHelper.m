//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by Gerry on 7/18/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

#define debug 1

#pragma mark - FILES
NSString *storeFilename = @"Grocery-Dude.sqlite";

#pragma mark - PATHS
- (NSString *)applicationDocumentsDirectory {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
- (NSURL *)applicationStoresDirectory {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storesDirectory
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error]) {
            if (debug == 1) {
                NSLog(@"Successfully creates Stores directory");
            }
        }
        else {NSLog(@"FAILED to create Stores Directory: %@", error);}
    }
    return storesDirectory;
}
- (NSURL *)storeURL {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];
}

#pragma mark - SETUP
- (id)init {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (!self) return nil;
    
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:_coordinator];
    
    return self;
}
- (void)loadStore {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_store) return; // Don't load store if it's already loaded
    
    
    BOOL useMigrationManager = NO;
    if (useMigrationManager && [self isMigrationNecessaryForStore:[self storeURL]]) {
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    } else {
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                  NSInferMappingModelAutomaticallyOption: @YES,
                                  NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}};
        NSError *error = nil;
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                            configuration:nil
                                                      URL:[self storeURL]
                                                  options:options
                                                    error:&error];
        if (!_store) {
            NSLog(@"Failed to add store. Error: %@", error); abort();
        }
        else {
            NSLog(@"Successfully added store: %@", _store);
        }
    }
}
- (void)setupCoreData {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self loadStore];
}

#pragma mark - SAVING
- (void)saveContext {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_context hasChanges]) {
        NSError *error = nil;
        if ([_context save:&error]) {
            NSLog(@"_context SAVED changes to persistent store");
        } else {
            NSLog(@"Failed to save _context: %@", error);
            [self showValidationError:error];
        }
    } else {
        NSLog(@"SKIPPED _context save, there are no changes!");
    }
}

#pragma mark - MIGRATION MANAGER
- (BOOL)isMigrationNecessaryForStore:(NSURL*)storeURL {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
        if (debug == 1) NSLog(@"SKIPPED MIGRATION: Source database missing.");
        return NO;
    }
    NSError *error = nil;
    NSDictionary *sourceMatadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL error:&error];
    NSManagedObjectModel *destinationModel = _coordinator.managedObjectModel;
    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMatadata]) {
        if (debug == 1) {
            NSLog(@"SKIPPED MIGRATION: Source is already compitable");
            return NO;
        }
    }
    return YES;
}

- (BOOL)migrateStore:(NSURL*)sourceStoreURL {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    BOOL success = NO;
    NSError *error = nil;
    
    // STEP 1 - Gather the Source, Destination and Mapping Model
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sourceStoreURL error:&error];
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil
                                                                    forStoreMetadata:sourceMetadata];
    NSManagedObjectModel *destinModel = _model;
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                            forSourceModel:sourceModel
                                                          destinationModel:destinModel];
    // STEP 2 - Perform migration, assuming the mapping model isn't null
    if (mappingModel) {
        NSError *error = nil;
        NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                                                              destinationModel:destinModel];
        [migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];
        
        NSURL *destinStoreURL = [[self applicationStoresDirectory] URLByAppendingPathComponent:@"Temp.sqlite"];
        
        success = [migrationManager migrateStoreFromURL:sourceStoreURL
                                                   type:NSSQLiteStoreType
                                                options:nil
                                       withMappingModel:mappingModel
                                       toDestinationURL:destinStoreURL
                                        destinationType:NSSQLiteStoreType
                                     destinationOptions:nil
                                                  error:&error];
        
        if (success) {
            // STEP 3 - Replace the old store with the new migrate store
            if ([self replaceStoreURL:sourceStoreURL withStoreURL:destinStoreURL]) {
                if (debug == 1) {
                    NSLog(@"SUCCESSFULLY MIGRATION %@ to the Current Model", sourceStoreURL.path);
                }
                [migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
            }
        } else {
            if (debug == 1) {
                NSLog(@"FAILED MIGRATION: %@", error);
            }
        }
    } else {
        if (debug == 1) {
            NSLog(@"FAILED MIGRATION: Mapping Model is null");
        }
    }
    return YES;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            self.migrationViewController.progressView.progress = progress;
            int percentage = progress * 100;
            NSString *string = [NSString stringWithFormat:@"Migration Progress: %i%%", percentage];
            NSLog(@"%@",string);
            self.migrationViewController.label.text = string;
        });
    }
}

- (BOOL)replaceStoreURL:(NSURL*)old withStoreURL:(NSURL*)new {
    BOOL success = NO;
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager] removeItemAtURL:old error:&error]) {
        error = nil;
        if ([[NSFileManager defaultManager] moveItemAtURL:new toURL:old error:&error]) {
            success = YES;
        } else {
            if (debug == 1) {
                NSLog(@"FAILED to re-home new store %@", error);
            }
        }
    } else {
        if (debug == 1) {
            NSLog(@"FAILED to remove old store %@: Error:%@", old, error);
        }
    }
    return success;
}

- (void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    // Show migration progress view preventing the user from using the app
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.migrationViewController = [sb instantiateViewControllerWithIdentifier:@"migration"];
    UIApplication *sa = [UIApplication sharedApplication];
    UINavigationController *nc = (UINavigationController *)sa.keyWindow.rootViewController;
    [nc presentViewController:self.migrationViewController animated:NO completion:nil];
    
    // Perform migration in the background, so it doesn't freeze the UI.
    // This way progress can be shown to the user
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL done = [self migrateStore:storeURL];
        if (done) {
            // When migration finishes, add the newly migrated store
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                    configuration:nil
                                                              URL:[self storeURL]
                                                          options:nil
                                                            error:&error];
                if (!_store) {
                    NSLog(@"Failed to add migrated store. Error: %@", error);
                    abort();
                } else {
                    NSLog(@"Successfully added a migrated store: %@", _store);
                }
                [self.migrationViewController dismissViewControllerAnimated:NO completion:nil];
                self.migrationViewController = nil;
            });
        }
    });
}

#pragma mark - VALIDATION ERROR HANDLING
- (void)showValidationError:(NSError *)anError {
    if (anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray *errors = nil;  // holdd all errors
        NSString *text = @"";    // the error message text of the alert
        
        // Populate array with error(s)
        if (anError.code == NSValidationMultipleErrorsError) {
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        } else {
            errors = [NSArray arrayWithObject:anError];
        }
        // Display the error(s)
        if (errors && errors.count > 0) {
            // Build error message text based on errors
            for (NSError * error in errors) {
                NSString *entity = [[[error.userInfo objectForKey:@"NSValidationErrorObject"] entity] name];
                NSString *property = [error.userInfo objectForKey:@"NSValidationError"];
                
                switch (error.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        text = [text stringByAppendingFormat:@"%@ delete was denied because there are associated %@\n(Error code %li)\n\n", entity, property, (long)error.code];
                        break;
                        
                    default:
                        text = [text stringByAppendingFormat:@"Unhandled error code %li in showValidationError method", (long)error.code];
                        break;
                }
            }
            // dispaly error message text message
            
        }
    }
}
@end








