//
//  AIProgressPanel.m
//  Combox
//
//  Created by Andrés Ibañez on 9/4/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import "AIProgressPanel.h"

@interface AIProgressPanel ()

@end

@implementation AIProgressPanel
@synthesize leftLbl;
@synthesize imageNameLbl;
@synthesize imageThumbnail;
@synthesize uploadProgressBar;
@synthesize percentageLbl;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setLeftLbl:nil];
    [self setImageNameLbl:nil];
    [self setImageThumbnail:nil];
    [self setUploadProgressBar:nil];
    [self setPercentageLbl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
