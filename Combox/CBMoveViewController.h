//
//  CBMoveViewController.h
//  Combox
//
//  Created by Andrés Ibañez on 8/30/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@class CBSelectNewFolderViewController;

@interface CBMoveViewController : UIViewController <DBRestClientDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    CBSelectNewFolderViewController *containerView;
    DBRestClient *restClient;
    NSMutableArray *foldersArray;
    
    NSIndexPath *lastSelectedIndexPath;
    UITextField *newNameTxtFld;
}

@property(nonatomic, strong) CBSelectNewFolderViewController *containerView;
@property(nonatomic, strong) NSString *currentPath;
@property(nonatomic, strong) NSString *currentFolder;
@property(nonatomic, strong) DBMetadata *currentFile;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)cancelDismiss:(id)sender;
- (IBAction)newFolder:(id)sender;

-(void)completeReload;
- (IBAction)move:(id)sender;
@end