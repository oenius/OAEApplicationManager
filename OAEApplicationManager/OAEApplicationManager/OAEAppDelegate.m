//
//  OAEAppDelegate.m
//  MASplashManager
//
//  Created by 陇阪 on 01/11/2017.
//  Copyright © 2017 陇阪. All rights reserved.
//

#import "OAEAppDelegate.h"
#import "OAEApplicationManager.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface _OAEPortalDelegate : UIResponder<UIApplicationDelegate>
@property (nonatomic, strong)UIWindow *window;
@end
@implementation _OAEPortalDelegate

+ (void)load{ @portalable(self.class); }

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self.window makeKeyAndVisible]; return YES;
}
@end

@interface OAEAppDelegate()

@property (nonatomic, assign)BOOL enabled;
@property (nonatomic, assign)BOOL protocolEnabled;

@end

@implementation OAEAppDelegate

+ (instancetype)application
{
  static OAEAppDelegate *oae;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    oae = [[OAEAppDelegate alloc]init];
  });
  return oae;
}

- (NSArray<NSString *> *)protocols
{
  static NSMutableArray *methods = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    unsigned int methodCount = 0;
    struct objc_method_description *methodList = protocol_copyMethodDescriptionList(@protocol(UIApplicationDelegate), NO, YES, &methodCount);
    methods = [NSMutableArray arrayWithCapacity:methodCount];
    for (int i = 0; i < methodCount; i ++) {
      struct objc_method_description md = methodList[i];
      [methods addObject:NSStringFromSelector(md.name)];
    }
    free(methodList);
  });
  return methods;
}

- (BOOL)respondsToSelector:(SEL)selector
{
  if(!self.enabled) return [super respondsToSelector:selector];
  
  BOOL canResponse = [self methodForSelector:selector] != nil && [self methodForSelector:selector] != _objc_msgForward;
  if (!canResponse) canResponse = self.protocolEnabled ? [[OAEApplicationManager manager] applicationCanResponseToSelector:selector] : [[OAEApplicationManager manager] applicationCanResponseToSelector:selector] && [[self protocols]containsObject:NSStringFromSelector(selector)];
  return canResponse;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
  if(!self.enabled) return [super forwardInvocation:invocation];
  [[OAEApplicationManager manager] applicationForwardInvocation:invocation];
}

@end
