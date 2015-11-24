//
//  ODObjCMethod.m
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 21.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import "ODObjCMethod.h"

@interface ODObjCUnregisteredMethod: ODObjCMethod
@end

@implementation ODObjCUnregisteredMethod {
    SEL _selector;
    NSString *_typeEncoding;
    IMP _implementation;
}

- (instancetype)initWithSelector:(SEL)sel implementation:(IMP)imp typeEncoding:(NSString *)type {
    if ((self = [super init])) {
        _selector = sel;
        _implementation = imp;
        _typeEncoding = type;
    }
    return self;
}

- (SEL)selector {
    return _selector;
}

- (NSString *)typeEncoding {
    return _typeEncoding;
}

- (IMP)implementation {
    return _implementation;
}

- (void)setImplementation:(IMP)implementation {
    _implementation = implementation;
}

@end

@implementation ODObjCMethod {
    Method _method;
}

- (instancetype)initWithMethod:(Method)method {
    if ((self = [super init])) {
        _method = method;
    }
    return self;
}

- (instancetype)initWithSelector:(SEL)sel implementation:(IMP)imp typeEncoding:(NSString *)type {
    return [[ODObjCUnregisteredMethod alloc] initWithSelector:sel implementation:imp typeEncoding:type];
}

- (NSString *)name {
    return NSStringFromSelector(self.selector);
}

- (SEL)selector {
    return method_getName(self.method);
}

- (NSString *)typeEncoding {
    return [NSString stringWithUTF8String:method_getTypeEncoding(self.method)];
}

- (IMP)implementation {
    return method_getImplementation(self.method);
}

- (void)setImplementation:(IMP)implementation {
    method_setImplementation(self.method, implementation);
}

- (NSArray<NSString *> *)argumentsTypes {
    unsigned int count = method_getNumberOfArguments(self.method);
    NSMutableArray<NSString *> *array = [NSMutableArray array];
    for (unsigned int i = 0; i < count; ++i) {
        char *type = method_copyArgumentType(self.method, i);
        if (type) {
            [array addObject:[NSString stringWithUTF8String:type]];
            free(type);
        }
    }
    return array;
}

- (NSString *)returnType {
    char *type = method_copyReturnType(self.method);
    if (type) {
        NSString *result = [NSString stringWithUTF8String:type];
        free(type);
        return result;
    }
    return nil;
}

- (void)exchangeImplementationsWithMethod:(ODObjCMethod *)anotherMethod {
    method_exchangeImplementations(self.method, anotherMethod.method);
}

- (BOOL)isEqual: (ODObjCMethod *)other {
    return [other isKindOfClass:ODObjCMethod.class] && sel_isEqual(self.selector, other.selector) &&
            self.implementation == other.implementation && [self.typeEncoding isEqual:other.typeEncoding];
}

- (NSUInteger)hash {
    return (NSUInteger)(void *)self.selector ^ (NSUInteger)self.implementation ^ self.typeEncoding.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"<%@ %p: %@>", self.class, self, self.name];
}

@end

@implementation ODObjCMethod (Array)

+ (NSArray <ODObjCMethod *> *)methodsWithDescriptions:(struct objc_method_description *)descriptions count:(unsigned int)count {
    NSMutableArray<ODObjCMethod *> *array = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; ++i) {
        NSString *type = [NSString stringWithCString:descriptions[i].types encoding:[NSString defaultCStringEncoding]];
        [array addObject:[[self.class alloc] initWithSelector:descriptions[i].name implementation:NULL typeEncoding:type]];
    }
    return array;
}

+ (NSArray <ODObjCMethod *> *)methodsWithList:(Method *)list count:(unsigned int)count {
    NSMutableArray<ODObjCMethod *> *array = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; ++i) {
        [array addObject:[[self.class alloc] initWithMethod:list[i]]];
    }
    return array;
}

@end
