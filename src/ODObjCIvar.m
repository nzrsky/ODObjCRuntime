//
//  ODObjCIvar.m
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 21.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import "ODObjCIvar.h"

@interface ODObjCUnregisteredIvar: ODObjCIvar
@end

@implementation ODObjCUnregisteredIvar {
    NSString *_name;
    NSString *_typeEncoding;
    ptrdiff_t _offset;
}

- (instancetype)initWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding offset:(ptrdiff_t)offset {
    if ((self = [super init])) {
        _name = name;
        _offset = offset;
        _typeEncoding = typeEncoding;
    }
    return self;
}

- (NSString *)name {
    return _name;
}

- (ptrdiff_t)offset {
    return _offset;
}

- (NSString *)typeEncoding {
    return _typeEncoding;
}


@end
    
@implementation ODObjCIvar {
    Ivar _ivar;
}

- (instancetype)initWithIvar:(Ivar)ivar {
    if ((self = [super init])) {
        _ivar = ivar;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding offset:(ptrdiff_t)offset {
    return [[ODObjCUnregisteredIvar alloc] initWithName:name typeEncoding:typeEncoding offset:offset];
}

- (NSString *)name {
    return [NSString stringWithUTF8String:ivar_getName(self.ivar)];
}

- (NSString *)typeEncoding {
    return [NSString stringWithUTF8String:ivar_getTypeEncoding(self.ivar)];
}

- (ptrdiff_t)offset {
    return ivar_getOffset(self.ivar);
}

- (BOOL)isEqual: (ODObjCIvar *)other {
    return [other isKindOfClass:ODObjCIvar.class] && [self.name isEqual:other.name] && [self.typeEncoding isEqual:other.typeEncoding];
}

- (NSUInteger)hash {
    return self.name.hash ^ self.typeEncoding.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"<%@ %p: %@ %@ %td>", self.class, self, self.typeEncoding, self.name, self.offset];
}

@end

@implementation ODObjCIvar (Array)

+ (NSArray <ODObjCIvar *> *)ivarsWithList:(Ivar *)list count:(unsigned int)count {
    NSMutableArray<ODObjCIvar *> *array = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; ++i) {
        [array addObject: [[self.class alloc] initWithIvar:list[i]]];
    }
    return array;
}

@end