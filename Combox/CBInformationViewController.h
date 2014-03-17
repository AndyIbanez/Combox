//
//  CBInformationViewController.h
//  Combox
//
//  Created by Andrés Ibañez on 8/26/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBMoveViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import <MessageUI/MessageUI.h>

@class DBMetadata;

@interface CBInformationViewController : UITableViewController <UIDocumentInteractionControllerDelegate, DBRestClientDelegate, MFMailComposeViewControllerDelegate>
{
    DBRestClient *restClient;
    UIDocumentInteractionController *documentController;
    BOOL shouldMail;
}
@property(nonatomic, strong) NSString *currentFolder;
@property(nonatomic, strong) NSString *currentPath;
@property(nonatomic, strong) NSString *previousPath;
@property(nonatomic, strong) DBMetadata *currentFile;


@property (strong, nonatomic) IBOutlet UITextField *fileNameTxtFld;
@property (strong, nonatomic) IBOutlet UIImageView *iconImage;
@property (strong, nonatomic) IBOutlet UILabel *creationDateLbl;
@property (strong, nonatomic) IBOutlet UILabel *filesizeLbl;
@property (strong, nonatomic) IBOutlet UILabel *revisionLbl;
@property (strong, nonatomic) IBOutlet UILabel *locationLbl;

- (IBAction)dismissKeyboard:(id)sender;

@end
