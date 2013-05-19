//
//  SSNote.h
//  NearbyNotes
//
//  Created by Shen Steven on 4/20/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SSNotebook, SSTag;

@interface SSNote : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) SSNotebook *notebook;
@property (nonatomic, retain) NSSet *tags;
@end

@interface SSNote (CoreDataGeneratedAccessors)

- (void)addTagsObject:(SSTag *)value;
- (void)removeTagsObject:(SSTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
