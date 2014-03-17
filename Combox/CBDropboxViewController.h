//
//  CBDropboxViewController.h
//  Combox
//
//  Created by Andrés Ibañez on 8/25/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import <MessageUI/MessageUI.h>
#import "AITinyPanel.h"
#import "AIQueue.h"
#import "AIProgressPanel.h"

typedef enum
{
    UICreateActionNewFolder,
    UICreateActionNewFile,
    UICreateActionUploadPicture
} UICreateAction;

@interface CBDropboxViewController : UITableViewController <DBRestClientDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, AITinyPanelDelegate, AIQueueDelegate, UIDocumentInteractionControllerDelegate>
{
    DBRestClient *restClient;
    NSMutableArray *filesArray;
    NSMutableString *currentPath;
    
    NSIndexPath *lastSelectedIndexPath;
    
    AITinyPanel *folderPanel;
    AITinyPanel *filePanel;
    AIProgressPanel *uploadsProgress;
    
    AIQueue *photosQueue;
    
    UIPopoverController __strong *popover;
    UIDocumentInteractionController *documentController;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editNavigationItem;

@property(nonatomic, strong) DBMetadata *currentFile;

@property(nonatomic, strong) NSString *currentFolder;
@property(nonatomic, strong) NSString *currentPath;

- (IBAction)putTableInEditMode:(id)sender;

- (void)createNewItem;
- (void)completeReload;
-(BOOL)recognizedFileFormat:(NSString *)fileName;
@end