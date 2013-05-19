//
//  SSENSyncManager.h
//  NearbyNotes
//
//  Created by Shen Steven on 4/20/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSENSyncManager : NSObject
- (void) reload;

@property (nonatomic, readonly) BOOL reloading;

@end
