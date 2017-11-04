//
//  main.m
//  OAEApplicationManager
//
//  Created by 陇阪 on 03/11/2017.
//  Copyright © 2017 陇阪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TTAppDelegate.h"
#import "OAEApplicationManager.h"

int main(int argc, char * argv[]) {
  
  @portalable([AppDelegate class]);
  @portalable([TTAppDelegate class]);
  
  [[OAEApplicationManager manager]setEnabled:YES];
  @autoreleasepool {
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
