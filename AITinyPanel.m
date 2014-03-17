//
//  AITinyPanel.m
//  Combox
//
//  Created by Andrés Ibañez on 9/2/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import "AITinyPanel.h"

@interface AITinyPanel ()

@end

@implementation AITinyPanel
@synthesize destinyView;
@synthesize panelView;
@synthesize titleLabel;
@synthesize iconImage;
@synthesize buttonsView;
@synthesize contentTextView;
@synthesize cancelButton;
@synthesize okButton;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(void)rotationOccured
{
    CGRect windowRect = [[[UIApplication sharedApplication] keyWindow] rootViewController].view.bounds;
    float posXPanelView = (windowRect.size.width / 2) - (panelView.frame.size.width / 2);
    panelView.frame = CGRectMake(posXPanelView, panelView.frame.origin.y, panelView.frame.size.width, panelView.frame.size.height);
    float posXButtonsView = (windowRect.size.width / 2) - (panelView.frame.size.width / 2);
    //WORKAROUND. For some bizarre reason, the keyboard has a y-coordinate of 0 (it really shouldn't) when the device is in landscape mode. So for this I need to check the rotation to know what opeartion to do
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    float posYPanelView;
    if(orientation == UIInterfaceOrientationLandscapeLeft ||
       orientation == UIInterfaceOrientationLandscapeRight)
    {
        posYPanelView = keyboardRect.origin.x - buttonsView.frame.size.height;
    }else
    {
        posYPanelView = keyboardRect.origin.y - buttonsView.frame.size.height;
    }

    NSLog(@"LOL %f, %f - %f", keyboardRect.origin.x, keyboardRect.origin.y, posYPanelView);
    buttonsView.frame = CGRectMake(posXButtonsView, posYPanelView, buttonsView.frame.size.width, buttonsView.frame.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake([[UIScreen mainScreen] bounds].origin.x, [[UIScreen mainScreen] bounds].origin.x, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangedFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setPanelView:nil];
    [self setTitleLabel:nil];
    [self setIconImage:nil];
    [self setContentTextView:nil];
    [self setButtonsView:nil];
    [self setCancelButton:nil];
    [self setOkButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)showView
{
    if([delegate respondsToSelector:@selector(tinyPanelWillShow:)])
    {
        [delegate performSelector:@selector(tinyPanelWillShow:) withObject:self];
    }
    CGRect windowRect = [[UIScreen mainScreen] applicationFrame];
    [destinyView addSubview:self.view];
    [destinyView.superview addSubview:panelView];
    [destinyView.superview addSubview:buttonsView];
    panelView.frame = CGRectMake(0, -80, panelView.frame.size.width, panelView.frame.size.height);
    buttonsView.frame = CGRectMake(-buttonsView.frame.size.width, windowRect.size.height / 2, buttonsView.frame.size.width, buttonsView.frame.size.height);
    __block float posy;
    [UIView animateWithDuration:0.1
                     animations:^{
                         [contentTextView becomeFirstResponder];
                         float posXPanelView = (windowRect.size.width / 2) - (panelView.frame.size.width / 2);
                         panelView.frame = CGRectMake(posXPanelView, 0, panelView.frame.size.width, panelView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         float posXButtonsView = (windowRect.size.width / 2) - (panelView.frame.size.width / 2);
                         UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
                         if(orientation == UIInterfaceOrientationLandscapeLeft ||
                            orientation == UIInterfaceOrientationLandscapeRight)
                         {
                             posy = keyboardRect.origin.x - buttonsView.frame.size.height;
                         }else
                         {
                             posy = keyboardRect.origin.y - buttonsView.frame.size.height;
                         }
                         [UIView animateWithDuration:0.1
                                          animations:^{
                                              buttonsView.frame = CGRectMake(posXButtonsView, posy, buttonsView.frame.size.width, buttonsView.frame.size.height);
                                          }
                          ];
                     }];

}

-(void)dismissView
{
    if([delegate respondsToSelector:@selector(tinyPanelWillDismiss:)])
    {
        [delegate performSelector:@selector(tinyPanelWillDismiss:) withObject:self];
    }
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if(orientation == UIInterfaceOrientationLandscapeLeft ||
           orientation == UIInterfaceOrientationLandscapeRight)
        {
            [UIView animateWithDuration:0.1
                             animations:^{
                                 buttonsView.frame = CGRectMake(-320, 373, 320, 44);
                             }
                             completion:^(BOOL finished){
                                 if(finished)
                                 {
                                     [contentTextView resignFirstResponder];
                                     [buttonsView removeFromSuperview];
                                     [UIView animateWithDuration:0.1
                                                      animations:^{
                                                          panelView.frame = CGRectMake(350, -80, 320, 100);
                                                      }
                                                      completion:^(BOOL finished){
                                                          if(finished)
                                                          {
                                                              [panelView removeFromSuperview];
                                                              [self.view removeFromSuperview];
                                                              if([delegate respondsToSelector:@selector(tinyPanelDidDismiss:)])
                                                              {
                                                                  [delegate performSelector:@selector(tinyPanelDidDismiss:) withObject:self];
                                                              }
                                                          }
                                                      }];
                                 }
                             }];
        }else
        {
            [UIView animateWithDuration:0.1
                            animations:^{
                                buttonsView.frame = CGRectMake(-320, 717, 320, 44);
                            }
                            completion:^(BOOL finished){
                                if(finished)
                                {
                                    [contentTextView resignFirstResponder];
                                    [buttonsView removeFromSuperview];
                                    [UIView animateWithDuration:0.1
                                                    animations:^{
                                                        panelView.frame = CGRectMake(210, -80, 320, 100);
                                                    }
                                                    completion:^(BOOL finished){
                                                        if(finished)
                                                        {
                                                            [panelView removeFromSuperview];
                                                            [self.view removeFromSuperview];
                                                            if([delegate respondsToSelector:@selector(tinyPanelDidDismiss:)])
                                                            {
                                                                [delegate performSelector:@selector(tinyPanelDidDismiss:) withObject:self];
                                                            }
                                                        }
                                                    }];
                                }
                            }];
        }
    }else
    {
        if(orientation == UIInterfaceOrientationLandscapeLeft ||
           orientation == UIInterfaceOrientationLandscapeRight)
        {
            [UIView animateWithDuration:0.1
                             animations:^{
                                 buttonsView.frame = CGRectMake(-320, 117, 320, 44);
                             }
                             completion:^(BOOL finished){
                                 if(finished)
                                 {
                                     [contentTextView resignFirstResponder];
                                     [buttonsView removeFromSuperview];
                                     [UIView animateWithDuration:0.1
                                                      animations:^{
                                                          panelView.frame = CGRectMake(80, -80, 320, 100);
                                                      }
                                                      completion:^(BOOL finished){
                                                          if(finished)
                                                          {
                                                              [panelView removeFromSuperview];
                                                              [self.view removeFromSuperview];
                                                              if([delegate respondsToSelector:@selector(tinyPanelDidDismiss:)])
                                                              {
                                                                  [delegate performSelector:@selector(tinyPanelDidDismiss:) withObject:self];
                                                              }
                                                          }
                                                      }];
                                 }
                             }];
        }else
        {
            [UIView animateWithDuration:0.1
                            animations:^{
                                buttonsView.frame = CGRectMake(0, 221, -320, 44);
                            }
                            completion:^(BOOL finished){
                                if(finished)
                                {
                                    [contentTextView resignFirstResponder];
                                    [buttonsView removeFromSuperview];
                                    [UIView animateWithDuration:0.1
                                                    animations:^{
                                                        panelView.frame = CGRectMake(0, -80, 320, 100);
                                                    }
                                                    completion:^(BOOL finished){
                                                        if(finished)
                                                        {
                                                            [panelView removeFromSuperview];
                                                            [self.view removeFromSuperview];
                                                            if([delegate respondsToSelector:@selector(tinyPanelDidDismiss:)])
                                                            {
                                                                [delegate performSelector:@selector(tinyPanelDidDismiss:) withObject:self];
                                                            }
                                                        }
                                                    }];
                             }
                         }];
        }
    }
}

- (IBAction)acceptPressed:(id)sender
{
    [delegate tinyPanel:self acceptedWithString:contentTextView.text];
}

- (IBAction)cancelPressed:(id)sender
{
    [delegate tinyPanelWasCancelled:self];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    NSDictionary *dict = [notif userInfo];
    keyboardRect = [[dict valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

- (void)keyboardWillHide:(NSNotification *)notif
{
}

- (void)keyboardChangedFrame:(NSNotification *)notif
{
    NSDictionary *dict = [notif userInfo];
    keyboardRect = [[dict valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

@end
