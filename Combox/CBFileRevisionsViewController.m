//
//  CBFileRevisionsViewController.m
//  Combox
//
//  Created by Andrés Ibañez on 8/28/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import "CBFileRevisionsViewController.h"

@interface CBFileRevisionsViewController ()

@end

@implementation CBFileRevisionsViewController
@synthesize doneButton;
@synthesize file;

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
    [[self restClient] loadRevisionsForFile:file.path limit:30];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setDoneButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"Revisions count. %d", [fileRevisions count]);
    return [fileRevisions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"restoreRevisionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = ((DBMetadata *)[fileRevisions objectAtIndex:indexPath.row]).rev;
    
    return cell;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    UITableViewCell *selectedCell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    UILabel *revisionLbl = (UILabel *)[selectedCell viewWithTag:40];
    [[self restClient] restoreFile:file.path toRev:revisionLbl.text];
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    [self.tableView reloadData];
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    
    NSLog(@"Error loading metadata: %@", error);
}

// Folder is the metadata for the newly created folder
- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder
{
}

// [error userInfo] contains the root and path
- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error{
    NSLog(@"%@",error);
}

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path
{
}
- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error
{
    NSLog(@"Couldn't delete %@", error);
}

- (void)restClient:(DBRestClient*)client loadedRevisions:(NSArray *)revisions forFile:(NSString *)path
{
    fileRevisions = [NSArray arrayWithArray:revisions];
}

- (void)restClient:(DBRestClient*)client loadRevisionsFailedWithError:(NSError *)error
{
    
}

- (void)restClient:(DBRestClient*)client restoredFile:(DBMetadata *)fileMetadata
{
    UIAlertView *restoreSuccess = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restore Succesfull", @"Restore success title")
                                                             message:NSLocalizedString(@"The file has been succesfully restored to the specified revision", @"The file has been yadda string")
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"OK button")
                                                   otherButtonTitles:nil];
    [restoreSuccess show];
}

- (void)restClient:(DBRestClient*)client restoreFileFailedWithError:(NSError *)error
{
    
}

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
