//
//  CBTextEditorViewController.m
//  Combox
//
//  Created by Andrés Ibañez on 9/1/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import "CBTextEditorViewController.h"

@interface CBTextEditorViewController ()

@end

@implementation CBTextEditorViewController
@synthesize currentFile;
@synthesize noteTextArea;
@synthesize currentPath;

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
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[self restClient] loadFile:currentFile.path intoPath:[NSTemporaryDirectory() stringByAppendingFormat:@"/%@", currentFile.filename]];
}

- (void)viewDidUnload
{
    [self setNoteTextArea:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
    {
        if([self interfaceOrientation] == UIInterfaceOrientationLandscapeLeft ||
           [self interfaceOrientation] == UIInterfaceOrientationLandscapeRight)
        {
            noteTextArea.frame = CGRectMake(noteTextArea.frame.origin.x, noteTextArea.frame.origin.y, noteTextArea.frame.size.width, 248);
        }else
        {
            noteTextArea.frame = CGRectMake(noteTextArea.frame.origin.x, noteTextArea.frame.origin.y, noteTextArea.frame.size.width, 367);
        }
    }
}

- (IBAction)saveNewText:(id)sender
{
    [noteTextArea resignFirstResponder];
    NSError *writingError = nil;
    [noteTextArea.text writeToFile:[NSTemporaryDirectory() stringByAppendingFormat:@"/%@", currentFile.filename]
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:&writingError];
    
    if(writingError == nil)
    {
        //[[self restClient] deletePath:currentFile.path];
        [[self restClient] uploadFile:currentFile.filename
                               toPath:currentPath
                        withParentRev:currentFile.rev
                             fromPath:[NSTemporaryDirectory() stringByAppendingFormat:@"/%@", currentFile.filename]];
    }else
    {
         NSLog(@"Couldn't write to file: %@", writingError);
    }
}

#pragma mark - DBRestClient stuff

- (DBRestClient *)restClient
{
    if (!restClient)
    {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
    //Once the file is downloaded, we need to open it.
    NSError *errorOfFile = nil;
    NSString *contentsOfFile = [[NSString alloc] initWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingFormat:@"/%@", currentFile.filename]
                                                               encoding:NSUTF8StringEncoding
                                                                  error:&errorOfFile];
    if(errorOfFile == nil)
    {
        noteTextArea.text = contentsOfFile;
    }else
    {
        NSLog(@"Couldn't open file: %@", errorOfFile.localizedFailureReason);
    }
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    NSLog(@"%@", error);
}
         
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
                    from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}
         
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSLog(@"File upload failed with error - %@", error);
}

#pragma mark - This file's methods.

-(void)keyboardWillHide
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if([self interfaceOrientation] == UIInterfaceOrientationLandscapeLeft ||
           [self interfaceOrientation] == UIInterfaceOrientationLandscapeRight)
        {
            [UIView animateWithDuration:0.2f animations:^{
                noteTextArea.frame = CGRectMake(noteTextArea.frame.origin.x, noteTextArea.frame.origin.y, noteTextArea.frame.size.width, 655);
            }];
        }else
        {
            [UIView animateWithDuration:0.2f animations:^{
                noteTextArea.frame = CGRectMake(noteTextArea.frame.origin.x, noteTextArea.frame.origin.y, noteTextArea.frame.size.width, 911);
            }];
        }
    }else
    {
        if([self interfaceOrientation] == UIInterfaceOrientationLandscapeLeft ||
           [self interfaceOrientation] == UIInterfaceOrientationLandscapeRight)
        {
            [UIView animateWithDuration:0.2f animations:^{
                noteTextArea.frame = CGRectMake(noteTextArea.frame.origin.x, noteTextArea.frame.origin.y, noteTextArea.frame.size.width, 248);
            }];
        }else
        {
            [UIView animateWithDuration:0.2f animations:^{
                noteTextArea.frame = CGRectMake(noteTextArea.frame.origin.x, noteTextArea.frame.origin.y, noteTextArea.frame.size.width, 367);
            }];
        }
    }
}

-(void)keyboardWillShow
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if([self interfaceOrientation] == UIInterfaceOrientationLandscapeLeft ||
           [self interfaceOrientation] == UIInterfaceOrientationLandscapeRight)
        {
            NSLog(@"%f %f", noteTextArea.frame.size.height, noteTextArea.frame
                  .size.width);
            [UIView animateWithDuration:0.2f animations:^{
                noteTextArea.frame = CGRectMake(noteTextArea.frame.origin.x, noteTextArea.frame.origin.y, noteTextArea.frame.size.width, 352);
            }];
        }else
        {
            [UIView animateWithDuration:0.2f animations:^{
                noteTextArea.frame = CGRectMake(noteTextArea.frame.origin.x, noteTextArea.frame.origin.y, noteTextArea.frame.size.width, 698);
            }];
        }
    }else
    {
        if([self interfaceOrientation] == UIInterfaceOrientationLandscapeLeft ||
           [self interfaceOrientation] == UIInterfaceOrientationLandscapeRight)
        {
            [UIView animateWithDuration:0.2f animations:^{
                noteTextArea.frame = CGRectMake(noteTextArea.frame.origin.x, noteTextArea.frame.origin.y, noteTextArea.frame.size.width, 113);
            }];
        }else
        {
            [UIView animateWithDuration:0.2f animations:^{
                noteTextArea.frame = CGRectMake(noteTextArea.frame.origin.x, noteTextArea.frame.origin.y, noteTextArea.frame.size.width, (noteTextArea.frame.size.height / 2) + 16);
            }];
        }
    }
}

@end
