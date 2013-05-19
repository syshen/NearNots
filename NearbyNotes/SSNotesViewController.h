//
//  SSNotesViewController.h
//  NearbyNotes
//
//  Created by Shen Steven on 4/19/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Evernote-SDK-iOS/EvernoteSDK.h>

@interface SSNotesViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectID *notebookID;

@end
