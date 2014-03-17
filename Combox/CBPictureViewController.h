//
//  CBPictureViewController.h
//  Combox
//
//  Created by Andrés Ibañez on 9/5/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "AIProgressPanel.h"

@interface CBPictureViewController : UIViewController <DBRestClientDelegate, UIScrollViewDelegate>
{
    DBRestClient *restClient;
    AIProgressPanel *downloadProgress;
}

@property(nonatomic, retain) DBMetadata *currentFile;

@property (strong, nonatomic) IBOutlet UIScrollView *pictureScroll;
@property (strong, nonatomic) IBOutlet UIImageView *pictureView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)savePicture:(id)sender;
- (void)               image: (UIImage *) image
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo;
@end
