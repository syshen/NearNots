//
//  SSEvernoteLoginViewController.h
//  NearbyNotes
//
//  Created by Shen Steven on 4/19/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSEvernoteLoginViewController : UIViewController

- (id) initWithCompletionHandler:(void(^)(NSError*error))completionHandler;

@end
