//
//  SSNoteViewController.m
//  NearbyNotes
//
//  Created by Shen Steven on 4/19/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "SSNoteViewController.h"
#import "SSNoteInfoViewController.h"
#import "SSNote.h"

@interface SSNoteViewController ()
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) SSNote *note;
@property (nonatomic, strong) EDAMNote *remoteNote;
@end

@implementation SSNoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.note = (SSNote*)[[NSManagedObjectContext MR_contextForCurrentThread] objectWithID:self.noteID];
  
  self.title = @"Loading...";
  __weak SSNoteViewController *wSelf = self;
  [[EvernoteNoteStore noteStore] getNoteWithGuid:self.note.guid
                                     withContent:YES
                               withResourcesData:YES
                        withResourcesRecognition:YES
                      withResourcesAlternateData:YES
                                         success:^(EDAMNote *note) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                             [wSelf.webView loadHTMLString:note.content baseURL:[NSURL URLWithString:@"http://localhost"]];
                                             wSelf.title = note.title;
                                             wSelf.remoteNote = note;
                                           });
                                         }
                                         failure:^(NSError *error) {
                                           
                                         }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"NoteInfo"]) {
    UINavigationController *navVC = (UINavigationController*)segue.destinationViewController;
    SSNoteInfoViewController *infoVC = (SSNoteInfoViewController*)(navVC.topViewController);
    infoVC.note = self.remoteNote;
  }

}
@end
