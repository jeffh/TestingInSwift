#import <Foundation/Foundation.h>

/*! Provides a basic API around performSelector:
 *
 *  This does not return any object since Swift can return an invalid ObjC
 *  pointer if there is no expected return type for that selector. Since
 *  performSelector: cannot know that ahead of time, it can crash if we
 *  try to operate on the returned value (eg - retaining it).
 */
@interface SelectorProxy : NSObject

@property (nullable, nonatomic, readonly) id target;

- (nonnull instancetype)initWithTarget:(nullable id)target;

- (void)performAction:(nonnull SEL)aSelector;
- (void)performAction:(nonnull SEL)aSelector withObject:(nullable id)object;
- (void)performAction:(nonnull SEL)aSelector withObject:(nullable id)object1 withObject:(nullable id)object2;

@end
