//
//  OAEAppDelegate.h
//  MASplashManager
//
//  Created by 陇阪 on 01/11/2017.
//  Copyright © 2017 陇阪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OAEAppDelegate : NSObject
<
UIApplicationDelegate
>

+ (instancetype)application;

@property (nonatomic, assign, readonly)BOOL enabled;

@end
