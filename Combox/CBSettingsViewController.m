//
//  CBSettingsViewController.m
//  Combox
//
//  Created by Andrés Ibañez on 9/5/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import "CBSettingsViewController.h"

@interface CBSettingsViewController ()

@end

@implementation CBSettingsViewController
@synthesize countryLbl;
@synthesize usernameLbl;
@synthesize normalBytesLbl;
@synthesize sharedBytesLbl;
@synthesize totalBytesLbl;
@synthesize capacityLbl;

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
    countryLbl.text = @"";
    usernameLbl.text = @"";
    normalBytesLbl.text = @"";
    sharedBytesLbl.text = @"";
    totalBytesLbl.text = @"";
    capacityLbl.text = @"";
    [[self restClient] loadAccountInfo];
}

- (void)viewDidUnload
{
    [self setCountryLbl:nil];
    [self setUsernameLbl:nil];
    [self setNormalBytesLbl:nil];
    [self setSharedBytesLbl:nil];
    [self setTotalBytesLbl:nil];
    [self setCapacityLbl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Unlink Account?", @"Unlink Account string")
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel string")
                                                       destructiveButtonTitle:NSLocalizedString(@"Unlink Account", @"Unlink Account string")
                                                            otherButtonTitles:nil];
            [actionSheet showInView:self.parentViewController.parentViewController.view];
        }
    }
}

#pragma mark - DBRestClient stuff

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info
{
    countryLbl.text = info.country;
    usernameLbl.text = info.displayName;
    normalBytesLbl.text = [NSString stringWithFormat:@"%lld bytes", info.quota.normalConsumedBytes];
    sharedBytesLbl.text = [NSString stringWithFormat:@"%lld bytes", info.quota.sharedConsumedBytes];
    totalBytesLbl.text = [NSString stringWithFormat:@"%lld bytes", info.quota.totalConsumedBytes];
    capacityLbl.text = [NSString stringWithFormat:@"%lld bytes", info.quota.totalBytes];
    [self.tableView reloadData];
    
}

-(void)restClient:(DBRestClient *)client loadAccountInfoFailedWithError:(NSError *)error
{
    if([DBSession sharedSession].isLinked)
    {
        UIAlertView *failed = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed To Load Account Info","failed to load account info string")
                                                        message:error.localizedDescription
                                                        delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK string")
                                            otherButtonTitles:nil];
        [failed show];
    }
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [[DBSession sharedSession] unlinkAll];
        [[DBSession sharedSession] linkFromController:self];
    }
}

@end
