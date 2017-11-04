//
//  MLAppServiceManager.m
//  MLAppServiceLoader
//

#import "OAEApplicationManager.h"

#import <objc/runtime.h>
#import <objc/message.h>

#import "OAEAppDelegate.h"

@interface OAEApplicationManager()

@property (nonatomic, strong) NSMutableDictionary<NSString*, id<NSObject>> *applications;

@property (nonatomic, assign)BOOL enabling;
@property (nonatomic, assign)BOOL protocolEnabling;

@end

@implementation OAEApplicationManager

+ (instancetype)manager
{
    static OAEApplicationManager *manager;
    static dispatch_once_t onceToken;
  
    dispatch_once(&onceToken, ^{
        manager = [[OAEApplicationManager alloc] init];
    });
  
    return manager;
}

- (NSMutableDictionary *)applications
{
  if(!_applications)
  {
    _applications = [@{} mutableCopy];
  }
  return _applications;
}

- (void)setEnabled:(BOOL)enabled;
{
  [[OAEAppDelegate application]setValue:@(enabled) forKey:@"enabled"];
  self.enabling = enabled;
}

- (void)setProtocolEnabled:(BOOL)protocolEnabled;
{
  [[OAEAppDelegate application]setValue:@(protocolEnabled) forKey:@"protocolEnabled"];
  self.protocolEnabling = protocolEnabled;
}

- (void)registerApplication:(Class)application forKey:(NSString *)key
{
  if(key.length == 0 || ![key isKindOfClass:[NSString class]] || !application || ![application isSubclassOfClass:[NSObject class]]) return;
  id pre = self.applications[key];
  NSAssert(!pre,@"Try to register application already exits. Conflict to application %@ on key %@",NSStringFromClass(application), key);
  if(!pre) self.applications[key] = [[application alloc]init];
}

- (BOOL)applicationCanResponseToSelector:(SEL)selector
{
    __block IMP imp = NULL;
    [self.applications enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if ([obj respondsToSelector:selector])
        {
            imp = [(id)obj methodForSelector:selector];
            NSMethodSignature *signature = [(id)obj methodSignatureForSelector:selector];
            if (signature.methodReturnLength > 0 && strcmp(signature.methodReturnType, @encode(BOOL)) != 0)
            {
                imp = NULL;
            }
            *stop = YES;
        }
    }];
    return imp != NULL && imp != _objc_msgForward;
}

- (NSString *)_objcTypesFromSignature:(NSMethodSignature *)signature
{
    NSMutableString *types = [NSMutableString stringWithFormat:@"%s", signature.methodReturnType?:"v"];
    for (NSUInteger i = 0; i < signature.numberOfArguments; i ++)
    {
      [types appendFormat:@"%s", [signature getArgumentTypeAtIndex:i]];
    }
    return [types copy];
}

- (void)applicationForwardInvocation:(NSInvocation *)invocation
{
    NSMethodSignature *signature = invocation.methodSignature;
    NSUInteger argCount = signature.numberOfArguments;
  
    __block BOOL returnValue = NO;
    NSUInteger returnLength = signature.methodReturnLength;
  
    void * returnValueBytes = NULL;
    if (returnLength > 0) returnValueBytes = alloca(returnLength);
    
    [self.applications enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key,id obj,BOOL *stop) {
        if ( ! [obj respondsToSelector:invocation.selector]) return;
      
        // check the signature
        NSAssert([[self _objcTypesFromSignature:signature] isEqualToString:[self _objcTypesFromSignature:[(id)obj methodSignatureForSelector:invocation.selector]]],
                 @"Method signature for selector (%@) on (%@ - `%@`) is invalid. \
                 Please check the return value type and arguments type.",
                 NSStringFromSelector(invocation.selector), key, obj);
      
        // copy the invokation
        NSInvocation *invok = [NSInvocation invocationWithMethodSignature:signature];
        invok.selector = invocation.selector;
      
        // copy arguments
        for (NSUInteger i = 0; i < argCount; i ++)
        {
            const char * argType = [signature getArgumentTypeAtIndex:i];
            NSUInteger argSize = 0;
            NSGetSizeAndAlignment(argType, &argSize, NULL);
          
            void * argValue = alloca(argSize);
            [invocation getArgument:&argValue atIndex:i];
            [invok setArgument:&argValue atIndex:i];
        }
      
        // reset the target
        invok.target = obj;
      
        // invoke
        [invok invoke];
        
        // get the return value
        if (returnValueBytes)
        {
            [invok getReturnValue:returnValueBytes];
            returnValue = returnValue || *((BOOL *)returnValueBytes);
        }
    }];
    
    // set return value
    if (returnValueBytes) [invocation setReturnValue:returnValueBytes];
}

@end

