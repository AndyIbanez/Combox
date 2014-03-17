//
//  CBDropboxViewController.m
//  Combox
//
//  Created by Andrés Ibañez on 8/25/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import "CBDropboxViewController.h"
#import "CBInformationViewController.h"
#import "CBTextEditorViewController.h"
#import "CBPictureViewController.h"

@interface CBDropboxViewController ()

@end

@implementation CBDropboxViewController
@synthesize editNavigationItem;
@synthesize currentFolder;
@synthesize currentPath;
@synthesize currentFile;

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
    currentFolder = self.navigationItem.title;
    if([currentFolder isEqualToString:@"Dropbox"])
    {
        currentPath = [NSMutableString stringWithString:@"/"];
    }
    photosQueue = [[AIQueue alloc] init];
    [[self restClient] loadMetadata:currentPath];
}

- (void)viewDidUnload
{
    [self setEditNavigationItem:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [folderPanel rotationOccured];
    [filePanel rotationOccured];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(photosQueue.shouldProcess)
    {
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
                if(orientation == UIInterfaceOrientationLandscapeLeft ||
                   orientation == UIInterfaceOrientationLandscapeRight)
                {
                    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 634);
                    uploadsProgress.view.frame = CGRectMake(0, 698, 1024, 70);
                }else
                {
                    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 891);
                    uploadsProgress.view.frame = CGRectMake(0, 955, 768, 70);
                }
        }else
        {
            if(orientation == UIInterfaceOrientationLandscapeLeft ||
               orientation == UIInterfaceOrientationLandscapeRight)
            {
                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 198);
                uploadsProgress.view.frame = CGRectMake(0, 250, 480, 70);
            }else
            {
                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 346);
                uploadsProgress.view.frame = CGRectMake(0, 410, 320, 70);
            }
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    /*if(photosQueue.shouldProcess)
    {
        //self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 297);
    }*/
    [self completeReload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [filesArray count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    DBMetadata *file = [filesArray objectAtIndex:indexPath.row];
    if(file.isDirectory)
    {
        static NSString *CellIdentifier = @"folderCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }else
    {
        if([file.filename hasSuffix:@".txt"])
        {
            static NSString *CellIdentifier = @"itemCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }else if([self recognizedFileFormat:file.filename])
        {
            static NSString *CellIdentifier = @"pictureCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }else
        {
            static NSString *CellIdentifier = @"anythingElseCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
    }
    
    UIImageView *icon = (UIImageView *)[cell viewWithTag:20];
    icon.image = [UIImage imageNamed:file.icon];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:10];
    titleLabel.text = file.filename;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lastSelectedIndexPath = indexPath;
    UITableViewCell *selectedCell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    if(selectedCell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        UIAlertView *notSupported = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unsupported File", @"Unsupported file title.")
                                                               message:NSLocalizedString(@"This can't be opened natively with Combox. Your file is being downloaded and you will see a list of apps that support this file type shortly. You can open this file with one of those apps.", @"Description")
                                                              delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Okay string")
                                                     otherButtonTitles:nil];
        [notSupported show];
        //Other file.
        NSString *fileName = ((UILabel *)[selectedCell viewWithTag:10]).text;
        NSString*fullpath = [NSString stringWithFormat:@"%@/%@", currentPath, fileName];
        NSLog(@"%@", fullpath);
        [[self restClient] loadFile:fullpath intoPath:[NSTemporaryDirectory() stringByAppendingFormat:@"%@", fileName]];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBMetadata *fileOrFolder = (DBMetadata *)[filesArray objectAtIndex:indexPath.row];
    NSString *alertViewTitle;
    NSString *alertViewMessage;
    if(fileOrFolder.isDirectory)
    {
        alertViewTitle = NSLocalizedString(@"Delete Folder", @"Delete folder warning message title");
        alertViewMessage = [NSString stringWithFormat:@"%@ %@?", NSLocalizedString(@"This will delete all the files under the folder. Are you sure you want to delete the folder", @"Are you sure you want to delete the folder message."), fileOrFolder.filename];
    }else
    {
        alertViewTitle = NSLocalizedString(@"Delete File", @"Delete file warning message title");
        alertViewMessage = [NSString stringWithFormat:@"%@ %@?", NSLocalizedString(@"Are you sure you want to delete the file", @"Are you sure you want to delete the folder message."), fileOrFolder.filename];
    }
    UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:alertViewTitle
                                                message:alertViewMessage
                                                delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel string")
                                                otherButtonTitles:NSLocalizedString(@"OK", @"OK string"), nil];
    [confirm show];
    lastSelectedIndexPath = indexPath;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    lastSelectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"informationViewSegue" sender:[self tableView:tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - UIStoryboard Methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *selectedCell = (UITableViewCell *)sender;
    UILabel *theFolderName = (UILabel *)[selectedCell viewWithTag:10];
    currentFolder = theFolderName.text;
    UIViewController *receiver;
    if([segue.identifier isEqualToString:@"folderSegue"])
    {
        receiver = (CBDropboxViewController *)segue.destinationViewController;
        [receiver performSelector:@selector(setCurrentPath:) withObject:[NSString stringWithFormat:@"%@/%@", currentPath, currentFolder]];
    }else if([segue.identifier isEqualToString:@"informationViewSegue"])
    {
        receiver = (CBInformationViewController *)segue.destinationViewController;
        [receiver performSelector:@selector(setCurrentFolder:) withObject:currentFolder];
        DBMetadata *file = [filesArray objectAtIndex:lastSelectedIndexPath.row];
        [receiver performSelector:@selector(setCurrentFile:) withObject:file];
        [receiver performSelector:@selector(setCurrentPath:) withObject:[NSString stringWithFormat:@"%@/%@", currentPath, currentFolder]];
    }else if([segue.identifier isEqualToString:@"itemSegue"])
    {
        //WORK AROUND. I was going to rely on lastSelectedIndex to fetch me the right file from the array,
        //but since I figured that cellForRowAtIndexPath gets called AFTER prepareForSegue, I can't do it.
        //Instead, I will have to search for the right file based on name.
        int index;
        NSString *filenameToSearch = ((UILabel *)[((UITableViewCell *)sender) viewWithTag:10]).text;
        for(index = 0; index < [filesArray count]; index++)
        {
            DBMetadata *currentItem = [filesArray objectAtIndex:index];
            if([currentItem.filename isEqualToString:filenameToSearch])
            {
                break;
            }
        }
        DBMetadata *file = [filesArray objectAtIndex:index];
        receiver = (CBTextEditorViewController *)segue.destinationViewController;
        [receiver performSelector:@selector(setCurrentFile:) withObject:file];
        [receiver performSelector:@selector(setCurrentPath:) withObject:currentPath];
    }else if([segue.identifier isEqualToString:@"pictureSegue"])
    {
        int index;
        NSString *filenameToSearch = ((UILabel *)[((UITableViewCell *)sender) viewWithTag:10]).text;
        for(index = 0; index < [filesArray count]; index++)
        {
            DBMetadata *currentItem = [filesArray objectAtIndex:index];
            if([currentItem.filename isEqualToString:filenameToSearch])
            {
                break;
            }
        }
        DBMetadata *file = [filesArray objectAtIndex:index];
        receiver = (CBPictureViewController *)segue.destinationViewController;
        [receiver performSelector:@selector(setCurrentFile:) withObject:file];
    }
    
    receiver.navigationItem.title = currentFolder;
}

/*-(void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
}*/

#pragma mark - This method's stuff

- (IBAction)putTableInEditMode:(id)sender
{
    if(!self.tableView.editing)
    {
        [self setEditing:YES animated:YES];
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(putTableInEditMode:)];
        self.navigationItem.rightBarButtonItem = done;
        UIBarButtonItem *create = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewItem)];
        self.navigationItem.leftBarButtonItem = create;
    }else
    {
        [self setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = editNavigationItem;
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)createNewItem
{
    UIActionSheet *createNewActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"What do you want to do?", @"What do you want to do? text in UIActionSheet")
                                                                      delegate:self
                                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel string")
                                                                      destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Create New Folder", @"Create new folder string"),
                                                                                                                   NSLocalizedString(@"Create New Text File", @"Create New Text File string"),
                                                                                                                   NSLocalizedString(@"Upload A Picture", @"Upload A Picture string"), nil];
    [createNewActionSheet showInView:self.tableView.window];
    
}

- (void)completeReload //This method reloads EVERYTHING: Just calling reloadData won't recreate the table with the new files and folders.
{
    [[self restClient] loadMetadata:currentPath];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([actionSheet.title isEqualToString:NSLocalizedString(@"What do you want to do?", @"What do you want to do? text in UIActionSheet")])
    {
        if(buttonIndex == UICreateActionNewFolder)
        {
            folderPanel = [[AITinyPanel alloc] init];
            folderPanel.destinyView = self.parentViewController.parentViewController.view;
            folderPanel.delegate = self;
            [folderPanel showView];
            folderPanel.titleLabel.text = NSLocalizedString(@"Create Folder", @"Create Folder string");
            folderPanel.iconImage.image = [UIImage imageNamed:@"folder"];
        }else if(buttonIndex == UICreateActionNewFile)
        {
            filePanel = [[AITinyPanel alloc] init];
            filePanel.destinyView = self.parentViewController.parentViewController.view;
            filePanel.delegate = self;
            [filePanel showView];
            filePanel.titleLabel.text = NSLocalizedString(@"Create File", @"Create Folder string");
            filePanel.iconImage.image = [UIImage imageNamed:@"page_white_text"];
        }else if(buttonIndex == UICreateActionUploadPicture)
        {
            UIImagePickerController *chooseMediaToUpload = [[UIImagePickerController alloc] init];
            chooseMediaToUpload.delegate = self;
            chooseMediaToUpload.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                popover = [[UIPopoverController alloc] initWithContentViewController:chooseMediaToUpload];
                [popover presentPopoverFromRect:CGRectMake(30, 30, 30, 30) inView:self.parentViewController.parentViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }else
            {
                [self presentViewController:chooseMediaToUpload animated:YES completion:nil];
            }
        }
    }
}

#pragma mark = UIImagePickerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *imageToUpload = [info objectForKey:UIImagePickerControllerOriginalImage];
        
    NSDate *dateForPictureName = [NSDate date];
    NSTimeInterval timeInterval = [dateForPictureName timeIntervalSince1970];
    NSMutableString *fileName = [NSMutableString stringWithFormat:@"%f", timeInterval];
    NSRange thePeriod = [fileName rangeOfString:@"."]; //Epoch returns with a period for some reason.
    [fileName deleteCharactersInRange:thePeriod];
    [fileName appendString:@".jpeg"];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(imageToUpload, 1.0)];
    [imageData writeToFile:filePath atomically:YES];
    
    [photosQueue addObject:fileName];
    if(!photosQueue.shouldProcess)
    {
        if(uploadsProgress == nil)
        {
            uploadsProgress =[[AIProgressPanel alloc] init];
        }
        [self.parentViewController.parentViewController.view addSubview:uploadsProgress.view];
        uploadsProgress.imageNameLbl.text = fileName;
        uploadsProgress.imageThumbnail.image = [UIImage imageWithData:imageData];
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            if(orientation == UIInterfaceOrientationLandscapeLeft ||
               orientation == UIInterfaceOrientationLandscapeRight)
            {
                uploadsProgress.view.frame = CGRectMake(0, 838, 1024, 70);
                [UIView animateWithDuration:0.2 animations:^{
                    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 634);
                    uploadsProgress.view.frame = CGRectMake(0, 698, 1024, 70);
                }];
            }else
            {
                uploadsProgress.view.frame = CGRectMake(0, 1094, 768, 70);
                [UIView animateWithDuration:0.2 animations:^{
                    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 891);
                    uploadsProgress.view.frame = CGRectMake(0, 955, 768, 70);
                }];
            }
        }else
        {
            if(orientation == UIInterfaceOrientationLandscapeLeft ||
               orientation == UIInterfaceOrientationLandscapeRight)
            {
                uploadsProgress.view.frame = CGRectMake(0, 550, 480, 70);
                [UIView animateWithDuration:0.2 animations:^{
                    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 198);
                    uploadsProgress.view.frame = CGRectMake(0, 250, 480, 70);
                }];
            }else
            {
                uploadsProgress.view.frame = CGRectMake(0, 550, 320, 70);
                [UIView animateWithDuration:0.2 animations:^{
                    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 346);
                uploadsProgress.view.frame = CGRectMake(0, 410, 320, 70);
                }];
            }
        }
        photosQueue.shouldProcess = YES;
        [[self restClient] uploadFile:fileName toPath:currentPath withParentRev:nil fromPath:filePath];
    }
    uploadsProgress.leftLbl.text = [NSString stringWithFormat:@"%d left", photosQueue.count];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != 0)
    {
        //Delete files and folders
        if([alertView.title isEqualToString:NSLocalizedString(@"Delete Folder", @"Delete folder warning message title")] ||
           [alertView.title isEqualToString:NSLocalizedString(@"Delete File", @"Delete file warning message title")])
        {
            DBMetadata *fileToDelete = (DBMetadata *)[filesArray objectAtIndex:lastSelectedIndexPath.row];
            [[self restClient] deletePath:fileToDelete.path];
            [filesArray removeObjectAtIndex:lastSelectedIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:lastSelectedIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

#pragma mark - DBRestClientDelegate methods

- (DBRestClient *)restClient {
    if (!restClient && [DBSession sharedSession].isLinked) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    if([metadata.filename hasSuffix:@".txt"])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Text File Created Succesfully", @"New text file created succesfully message.")
                                                     message:NSLocalizedString(@"The new text file has been created succesfully", @"New textfile created succesfully message body.")
                                                    delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"OK", @"OK string.")
                                           otherButtonTitles:nil];
        [av show];
    }else
    {
        [photosQueue removeFirstObject];
        if(photosQueue.shouldProcess)
        {
            NSString *completePath = [NSTemporaryDirectory() stringByAppendingFormat:@"/%@", [photosQueue nextObject]];
            uploadsProgress.imageNameLbl.text = [photosQueue nextObject];
            uploadsProgress.imageThumbnail.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:completePath]];
            [[self restClient] uploadFile:[photosQueue nextObject] toPath:self.currentPath withParentRev:nil fromPath:completePath];
        }else
        {
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                if(orientation == UIInterfaceOrientationLandscapeLeft ||
                   orientation == UIInterfaceOrientationLandscapeRight)
                {
                    [UIView animateWithDuration:0.2 animations:^{
                        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 655);
                        uploadsProgress.view.frame = CGRectMake(0, 838, 1024, 70);
                    }];
                }else
                {
                    [UIView animateWithDuration:0.2 animations:^{
                        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 911);
                        uploadsProgress.view.frame = CGRectMake(0, 1094, 768, 70);
                    }];
                }
            }else
            {
                if(orientation == UIInterfaceOrientationLandscapeLeft ||
                   orientation == UIInterfaceOrientationLandscapeRight)
                {
                    [UIView animateWithDuration:0.2 animations:^{
                        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 219);
                        uploadsProgress.view.frame = CGRectMake(0, 550, 480, 70);
                    }];
                }else
                {
                    [UIView animateWithDuration:0.2 animations:^{
                        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 367);
                        uploadsProgress.view.frame = CGRectMake(0, 550, 320, 70);
                    }];
                }
            }
        }
        uploadsProgress.leftLbl.text = [NSString stringWithFormat:@"%d left", photosQueue.count];
        uploadsProgress.percentageLbl.text = @"0 %";
        uploadsProgress.uploadProgressBar.progress = 0.0;
    }
    [self completeReload];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    UIAlertView *uploadFailed = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uoload Failed", @"Upload Failed message title")
                                                     message:error.localizedDescription
                                                    delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"OK", @"OK string")
                                           otherButtonTitles:nil];
    [uploadFailed show];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    filesArray = [NSMutableArray arrayWithArray:metadata.contents];
    [self.tableView reloadData];
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    UIAlertView *metadata = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed To Load Metadata", @"Failed To Load Metadata message title.")
                                                     message:error.localizedDescription
                                                    delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"OK", @"OK string")
                                           otherButtonTitles:nil];
    [metadata show];
}

