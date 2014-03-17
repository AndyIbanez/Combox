//
//  CBTextEditorViewController.h
//  Combox
//
//  Created by Andrés Ibañez on 9/1/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface CBTextEditorViewController : UIViewController <DBRestClientDelegate>
{
    DBRestClient *restClient;
}

@property (nonatomic, strong) DBMetadata *currentFile;
@property (nonatomic, strong) NSString *currentPath;

@property (strong, nonatomic) IBOutlet UITextView *noteTextArea;

- (IBAction)saveNewText:(id)sender;

-(void)keyboardWillShow;
-(void)keyboardWillHide;
@end
