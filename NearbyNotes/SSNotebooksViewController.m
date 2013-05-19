//
//  SSNotebooksViewController.m
//  NearbyNotes
//
//  Created by Shen Steven on 4/19/13.
//  Copyright (c) 2013 syshen. All rights reserved.
//

#import "SSNotebooksViewController.h"
#import "SSEvernoteLoginViewController.h"
#import "SSNotesViewController.h"
#import "SSENSyncManager.h"
#import "SSNotebook.h"

@interface SSNotebooksViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) SSENSyncManager *syncManager;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *insertingIndexPath;
@property (nonatomic, strong) NSMutableArray *deletingIndexPath;
@property (nonatomic, strong) NSMutableArray *updatingIndexPath;
@property (nonatomic, strong) NSMutableArray *movingIndexPath;
@end

@implementation SSNotebooksViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.fetchedResultsController = [SSNotebook MR_fetchAllSortedBy:@"title"
                                                        ascending:YES
                                                    withPredicate:nil
                                                          groupBy:nil
                                                         delegate:self];
  self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, -60, self.view.frame.size.width, 60)];
  self.refreshControl.tintColor = [UIColor blackColor];
  self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull down to refresh"];
  [self.view addSubview:self.refreshControl];
  
  if (!self.fetchedResultsController.fetchedObjects.count) {
    self.refreshControl.attributedTitle =[[NSAttributedString alloc] initWithString:@"Refreshing"];
    [self.refreshControl beginRefreshing];
  }
  [self.refreshControl addTarget:self action:@selector(startRefresh) forControlEvents:UIControlEventValueChanged];
  
  if (![[EvernoteSession sharedSession] isAuthenticated]) {
    
    __block SSEvernoteLoginViewController *loginVC = [[SSEvernoteLoginViewController alloc] initWithCompletionHandler:^(NSError *error) {
      
      if (error) {
        
      } else {
        self.syncManager = [[SSENSyncManager alloc] init];
        [self.syncManager addObserver:self
                           forKeyPath:@"reloading"
                              options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                              context:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
          [loginVC dismissViewControllerAnimated:YES completion:nil];
          
        });
      }
      
    }];
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    loginVC.view.alpha = 0;
    [self presentViewController:loginVC animated:NO completion:nil];
    [UIView animateWithDuration:0.5 animations:^{
      loginVC.view.alpha = 1;
    }];

    
  } else {
    
    self.syncManager = [[SSENSyncManager alloc] init];
    [self.syncManager addObserver:self
                       forKeyPath:@"reloading"
                          options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                          context:nil];

  }
  
}

- (void) dealloc {
  if (self.syncManager)
    [self.syncManager removeObserver:self forKeyPath:@"reloading"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startRefresh {
  [self.syncManager reload];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

  if ([keyPath isEqualToString:@"reloading"]) {
    if (!self.syncManager.reloading)
      [self.refreshControl endRefreshing];
  }
  
}

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
 
  self.insertingIndexPath = [NSMutableArray array];
  self.updatingIndexPath = [NSMutableArray array];
  self.deletingIndexPath = [NSMutableArray array];
  self.movingIndexPath = [NSMutableArray array];
  
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
 
  switch (type) {
    case NSFetchedResultsChangeInsert:
      [self.insertingIndexPath addObject:newIndexPath];
      break;
      
    case NSFetchedResultsChangeUpdate:
      [self.updatingIndexPath addObject:indexPath];
      break;
      
    case NSFetchedResultsChangeDelete:
      [self.deletingIndexPath addObject:indexPath];
      break;
      
    case NSFetchedResultsChangeMove:
      [self.movingIndexPath addObject:@{@"oldIndexPath": indexPath, @"newIndexPath": newIndexPath}];
      break;
      
    default:
      break;
  }
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
  
  if (self.refreshControl.refreshing)
    [self.refreshControl endRefreshing];

  if (self.insertingIndexPath.count)
    [self.tableView insertRowsAtIndexPaths:self.insertingIndexPath withRowAnimation:YES];
  
  if (self.deletingIndexPath.count)
    [self.tableView deleteRowsAtIndexPaths:self.deletingIndexPath withRowAnimation:YES];
  
  if (self.updatingIndexPath.count)
    [self.tableView reloadRowsAtIndexPaths:self.updatingIndexPath withRowAnimation:YES];
  
  if (self.movingIndexPath.count) {
    for (NSDictionary *changes in self.movingIndexPath) {
      [self.tableView moveRowAtIndexPath:changes[@"oldIndexPath"] toIndexPath:changes[@"newIndexPath"]];
    }
  }
  
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotebookCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
//  cell.textLabel.text = [(SSNotebook*)self.fetchedResultsController.fetchedObjects[indexPath.row] title];
 
  cell.textLabel.text = [(SSNotebook*)[self.fetchedResultsController objectAtIndexPath:indexPath] title];
  
  return cell;
}


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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"NotesList"]) {
    
    SSNotesViewController *notesVC = (SSNotesViewController*)segue.destinationViewController;
    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    notesVC.notebookID = [(SSNotebook*)[self.fetchedResultsController objectAtIndexPath:indexPath] objectID];
    
  }
}


@end
