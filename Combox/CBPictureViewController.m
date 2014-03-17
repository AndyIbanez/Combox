//
//  CBPictureViewController.m
//  Combox
//
//  Created by Andrés Ibañez on 9/5/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import "CBPictureViewController.h"

@interface CBPictureViewController ()

@end

@implementation CBPictureViewController
@synthesize pictureScroll;
@synthesize pictureView;
@synthesize saveButton;
@synthesize currentFile;

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
}

-(void)viewDidDisappear:(BOOL)animated
{
    [downloadProgress.view removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"HAI VIEW");
    downloadProgress = [[AIProgressPanel alloc] init];
    [self.parentViewController.view addSubview:downloadProgress.view];
    downloadProgress.imageNameLbl.text = currentFile.filename;
    [downloadProgress.leftLbl removeFromSuperview];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if(orientation == UIInterfaceOrientationLandscapeLeft ||
           orientation == UIInterfaceOrientationLandscapeRight)
        {
            downloadProgress.view.frame = CGRectMake(0, -70, 1024, 70);
            [UIView animateWithDuration:0.2 animations:^{
                downloadProgress.view.frame = CGRectMake(0, 20, 1024, 70);
            }];
        }else
        {
            downloadProgress.view.frame = CGRectMake(0, -70, 768, 70);
            [UIView animateWithDuration:0.2 animations:^{
                downloadProgress.view.frame = CGRectMake(0, 20, 768, 70);
            }];
        }
    }else
    {
        if(orientation == UIInterfaceOrientationLandscapeLeft ||
           orientation == UIInterfaceOrientationLandscapeRight)
        {
            downloadProgress.view.frame = CGRectMake(0, -70, 480, 70);
            [UIView animateWithDuration:0.2 animations:^{
                downloadProgress.view.frame = CGRectMake(0, 20, 480, 70);
            }];
        }else
        {
            downloadProgress.view.frame = CGRectMake(0, -70, 320, 70);
            [UIView animateWithDuration:0.2 animations:^{
                downloadProgress.view.frame = CGRectMake(0, 60, 320, 70);
            }];
        }
    }
    if(currentFile == nil)
    {
        NSLog(@"Current path is nil");
    }
    pictureScroll.minimumZoomScale = 0.0;
    pictureScroll.maximumZoomScale = 2.0;
    saveButton.enabled = false;
    [[self restClient] loadFile:currentFile.path intoPath:[NSTemporaryDirectory() stringByAppendingFormat:@"/%@", currentFile.filename]];
}

- (void)viewDidUnload
{
    [self setPictureScroll:nil];
    [self setPictureView:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)savePicture:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(pictureView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
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

-(void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath
{
    downloadProgress.uploadProgressBar.progress = progress;
    int prog = progress * 100;
    downloadProgress.percentageLbl.text = [NSString stringWithFormat:@"%d %%", prog];
    
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath
{
    pictureView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingFormat:@"/%@", currentFile.filename]]];
    pictureView.frame = CGRectMake(pictureView.frame.origin.x, pictureView.frame.origin.y, pictureView.image.size.width, pictureView.image.size.height);
    pictureScroll.contentSize = CGSizeMake(pictureView.bounds.size.width, pictureView.bounds.size.height);
    saveButton.enabled = YES;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if(orientation == UIInterfaceOrientationLandscapeLeft ||
           orientation == UIInterfaceOrientationLandscapeRight)
        {
            [UIView animateWithDuration:0.2 animations:^{
                downloadProgress.view.frame = CGRectMake(0, -70, 1024, 70);
            }];
        }else
        {
            [UIView animateWithDuration:0.2 animations:^{
                downloadProgress.view.frame = CGRectMake(0, -70, 768, 70);
            }];
        }
    }else
    {
        if(orientation == UIInterfaceOrientationLandscapeLeft ||
           orientation == UIInterfaceOrientationLandscapeRight)
        {
            [UIView animateWithDuration:0.2 animations:^{
                downloadProgress.view.frame = CGRectMake(0, -70, 480, 70);
            }];
        }else
        {
            [UIView animateWithDuration:0.2 animations:^{
                downloadProgress.view.frame = CGRectMake(0, -70, 320, 70);
            }];
        }
    }
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    UIAlertView *uploadFailed = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Download Failed", @"Upload Failed message title")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"OK string")
                                                 otherButtonTitles:nil];
    [uploadFailed show];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [UIView animateWithDuration:0.2 animations:^{
            downloadProgress.view.frame = CGRectMake(0, -70, 768, 70);
        }];
    }else
    {
        [UIView animateWithDuration:0.2 animations:^{
            downloadProgress.view.frame = CGRectMake(0, -70, 480, 70);
        }];
    }
    [downloadProgress.view removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate methods

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return pictureView;
}

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
    {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
    {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else
    {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}

- (void)               image: (UIImage *) image
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo
{
    UIAlertView *saved = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Picture Saved", @"Picture Saved string")
                                                           message:@""
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"OK string")
                                                 otherButtonTitles:nil];
    [saved show];
}
@end
