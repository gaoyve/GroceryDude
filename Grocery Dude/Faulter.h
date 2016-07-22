//
//  Faulter.h
//  Grocery Dude
//
//  Created by Gerry on 7/23/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Faulter : NSObject

+ (void)faultObjectWithID:(NSManagedObjectID*)objectID inContext:(NSManagedObjectContext*)context;

@end
