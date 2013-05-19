//
//  SSNoteInfoViewController.m
//  NearbyNotes
//
//  Created by Shen Steven on 4/19/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "SSNoteInfoViewController.h"
#import "SSNoteInfoCover.h"
#import "SSTag.h"
#import <MapKit/MapKit.h>

@interface SSNoteInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SSNoteInfoViewController

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
  NSLog(@"%@", self.note);
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"NoteInfoCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) closeButtonDidTap:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  return 4;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0)
    return 0;
  if (section == 3)
    return self.note.tagGuids.count;
  return 1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    SSNoteInfoCover *cover = (SSNoteInfoCover*)[[[[UINib nibWithNibName:@"SSNoteInfoCover" bundle:nil] instantiateWithOwner:nil options:nil] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
      return [evaluatedObject isKindOfClass:[SSNoteInfoCover class]];
    }]] lastObject];
    [cover.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.note.attributes.latitude, self.note.attributes.longitude), MKCoordinateSpanMake(0.02, 0.02))];
    return cover;
  }
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == 0)
    return 150;
  return 22;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  switch (section) {
    case 1:
      return @"Title";

    case 2:
      return @"Create Time";
      
    case 3:
      return @"Tags";
      
    default:
      break;
  }
  
  return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteInfoCell" forIndexPath:indexPath];

  switch (indexPath.section) {
    case 1:
      cell.textLabel.text = self.note.title;
      break;

    case 2: {
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      formatter.dateStyle = NSDateFormatterMediumStyle;
      formatter.timeStyle = NSDateFormatterShortStyle;
      cell.textLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.note.created/1000]];
      break;
    }
    case 3: {
      NSString *tagGuid = self.note.tagGuids[indexPath.row];
      SSTag *tag = [SSTag MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"guid=%@", tagGuid]];
      if (tag) {
        cell.textLabel.text = tag.name;
      }
      break;
    }
      
    default:
      break;
  }
  
  return cell;
}

@end
