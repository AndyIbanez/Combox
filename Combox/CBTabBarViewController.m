//
//  CBTabBarViewController.m
//  Combox
//
//  Created by Andrés Ibañez on 8/25/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import "CBTabBarViewController.h"
#import "CBAppDelegate.h"

@interface CBTabBarViewController ()

@end

@implementation CBTabBarViewController
@synthesize currentFile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (![[DBSession sharedSession] isLinked]) {
        CBAppDelegate *appDelegate = (CBAppDelegate *)[UIApplication sharedApplication].delegate;
        [[DBSession sharedSession] linkFromController:[[appDelegate window] rootViewController]];
        self.selectedIndex = 1;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId
{
    relinkUserId = userId;
	[[[UIAlertView alloc]
      initWithTitle:NSLocalizedString(@"Dropbox Session Ended", @"Dropbox session ended string") message:NSLocalizedString(@"Do you want to relink?", @"Do you want to relink message") delegate:self
      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel string") otherButtonTitles:NSLocalizedString(@"Relink", @"relink string"), nil]
	 show];
}

#pragma mark -
 #pragma mark UIAlertViewDelegate methods
 
 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
     if (index != alertView.cancelButtonIndex)
     {
         [[DBSession sharedSession] linkUserId:relinkUserId fromController:self];
     }
     relinkUserId = nil;
 }


#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
	outstandingRequests++;
	if (outstandingRequests == 1) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)networkRequestStopped {
	outstandingRequests--;
	if (outstandingRequests == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

@end