// Folder is the metadata for the newly created folder
- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Folder Created Succesfully", @"Folder created succesfully message title.")
                                                 message:NSLocalizedString(@"The new folder has been created succesfully.", @"New folder created succesfully message body.")
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK string.")
                                       otherButtonTitles:nil];
    [av show];
    [self completeReload];
}

// [error userInfo] contains the root and path
- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could Not Create Folder", @"Could Not Create Folder message title.")
                                                 message:error.localizedDescription
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK string.")
                                       otherButtonTitles:nil];
    [av show];
}

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path
{
    [self completeReload];
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error
{
    UIAlertView *delete = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed To Delete Path", @"Failed To Delete Path message title")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"OK string")
                                                 otherButtonTitles:nil];
    [delete show];
}

-(void)restClient:(DBRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath
{
    uploadsProgress.uploadProgressBar.progress = progress;
    int prog = progress * 100;
    uploadsProgress.percentageLbl.text = [NSString stringWithFormat:@"%d %%", prog];
}

-(BOOL)recognizedFileFormat:(NSString *)aFileName
{
    NSMutableString *fileName = (NSMutableString *)[[NSMutableString stringWithString:aFileName] lowercaseString];
    if([fileName hasSuffix:@".cur"] ||
       [fileName hasSuffix:@".ico"] ||
       [fileName hasSuffix:@".bmp"] ||
       [fileName hasSuffix:@".bpmf"] ||
       [fileName hasSuffix:@".png"] ||
       [fileName hasSuffix:@".gif"] ||
       [fileName hasSuffix:@".tif"] ||
       [fileName hasSuffix:@".tiff"] ||
       [fileName hasSuffix:@".xbm"] ||
       [fileName hasSuffix:@".jpg"] ||
       [fileName hasSuffix:@".jpeg"]
       )
    {
        return YES;
    }
    return NO;
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath
{
    documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:destPath]];
    documentController.delegate = self;
    [documentController presentOpenInMenuFromRect:CGRectZero inView:self.parentViewController.parentViewController.view animated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark - AITinyPanelDelegate methods

-(void)tinyPanelWasCancelled:(AITinyPanel *)panel
{
    [panel dismissView];
}

-(void)tinyPanel:(AITinyPanel *)panel acceptedWithString:(NSString *)string
{
    if(panel == folderPanel)
    {
        [[self restClient] createFolder:[NSString stringWithFormat:@"%@/%@", currentPath, string]];
    }else if(panel == filePanel)
    {
        NSMutableString *fileName = [NSMutableString stringWithString:string];
        if(![fileName hasSuffix:@".txt"])
        {
            [fileName appendString:@".txt"];
        }
        //Create temporary file
        [[NSFileManager defaultManager] createFileAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName] contents:nil attributes:nil];
        NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        // And upload it.
        [[self restClient] uploadFile:fileName toPath:currentPath withParentRev:nil fromPath:localPath];
    }
    [panel dismissView];
}

#pragma mark - AIQueueDelegate methods

-(void)objectHasBeenRemoved
{
    
}

-(void)objectHasBeenAdded:(id)object
{
    
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application
{
    
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application
{
    
}

-(void)documentInteractionControllerDidDismissOpenInMenu:
(UIDocumentInteractionController *)controller
{
    
}

@end
