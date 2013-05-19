//
//  SSENSyncManager.m
//  NearbyNotes
//
//  Created by Shen Steven on 4/20/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "SSENSyncManager.h"
#import "SSNote.h"
#import "SSNotebook.h"
#import "SSTag.h"

@interface SSENSyncManager ()

@property (nonatomic, strong) NSOperationQueue *syncQueue;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, assign) NSUInteger syncInteval;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SSENSyncManager

- (id) init {
  self = [super init];
  if (self) {
    
    self.syncQueue = [[NSOperationQueue alloc] init];
    self.syncQueue.maxConcurrentOperationCount = 1;
    
    self.downloadQueue = [[NSOperationQueue alloc] init];
    self.downloadQueue.maxConcurrentOperationCount = 1;

    self.syncInteval = 10;
   
    [self.timer fire];
  }
  return self;
}

- (void) reload {
  
  [self.timer invalidate];
  self.timer = nil;  
  [self.timer fire];
}

- (NSTimer *)timer {
  if (_timer)
    return _timer;
  
  _timer = [NSTimer scheduledTimerWithTimeInterval:self.syncInteval
                                            target:self
                                          selector:@selector(performOperations)
                                          userInfo:nil repeats:YES];
  return _timer;
}

- (BOOL) reloading {
  return (self.syncQueue.operationCount || self.downloadQueue.operationCount);
}

- (void) saveAllChangedNotes:(NSArray*)notes {
 
  [notes enumerateObjectsUsingBlock:^(EDAMNote *note, NSUInteger idx, BOOL *stop) {
    SSNote *updatingNote = [SSNote MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"guid = %@", note.guid]];
    
    if (!updatingNote) {
      updatingNote = [SSNote MR_createEntity];
    } else {
      NSLog(@"Found note: %@", updatingNote);
    }
    updatingNote.guid = note.guid;
    updatingNote.title = note.title;
    updatingNote.content = note.content;
    updatingNote.latitude = @(note.attributes.latitude);
    updatingNote.longitude = @(note.attributes.longitude);
    
    NSArray *tags = [SSTag MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"guid in %@", note.tagGuids]];
    if (tags)
      updatingNote.tags = [NSSet setWithArray:tags];
    
    SSNotebook *notebook = [SSNotebook MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"guid = %@", note.notebookGuid]];
    if (notebook)
      updatingNote.notebook = notebook;
    
  }];

  [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
    
    if (error) {
      NSLog(@"Fail to save SSNote for error: %@", error);
    }
    if (success) {
      NSLog(@"Save SSNotes successfully");
    }
    
  }];
  
}

- (void) saveAllChangedNotebooks:(NSArray*)notebooks {
  
  [notebooks enumerateObjectsUsingBlock:^(EDAMNotebook *notebook, NSUInteger idx, BOOL *stop) {
    SSNotebook *updatingNotebook = [SSNotebook MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"guid = %@", notebook.guid]];
    
    if (!updatingNotebook) {
      updatingNotebook = [SSNotebook MR_createEntity];
    } else {
      NSLog(@"Found notebook: %@", updatingNotebook);
    }
    updatingNotebook.guid = notebook.guid;
    updatingNotebook.title = notebook.name;
    
  }];
  
  [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {

    if (error) {
      NSLog(@"Fail to save notebooks for error: %@", error);
    }
    if (success) {
      NSLog(@"Successfully save notebooks");
    }
  }];

}

- (void) saveAllChangedTags:(NSArray*)tags {
  
  [tags enumerateObjectsUsingBlock:^(EDAMTag *tag, NSUInteger idx, BOOL *stop) {
    SSTag *updatingTag = [SSTag MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"guid = %@", tag.guid]];
    
    if (!updatingTag) {
      updatingTag = [SSTag MR_createEntity];
    } else {
      NSLog(@"Found tags: %@", updatingTag);
    }
    updatingTag.guid = tag.guid;
    updatingTag.name = tag.name;
    
  }];
  
  [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
    if (error) {
      NSLog(@"Fail to save SSTag for error: %@", error);
    }
    if (success) {
      NSLog(@"Save SSTags successfully");
    }
  }];

}

- (void) performOperations {

  NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
    
    NSInteger lastUpdateCount = [[NSUserDefaults standardUserDefaults] integerForKey:kLastUpdateCount];
    [[EvernoteNoteStore noteStore] getSyncStateWithSuccess:^(EDAMSyncState *syncState) {
      
      if (lastUpdateCount < syncState.updateCount) {
        // something changes
        NSLog(@"new update count: %d", syncState.updateCount);
        
        NSBlockOperation *dnOp = [NSBlockOperation blockOperationWithBlock:^{
          NSInteger lastSyncUSN = [[NSUserDefaults standardUserDefaults] integerForKey:kLastSyncUSN];
          BOOL fullSync = NO;
          if (lastUpdateCount == 0)
            fullSync = YES;
          [[EvernoteNoteStore noteStore] getSyncChunkAfterUSN:lastSyncUSN
                                                   maxEntries:255
                                                 fullSyncOnly:NO
                                                      success:^(EDAMSyncChunk *syncChunk) {
//                                                        NSLog(@"syncChunk: %@", syncChunk);
                                                        if (syncChunk.tags.count)
                                                          [self saveAllChangedTags:syncChunk.tags];

                                                        if (syncChunk.notebooks.count)
                                                          [self saveAllChangedNotebooks:syncChunk.notebooks];

                                                        if (syncChunk.notes.count)
                                                          [self saveAllChangedNotes:syncChunk.notes];
                                                        
//                                                        [[NSUserDefaults standardUserDefaults] setInteger:syncChunk.chunkHighUSN forKey:kLastSyncUSN];
                                                      }
                                                      failure:^(NSError *error) {
                                                        NSLog(@"Fail to get full sync for error: %@", error);
                                                      }];
          
        }];
        [self willChangeValueForKey:@"reloading"];
        [self.downloadQueue addOperation:dnOp];
        [self didChangeValueForKey:@"reloading"];

//        [[NSUserDefaults standardUserDefaults] setInteger:syncState.updateCount forKey:kLastUpdateCount];
      }
      
    } failure:^(NSError *error) {
      
      NSLog(@"fail to get sync state for error: %@", error);
      
    }];
    
  }];
  
  [self willChangeValueForKey:@"reloading"];
  [self.syncQueue addOperation:op];
  [self didChangeValueForKey:@"reloading"];
  
}

- (void) cancelAllOperations {
  [self.syncQueue cancelAllOperations];
}

@end
