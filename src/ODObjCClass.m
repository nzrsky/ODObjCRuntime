//
//  ODObjCClass.m
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 23.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import "ODObjCClass.h"
#import "ODObjCIvar.h"
#import "ODObjCMethod.h"
#import "ODObjCProperty.h"
#import "ODObjCProtocol.h"
#import "ODObjCRuntime.h"

@implementation ODObjCClass {
    Class _class;
}

- (instancetype)initWithName:(NSString *)name {
    return [self initWithName:name superclass:nil];
}

- (instancetype)initWithName:(NSString *)name superclass:(__unsafe_unretained Class)superclass {
    if ((self = [self init])) {
        _class = objc_allocateClassPair(superclass, name.UTF8String, 0);
    }
    return _class ? self : nil;
}

- (void)addIvar:(ODObjCIvar *)ivar {
    const char *type = ivar.typeEncoding.UTF8String;
    NSUInteger size, alignment;
    NSGetSizeAndAlignment(type, &size, &alignment);
    class_addIvar(_class, ivar.name.UTF8String, size, log2(alignment), type);
}

- (void)addMethod:(ODObjCMethod *)method {
    class_addMethod(_class, method.selector, method.implementation, method.typeEncoding.UTF8String);
}

- (void)addProperty: (ODObjCProperty *)property {
    [ODObjCRuntime addProperty:property toClass:_class];
}

- (void)addProtocol: (ODObjCProtocol *)protocol {
    class_addProtocol(_class, protocol.protocol);
}

- (Class)registerClass {
    objc_registerClassPair(_class);
    return _class;
}

@end
