//
//  AIProgressPanel.h
//  Combox
//
//  Created by Andrés Ibañez on 9/4/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIProgressPanel : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *leftLbl;
@property (strong, nonatomic) IBOutlet UILabel *imageNameLbl;
@property (strong, nonatomic) IBOutlet UIImageView *imageThumbnail;
@property (strong, nonatomic) IBOutlet UIProgressView *uploadProgressBar;
@property (strong, nonatomic) IBOutlet UILabel *percentageLbl;

@end
