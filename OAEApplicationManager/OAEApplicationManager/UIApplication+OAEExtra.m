//
//  UIApplication+OAEExtra.m
//  MASplashManager
//
//  Created by 陇阪 on 03/11/2017.
//  Copyright © 2017 陇阪. All rights reserved.
//

#import "UIApplication+OAEExtra.h"
#import <objc/runtime.h>
#import "OAEAppDelegate.h"

@implementation UIApplication (OAEExtra)

void _swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)
{
  // the method might not exist in the class, but in its superclass
  Method originalMethod = class_getInstanceMethod(class, originalSelector);
  Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
  
  // class_addMethod will fail if original method already exists
  BOOL checked = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
  
  // the method doesn’t exist and we just added one
  if (checked)
  {
    class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
  }
  else
  {
    method_exchangeImplementations(originalMethod, swizzledMethod);
  }
}

+ (void)load
{
  _swizzleMethod([UIApplication class], @selector(setDelegate:), @selector(oae_setDelegate:));
}

- (void)oae_setDelegate:(id<UIApplicationDelegate>)delegate
{
  if([OAEAppDelegate application].enabled)
  {
    delegate = [OAEAppDelegate application];
  }
  [self oae_setDelegate:delegate];
}


@end
