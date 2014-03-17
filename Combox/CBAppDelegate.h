//
//  CBAppDelegate.h
//  Combox
//
//  Created by Andrés Ibañez on 8/24/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface CBAppDelegate : UIResponder <UIApplicationDelegate, DBSessionDelegate, DBNetworkRequestDelegate>
{
    NSString *relinkUserId;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DBMetadata *currentFile;

@end
