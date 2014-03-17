//
//  CBMoveViewController.m
//  Combox
//
//  Created by Andrés Ibañez on 8/30/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import "CBMoveViewController.h"
#import "CBInformationViewController.h"
#import "CBAppDelegate.h"

@interface CBMoveViewController ()

@end

@implementation CBMoveViewController
@synthesize tableView;
@synthesize containerView;
@synthesize currentFolder;
@synthesize currentPath;

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
    currentFolder = self.navigationItem.title;
    if([currentFolder isEqualToString:@"Dropbox"])
    {
        currentPath = [NSMutableString stringWithString:@""];
    }
    foldersArray = [NSMutableArray array];
    [self completeReload];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)viewDidAppear:(BOOL)animated
{
    [self completeReload];
}

#pragma mark - Segue stuff

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CBMoveViewController *receiver = (CBMoveViewController *)segue.destinationViewController;
    UITableViewCell *selectedCell = (UITableViewCell *)sender;
    UILabel *theFolderName = (UILabel *)[selectedCell viewWithTag:20];
    NSString *tempFolder = currentFolder;
    currentFolder = theFolderName.text;
    receiver.navigationItem.title = currentFolder;
    if([tempFolder isEqualToString:@"Dropbox"])
    {
        [receiver performSelector:@selector(setCurrentPath:) withObject:[NSString stringWithFormat:@"/%@", currentFolder]];
    }else
    {
        [receiver performSelector:@selector(setCurrentPath:) withObject:[NSString stringWithFormat:@"%@/%@", currentPath, currentFolder]];
    }
}

#pragma mark - TableView stuff

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [foldersArray count];
}

-(void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lastSelectedIndexPath = indexPath;
    [tv deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"folderCell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:identifier];
    
    DBMetadata *folder = (DBMetadata *)[foldersArray objectAtIndex:indexPath.row];
    
    ((UILabel *)[cell viewWithTag:20]).text = folder.filename;
    ((UIImageView *)[cell viewWithTag:10]).image = [UIImage imageNamed:folder.icon];
    
    return cell;
}

#pragma mark - DBRestClientDelegate methods

- (DBRestClient *)restClient
{
    if (!restClient)
    {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
    [foldersArray removeAllObjects];
    for(DBMetadata *fileOrFolder in metadata.contents)
    {
        if(fileOrFolder.isDirectory)
        {
            [foldersArray addObject:fileOrFolder];
        }
    }
    [tableView reloadData];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError *)error
{
    NSLog(@"Load metadata failed %@, ", error);
}

-(void)restClient:(DBRestClient *)client createdFolder:(DBMetadata *)folder
{
    [self completeReload];
}

- (void)restClient:(DBRestClient*)client movedPath:(NSString *)from_path to:(DBMetadata *)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)restClient:(DBRestClient*)client movePathFailedWithError:(NSError*)error
{
    NSLog(@"%@", error);
}

#pragma mark - actions

- (IBAction)cancelDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)newFolder:(id)sender
{
    UIAlertView *createNewAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Create Folder", @"Create Folder string")
                                                                 message:[NSString stringWithFormat:@"%@\n\n\n", NSLocalizedString(@"Folder Name:", @"Folder Name String")]
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel string")
                                                       otherButtonTitles:NSLocalizedString(@"OK", @"OK string"), nil];
    
    newNameTxtFld = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, 245, 28)];
    newNameTxtFld.backgroundColor = [UIColor whiteColor];
    newNameTxtFld.borderStyle = UITextBorderStyleBezel;
    [createNewAlertView addSubview:newNameTxtFld];
    [createNewAlertView show];
    [newNameTxtFld becomeFirstResponder];
}

#pragma mark - UIAlertViewDelegate methods

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != 0)
    {
        if([alertView.title isEqualToString:NSLocalizedString(@"Create Folder", @"Create Folder string")])
        {
            [[self restClient] createFolder:[NSString stringWithFormat:@"%@/%@", currentPath, newNameTxtFld.text]];
        }else if([alertView.title isEqualToString:NSLocalizedString(@"Move or Copy", @"Move or copy string.")])
        {
            CBAppDelegate *appDelegate = (CBAppDelegate *)[[UIApplication sharedApplication] delegate];
            if(buttonIndex == 1)
            { //Move
                [[self restClient] moveFrom:appDelegate.currentFile.path toPath:[self.currentPath stringByAppendingFormat:@"/%@", appDelegate.currentFile.filename]];
            }else if(buttonIndex == 2)
            { //Copy
                [[self restClient] copyFrom:appDelegate.currentFile.path toPath:[self.currentPath stringByAppendingFormat:@"/%@", appDelegate.currentFile.filename]];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)completeReload
{
    [[self restClient] loadMetadata:currentPath];
}

- (IBAction)move:(id)sender
{
    UIAlertView *moveOrCopy = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Move or Copy", @"Move or copy string.")
                                                         message:NSLocalizedString(@"Do you want to move the file or create a copy of it in the specified location?", @"Asking the user if he wants to move the folder or file or make a copy.")
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel string")
                                               otherButtonTitles:NSLocalizedString(@"Move", @"Move string"), NSLocalizedString(@"Copy", @"Copy string"), nil];
    [moveOrCopy show];
}
@end
