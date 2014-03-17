//
//  AITinyPanel.h
//  Combox
//
//  Created by Andrés Ibañez on 9/2/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AITinyPanel;
@protocol AITinyPanelDelegate <NSObject>

@required
-(void)tinyPanel:(AITinyPanel *)panel acceptedWithString:(NSString *)string;
-(void)tinyPanelWasCancelled:(AITinyPanel *)panel;

@optional
-(void)tinyPanelWillShow:(AITinyPanel *)panel;
-(void)tinyPanelWillDismiss:(AITinyPanel *)panel;
-(void)tinyPanelDidShow:(AITinyPanel *)panel;
-(void)tinyPanelDidDismiss:(AITinyPanel *)panel;
@end

@interface AITinyPanel : UIViewController
{
    id<AITinyPanelDelegate> __weak delegate;
    UIView __weak *destinyView;
    
    CGRect keyboardRect;
}

@property(nonatomic, weak)UIView *destinyView;
@property(nonatomic, weak) id<AITinyPanelDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *panelView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *iconImage;
@property (strong, nonatomic) IBOutlet UIView *buttonsView;
@property (strong, nonatomic) IBOutlet UITextField *contentTextView;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *okButton;

-(void)showView;
-(void)dismissView;
-(void)rotationOccured;

- (IBAction)acceptPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

//Called by NSNotificationCenter
- (void)keyboardWillShow:(NSNotification *)notif;
- (void)keyboardWillHide:(NSNotification *)notif;
- (void)keyboardChangedFrame:(NSNotification *)notif;
@end