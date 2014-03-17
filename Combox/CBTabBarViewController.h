//
//  CBTabBarViewController.h
//  Combox
//
//  Created by Andrés Ibañez on 8/25/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface CBTabBarViewController : UITabBarController <DBSessionDelegate, DBNetworkRequestDelegate>
{
    NSString *relinkUserId;
}

@property (nonatomic, strong) DBMetadata *currentFile;

@end
