//
//  SSNotebook.h
//  NearbyNotes
//
//  Created by Shen Steven on 4/20/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SSNote;

@interface SSNotebook : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *notes;
@end

@interface SSNotebook (CoreDataGeneratedAccessors)

- (void)addNotesObject:(SSNote *)value;
- (void)removeNotesObject:(SSNote *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
