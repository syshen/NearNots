//
//  SSTag.h
//  NearbyNotes
//
//  Created by Shen Steven on 4/20/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SSTag : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * name;

@end
