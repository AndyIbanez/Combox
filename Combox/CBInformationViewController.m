//
//  CBInformationViewController.m
//  Combox
//
//  Created by Andrés Ibañez on 8/26/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import "CBInformationViewController.h"
#import "CBFileRevisionsViewController.h"
#import "CBMoveViewController.h"
#import "CBAppDelegate.h"

@interface CBInformationViewController ()

@end

@implementation CBInformationViewController
@synthesize currentFolder;
@synthesize currentPath;
@synthesize previousPath;
@synthesize currentFile;
@synthesize fileNameTxtFld;
@synthesize iconImage;
@synthesize creationDateLbl;
@synthesize filesizeLbl;
@synthesize revisionLbl;
@synthesize locationLbl;

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
    self.fileNameTxtFld.text = currentFile.filename;
    iconImage.image = [UIImage imageNamed:currentFile.icon];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateStyle = NSDateFormatterLongStyle;
    creationDateLbl.text = [dateFormat stringFromDate:currentFile.lastModifiedDate];
    filesizeLbl.text = currentFile.humanReadableSize;
    revisionLbl.text = currentFile.rev;
    locationLbl.text = currentFile.path;
}

- (void)viewDidUnload
{
    [self setFileNameTxtFld:nil];
    [self setIconImage:nil];
    [self setCreationDateLbl:nil];
    [self setFilesizeLbl:nil];
    [self setRevisionLbl:nil];
    [self setLocationLbl:nil];
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

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"revisionsSegue"])
    {
        CBFileRevisionsViewController *receiver = (CBFileRevisionsViewController *)segue.destinationViewController;
        receiver.file = currentFile;
    }
    else
    {
        //CBMoveViewController *receiver = (CBMoveViewController *)segue.destinationViewController;
        CBAppDelegate *appDelegate = (CBAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.currentFile = currentFile;
    }
}

#pragma mark - Table view data source

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 2)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if(indexPath.row == 0)
        {
            //Open With Another App
            [[self restClient] loadFile:currentFile.path intoPath:[NSTemporaryDirectory() stringByAppendingFormat:@"/%@", currentFile.filename]];
        }else if(indexPath.row == 1)
        {
            shouldMail = YES;
            [[self restClient] loadSharableLinkForFile:currentFile.path];
        }else if(indexPath.row == 2)
        {
            //Copy link to pasteboard.
            shouldMail = NO;
            [[self restClient] loadSharableLinkForFile:currentFile.path];
        }
    }
}

- (IBAction)dismissKeyboard:(id)sender
{
    [fileNameTxtFld resignFirstResponder];
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

#pragma mark - rest client stuff

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath
{
    //This method is only called when "open in" is selected in the second alert sheet.
    documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:destPath]];
    documentController.delegate = self;
    [documentController presentOpenInMenuFromRect:CGRectZero inView:self.parentViewController.parentViewController.view animated:YES];
}

-(void)restClient:(DBRestClient *)restClient loadedSharableLink:(NSString *)link forFile:(NSString *)path
{
    if(shouldMail)
    {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:currentFile.filename];
        [mailComposer setMessageBody:link isHTML:NO];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }else
    {
        UIPasteboard *thePasteboard = [UIPasteboard generalPasteboard];
        thePasteboard.string = link;
        UIAlertView *copiedMessage = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Copy Link", @"Copy Link string")
                                                                message:NSLocalizedString(@"The link has been succesfully copied to your clipboard.", @"The link has been succesfully copied to your clipboard string")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK string")
                                                      otherButtonTitles:nil];
        [copiedMessage show];
    }
}

- (void)restClient:(DBRestClient *)restClient loadSharableLinkFailedWithError:(NSError *)error
{
    UIAlertView *loadSharable = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed To Get Sharable Link", @"Failed To Get Sharable Link message title.")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"OK string")
                                                 otherButtonTitles:nil];
    [loadSharable show];
}

#pragma mark - MFMailComposeViewControllerDelegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
