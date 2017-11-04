//
//  MLAppServiceManager.h
//  MLAppServiceLoader
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define portalable(cls) \
autoreleasepool {} \
[[OAEApplicationManager manager]registerApplication:cls forKey:NSStringFromClass(cls)];

NS_ASSUME_NONNULL_BEGIN
@interface OAEApplicationManager : NSObject

@property (nonatomic, assign, readonly)BOOL enabling;
@property (nonatomic, assign, readonly)BOOL protocolEnabling;

+ (instancetype)manager;

- (void)setEnabled:(BOOL)enable;

- (void)setProtocolEnabled:(BOOL)protocolEnabled;

- (void)registerApplication:(Class)application forKey:(NSString *)key;

- (BOOL)applicationCanResponseToSelector:(SEL)selector;

- (void)applicationForwardInvocation:(NSInvocation *)invocation;

@end
NS_ASSUME_NONNULL_END
