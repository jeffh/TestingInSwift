#import "PerformSelector.h"

@implementation SelectorProxy

- (instancetype)initWithTarget:(id)target
{
    self = [super init];
    if (self) {
        _target = target;
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)performAction:(nonnull SEL)aSelector
{
    [self.target performSelector:aSelector];
}

- (void)performAction:(nonnull SEL)aSelector withObject:(nullable id)object
{
    [self.target performSelector:aSelector withObject:object];
}

- (void)performAction:(nonnull SEL)aSelector withObject:(nullable id)object1 withObject:(nullable id)object2
{
    [self.target performSelector:aSelector withObject:object1 withObject:object2];
}
#pragma clang diagnostic pop

@end
