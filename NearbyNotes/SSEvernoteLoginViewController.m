//
//  SSEvernoteLoginViewController.m
//  NearbyNotes
//
//  Created by Shen Steven on 4/19/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "SSEvernoteLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Evernote-SDK-iOS/EvernoteSDK.h>

@interface SSEvernoteLoginViewController ()
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, copy) void (^completionHandler)(NSError *error);
@end

@implementation SSEvernoteLoginViewController

- (id) initWithCompletionHandler:(void(^)(NSError*error))completionHandler {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    self.completionHandler = completionHandler;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.bottomView.layer.cornerRadius = 5;
  self.loginButton.layer.cornerRadius = 15;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) loginButtonTapped:(id)sender {
  EvernoteSession *session = [EvernoteSession sharedSession];
  [session authenticateWithViewController:self
                        completionHandler:^(NSError *error) {
                          
                          if (error || !session.isAuthenticated) {
                            if (error) {
                              if (self.completionHandler)
                                self.completionHandler(error);
                            } else {
                              if (self.completionHandler)
                                self.completionHandler([NSError errorWithDomain:@"User" code:-1 userInfo:nil]);
                            }
                          } else {
                            
                            if (self.completionHandler)
                              self.completionHandler(nil);
                            
                          }
                        }];
}

@end
