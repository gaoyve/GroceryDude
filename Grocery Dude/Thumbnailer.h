//
//  Thumbnailer.h
//  Grocery Dude
//
//  Created by Gerry on 7/23/16.
//  Copyright © 2016 Tim Roadley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Thumbnailer : NSObject
+ (void)createMissingThumbnailsForEntityName:(NSString*)entityName
                  withThumbnailAttributeName:(NSString*)thumbnailAttributeName
                   withPhotoRelationshipName:(NSString*)photoRelationshipName
                      withPhotoAttributeName:(NSString*)phototAttributeName
                         withSortDescriptors:(NSArray*)sortDescriptors
                           withImportContext:(NSManagedObjectContext*)importContext;

@end
