//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by Gerry on 7/18/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import "CoreDataHelper.h"
#import "CoreDataImporter.h"

@implementation CoreDataHelper

#define debug 1

#pragma mark - FILES
NSString *storeFilename = @"Grocery-Dude.sqlite";
NSString *sourceStoreFilename = @"DefaultData.sqlite";

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

- (NSURL *)sourceStoreURL {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [NSURL fileURLWithPath:[[NSBundle mainBundle]
                  pathForResource:[sourceStoreFilename stringByDeletingPathExtension]
                           ofType:[sourceStoreFilename pathExtension]]];
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
    
    _importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_importContext performBlockAndWait:^{
        [_importContext setPersistentStoreCoordinator:_coordinator];
        [_importContext setUndoManager:nil];  // the default on iOS
    }];
    
    _sourceCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _sourceContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_sourceContext performBlockAndWait:^{
        [_sourceContext setPersistentStoreCoordinator:_sourceCoordinator];
        [_sourceContext setUndoManager:nil];  // the default on ios;
    }];
    
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
            NSLog(@"Failed to add store. Error: %@", error);
            abort();
        }
        else {
            NSLog(@"Successfully added store: %@", _store);
        }
    }
}

- (void)loadSourceStore {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_sourceStore)
        return;
    
    NSDictionary *options = @{NSReadOnlyPersistentStoreOption:@YES};
    NSError *error = nil;
    _sourceStore = [_sourceCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                    configuration:nil
                                                              URL:[self sourceStoreURL]
                                                          options:options
                                                            error:&error];
    if (!_sourceStore) {
        NSLog(@"Failed to add source store. Error: %@",error);
        abort();
    } else {
        NSLog(@"Successfully added source store: %@", _sourceStore);
    }
}

- (void)setupCoreData {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
//    [self setDefaultDataStoreAsInitialStore];
    [self loadStore];
    [self checkIfDefaultDataNeedsImporting];
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

#pragma mark - DATA IMPORT

- (BOOL)isDefaultDataAlreadyImportedForStoreWithURL:(NSURL*)url ofType:(NSString*)type {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSError *error;
    NSDictionary *dictionary = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                                                          URL:url
                                                                                        error:&error];
    if (error) {
        NSLog(@"Error reading persistent store metadata: %@", error.localizedDescription);
    } else {
        NSNumber *defaultDataAlreadyImported = [dictionary valueForKey:@"DefaultDataImported"];
        if (![defaultDataAlreadyImported boolValue]) {
            NSLog(@"Default Data has NOT already been imported");
            return NO;
        }
    }
    if (debug == 1) {
        NSLog(@"Default DATA HAS already been imported");
    }
    return YES;
}

-(void)checkIfDefaultDataNeedsImporting {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (![self isDefaultDataAlreadyImportedForStoreWithURL:[self storeURL] ofType:NSSQLiteStoreType]) {
        self.importAlertView = [[UIAlertView alloc] initWithTitle:@"Import Default Data?"
                                                          message:@"If you've never use Grocery Dude before then some default data might help you understand how to use it. Tap 'Import' to import default data. Tap 'Cancel' to skip the import, especially if you've done this before on other devices."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Import", nil];
        [self.importAlertView show];
    }
}

- (void)importFromXML:(NSURL*)url {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    self.parser.delegate = self;
    
    NSLog(@"**** START PARSE OF %@", url.path);
    [self.parser parse];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
    NSLog(@"**** END PARSE OF %@", url.path);
}

-(void)setDefaultDataAsImportedForStore:(NSPersistentStore*)aStore {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // get metadata dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[[aStore metadata] copy]];
    if (debug == 1) {
        NSLog(@"__Store Metadata BEFORE changes__ \n %@", dictionary);
    }
    
    // edit metadata dictionary
    [dictionary setObject:@YES forKey:@"DefaultDataImported"];
    
    // set metadata dictionary
    [self.coordinator setMetadata:dictionary forPersistentStore:aStore];
    if (debug == 1) {
        NSLog(@"__Store Metadata AFTER changes__ \n %@", dictionary);
    }
}

- (void)setDefaultDataStoreAsInitialStore {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.storeURL.path]) {
        
        NSURL *defaultDataURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DefaultData" ofType:@"sqlite"]];
        
        NSError *error = nil;
        if (![fileManager copyItemAtURL:defaultDataURL toURL:self.storeURL error:&error]) {
            NSLog(@"DefaultData.sqlite copy FAIL: %@", error.localizedDescription);
        } else {
            NSLog(@"A copy of DefaultData.sqlite was set as the initial store for %@", self.storeURL);
        }
    }
}

