//
//  CBSettingsViewController.h
//  Combox
//
//  Created by Andrés Ibañez on 9/5/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface CBSettingsViewController : UITableViewController <DBRestClientDelegate, UIActionSheetDelegate>
{
    DBRestClient *restClient;
}

@property (strong, nonatomic) IBOutlet UILabel *countryLbl;
@property (strong, nonatomic) IBOutlet UILabel *usernameLbl;
@property (strong, nonatomic) IBOutlet UILabel *normalBytesLbl;
@property (strong, nonatomic) IBOutlet UILabel *sharedBytesLbl;
@property (strong, nonatomic) IBOutlet UILabel *totalBytesLbl;
@property (strong, nonatomic) IBOutlet UILabel *capacityLbl;

@end
