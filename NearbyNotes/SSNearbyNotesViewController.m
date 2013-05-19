//
//  SSNearbyNotesViewController.m
//  NearbyNotes
//
//  Created by Shen Steven on 4/19/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "SSNearbyNotesViewController.h"
#import "SSNoteViewController.h"
#import "Haversine.h"
#import "SSNote.h"
#import <CoreLocation/CoreLocation.h>

@interface SSNearbyNotesViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) NSArray *unsortedNotes;
@property (nonatomic, strong) NSArray *sortedNotes;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;
@end

@implementation SSNearbyNotesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = 10;
  [self.locationManager startUpdatingLocation];

  self.unsortedNotes = [SSNote MR_findAll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
  [self.locationManager stopUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
 
  if (!locations.count)
    return;
  
  CLLocation *newLocation = locations[0];
  self.currentCoordinate = newLocation.coordinate;
  [self sortNotesBasedOnLocation:newLocation.coordinate];
  [self.tableView reloadData];
  
}

- (void) sortNotesBasedOnLocation:(CLLocationCoordinate2D)coordinate {
  NSMutableArray *sortingNotes = [NSMutableArray arrayWithArray:self.unsortedNotes];

  [sortingNotes sortUsingComparator:^NSComparisonResult(SSNote *note1, SSNote *note2) {
    Haversine *h1 = [[Haversine alloc] init];
    h1.source = coordinate;
    h1.dest = CLLocationCoordinate2DMake([note1.latitude floatValue], [note1.longitude floatValue]);
    
    Haversine *h2 = [[Haversine alloc] init];
    h2.source = coordinate;
    h2.dest = CLLocationCoordinate2DMake([note2.latitude floatValue], [note2.longitude floatValue]);
    
    return h1.distance > h2.distance;
  }];
  
  self.sortedNotes = [NSArray arrayWithArray:sortingNotes];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.sortedNotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"NearByCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  SSNote *note = (SSNote*)self.sortedNotes[indexPath.row];
  cell.textLabel.text = note.title;
  
  Haversine *h = [[Haversine alloc] init];
  h.source = self.currentCoordinate;
  h.dest = CLLocationCoordinate2DMake(note.latitude.floatValue, note.longitude.floatValue);
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f km", h.toKilometers];
  
  return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"NoteDetail"]) {
    
    SSNoteViewController *noteVC = (SSNoteViewController*)segue.destinationViewController;
    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SSNote *note = (SSNote*)self.sortedNotes[indexPath.row];
    noteVC.noteID = note.objectID;

  }
}

@end