- (void)deepCopyFromPersistentStore:(NSURL*)url {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Perodically refresh the interface during the import
    _importTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                    target:self
                                                  selector:@selector(somethingChanged)
                                                  userInfo:nil
                                                   repeats:YES];
    
    [_sourceContext performBlock:^{
        NSLog(@"*** STARTED DEEP COPY FROM DATA PERSISTENT STORE ***");
        NSArray *entitiesToCopy = [NSArray arrayWithObjects:@"LocationAtHome", @"LocationAtShop", @"Unit", @"Item", nil];
        CoreDataImporter *importer = [[CoreDataImporter alloc]
                                      initWithUniqueAttributes:[self selectedUniqueAttributes]];
        [importer deepCopyEntities:entitiesToCopy fromContext:_sourceContext toContext:_importContext];
        [_context performBlock:^{
            // Stop periodically refreshing the interface
            [_importTimer invalidate];
            
            // Tell the interface to refresh once import completess
            [self somethingChanged];
        }];
        NSLog(@"*** FINISHED DEEP COPY FROM DEFAULT DATA PERSISTENT STORE ***");
    }];
}
#pragma mark - DELEGATE: UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (alertView == self.importAlertView) {
        if (buttonIndex == 1) {  // The 'Import' button on the importAlertView
            NSLog(@"Default Data Import Approved by User");
            [_importContext performBlock:^{
                
//                // XML Import
//                [self importFromXML:[[NSBundle mainBundle]
//                                     URLForResource:@"DefaultData" withExtension:@"xml"]];
                
                // Deep Copy Import From Persistent Store
                [self loadSourceStore];
                [self deepCopyFromPersistentStore:[self sourceStoreURL]];
                
            }];
        } else {
            NSLog(@"Default Data Import Cancelled by User");
        }
        // Set the data as imported regardless of the user's decision
        [self setDefaultDataAsImportedForStore:_store];
    }
}

#pragma mark - UNIQUE ATTRIBUTE SELECTION
// This code is Crocery Dude data specific and is used when instantiating CoreDataImporter
- (NSDictionary*)selectedUniqueAttributes {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableArray *entities   = [NSMutableArray new];
    NSMutableArray *attributes = [NSMutableArray new];
    
    // Select an attribute in each entity for uniqueness
    [entities addObject:@"Item"];[attributes addObject:@"name"];
    [entities addObject:@"Unit"];[attributes addObject:@"name"];
    [entities addObject:@"LocationAtHome"];[attributes addObject:@"storeIn"];
    [entities addObject:@"LocationAtShop"];[attributes addObject:@"aisle"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:attributes forKeys:entities];
    
    return dictionary;
}

#pragma mark - DELEGATE: NSXMLParser
// This code is Grocery Dude adta specific
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}
- (void)parser:(NSXMLParser*)parser didStartElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(nonnull NSDictionary<NSString *,NSString *> *)attributeDict {
    [self.importContext performBlockAndWait:^{
        // STEP 1: Process only the 'item' element in the XML file
        if ([elementName isEqualToString:@"item"]) {
            // STEP 2: Prepare the Core Data Importer
            CoreDataImporter *importer = [[CoreDataImporter alloc] initWithUniqueAttributes:[self selectedUniqueAttributes]];
            
            // STEP 3a: Insert a unique 'Item' Object
            NSManagedObject *item = [importer insertBasicObjectInTargetEntity:@"Item"
                                                        uniqueEntityAttribute:@"name"
                                                           sourceXMLAttribute:@"name"
                                                                 attributeDic:attributeDict
                                                                      Context:_importContext];
            // STEP 3b: Insert a unique 'Unit' Object
            NSManagedObject *unit = [importer insertBasicObjectInTargetEntity:@"Unit"
                                                        uniqueEntityAttribute:@"name"
                                                           sourceXMLAttribute:@"unit"
                                                                 attributeDic:attributeDict
                                                                      Context:_importContext];
            
            // STEP 3c: Insert a unique 'LocationAtHome' Object
            NSManagedObject *locationAtHome = [importer insertBasicObjectInTargetEntity:@"LocationAtHome"
                                                                  uniqueEntityAttribute:@"storeIn"
                                                                     sourceXMLAttribute:@"locationathome"
                                                                           attributeDic:attributeDict
                                                                                Context:_importContext];
            
            // STEP 3d: Insert a unique 'LocationAtHome' Object
            NSManagedObject *locationAtShop = [importer insertBasicObjectInTargetEntity:@"LocationAtShop"
                                                                  uniqueEntityAttribute:@"aisle"
                                                                     sourceXMLAttribute:@"locationatshop"
                                                                           attributeDic:attributeDict
                                                                                Context:_importContext];
            
            // STEP 4: Manually add extra attribute values
            [item setValue:@NO forKey:@"listed"];
            
            // STEP 5: Create relationships
            [item setValue:unit forKey:@"unit"];
            [item setValue:locationAtHome forKey:@"locationAtHome"];
            [item setValue:locationAtShop forKey:@"locationAtShop"];
            
            // STEP 6: Save new objects to the persistent store
            [CoreDataImporter saveContext:_importContext];
            
            // STEP 7: Turn objects into faults to save memory
            [_importContext refreshObject:item mergeChanges:NO];
            [_importContext refreshObject:unit mergeChanges:NO];
            [_importContext refreshObject:locationAtHome mergeChanges:NO];
            [_importContext refreshObject:locationAtShop mergeChanges:NO];
        }
    }];
}

#pragma mark - UNDERLYING DATA CHANGE NOTIFICATION
- (void)somethingChanged {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Send a notification that tells observing interfaces to refresh their data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
}

@end








