#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LibBridge : NSObject
+ (nullable NSString*)vectorize:(CGContextRef)ctx error:(NSError**)error;
@end

NS_ASSUME_NONNULL_END
