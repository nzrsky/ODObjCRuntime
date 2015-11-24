//
//  ODObjCProtocol.m
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 21.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import "ODObjCProtocol.h"
#import "ODObjCMethod.h"

@implementation ODObjCProtocol {
    Protocol *_protocol;
//    NSString *_name;
}

- (instancetype)initWithProtocol:(Protocol *)protocol {
    if ((self = [super init])) {
        _protocol = protocol;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name {
    Protocol *protocol = objc_getProtocol([name cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    return [self initWithProtocol:protocol];
}

- (NSString *)name {
    return [NSString stringWithUTF8String:protocol_getName(self.protocol)];
}

- (BOOL)isEqual: (ODObjCProtocol *)other {
    return [other isKindOfClass:ODObjCProtocol.class] && protocol_isEqual(self.protocol, other.protocol);
}

- (NSUInteger)hash {
    return [(id)self.protocol hash];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"<%@ %p: %@>", self.class, self, self.name];
}

+ (NSArray <ODObjCProtocol *> *)allProtocols {
    unsigned int count;
    Protocol * __unsafe_unretained *protocolsList = objc_copyProtocolList(&count);
    NSArray<ODObjCProtocol *> *array = [self protocolsWithList:protocolsList count:count];
    free(protocolsList);
    return array;
}

- (NSArray<ODObjCProtocol *> *)parentProtocols {
    unsigned int count;
    Protocol * __unsafe_unretained *protocolsList = protocol_copyProtocolList(self.protocol, &count);
    NSArray<ODObjCProtocol *> *array = [self.class protocolsWithList:protocolsList count:count];
    free(protocolsList);
    return array;
}

- (NSArray<ODObjCMethod *> *)methodsIsRequired:(BOOL)isRequired instance:(BOOL)isInstance {
    unsigned int count;
    struct objc_method_description *methodsDesc = protocol_copyMethodDescriptionList(self.protocol, isRequired, isInstance, &count);
    NSArray<ODObjCMethod *> *array = [ODObjCMethod methodsWithDescriptions:methodsDesc count:count];
    free(methodsDesc);
    return array;
}

@end

@implementation ODObjCProtocol (Array)

+ (NSArray <ODObjCProtocol *> *)protocolsWithList:(Protocol * __unsafe_unretained *)list count:(unsigned int)count {
    NSMutableArray<ODObjCProtocol *> *array = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; ++i) {
        [array addObject: [[self.class alloc] initWithProtocol:list[i]]];
    }
    return array;
}

@end