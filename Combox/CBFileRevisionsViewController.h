//
//  CBFileRevisionsViewController.h
//  Combox
//
//  Created by Andrés Ibañez on 8/28/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "CBMoveViewController.h"

@interface CBFileRevisionsViewController : UITableViewController <DBRestClientDelegate, UIAlertViewDelegate>
{
    DBRestClient *restClient;
    NSArray *fileRevisions;
}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property(strong, nonatomic) DBMetadata *file;

- (IBAction)doneAction:(id)sender;
@end
