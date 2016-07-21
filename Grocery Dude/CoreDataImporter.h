//
//  CoreDataImporter.h
//  Grocery Dude
//
//  Created by Gerry on 7/21/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataImporter : NSObject

@property (nonatomic, retain) NSDictionary *entitiesWithUniqueAttributes;

+ (void)saveContext:(NSManagedObjectContext*) context;
- (CoreDataImporter*)initWithUniqueAttributes:(NSDictionary*)uniqueAttributes;;
- (NSString*)uniqueAtrributeForEntity:(NSString*)entity;

- (NSManagedObject*)insertUniqueObjectInTargetEntity:(NSString*)entity
                                uniqueAttributeValue:(NSString*)uniqueAttributeValue
                                     attributeValues:(NSDictionary*)attributeValues
                                           inContext:(NSManagedObjectContext*)context;

- (NSManagedObject*)insertBasicObjectInTargetEntity:(NSString *)entity
                              uniqueEntityAttribute:(NSString *)targetEntityAttribute
                                 sourceXMLAttribute:(NSString *)sourceXMLAttribute
                                    attributeDic:(NSDictionary *)attributeDic
                                            Context:(NSManagedObjectContext *)context;
@end
