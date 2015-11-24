//
//  ODObjCProperty.m
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 21.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import "ODObjCProperty.h"

NSString * const kODObjCPropertyTypeEncoding                  = @"T";
NSString * const kODObjCPropertyIVarName                      = @"V";
NSString * const kODObjCPropertyCopy                          = @"C";
NSString * const kODObjCPropertyCustomGetter                  = @"G";
NSString * const kODObjCPropertyCustomSetter                  = @"S";
NSString * const kODObjCPropertyDynamic                       = @"D";
NSString * const kODObjCPropertyEligibleForGarbageCollection  = @"P";
NSString * const kODObjCPropertyNonAtomic                     = @"N";
NSString * const kODObjCPropertyOldTypeEncoding               = @"t";
NSString * const kODObjCPropertyReadOnly                      = @"R";
NSString * const kODObjCPropertyRetain                        = @"&";
NSString * const kODObjCPropertyWeak                          = @"W";

@implementation ODObjCProperty {
    objc_property_t _method;
    NSString *_name;
    NSDictionary<NSString *, NSString *> *_attributes;
}

- (instancetype)initWithProperty:(objc_property_t)property {
    if ((self = [super init])) {
        _property = property;
        _name = [NSString stringWithUTF8String:property_getName(_property)];
        
        NSArray<NSString *> *attrs = [[NSString stringWithUTF8String:property_getAttributes(_property)]
                              componentsSeparatedByString: @","];
        
        NSMutableDictionary<NSString *, NSString *> *_attributesDict = [[NSMutableDictionary alloc] initWithCapacity:attrs.count];
        for (NSString *attr in attrs) {
            _attributesDict[[attr substringToIndex:1]] = [attr substringFromIndex:1];
        }
        
        _attributes = _attributesDict;
    }
    return self;
}

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes {
    if ((self = [self init])) {
        _name = [name copy];
        _attributes = [attributes copy];
    }
    return self;
}

- (NSString *)name {
    return _name;
}

- (NSDictionary<NSString *, NSString *> *)attributes {
    return [_attributes copy];
}

- (NSString *)typeEncoding {
    return [NSString stringWithUTF8String:property_getAttributes(self.property)];
}

- (BOOL)hasAttribute:(NSString *)attrType {
    return self.attributes[attrType] != nil;
}

- (BOOL)hasCopyAtribute {
    return [self hasAttribute:kODObjCPropertyCopy];
}

- (BOOL)isDynamic {
    return [self hasAttribute:kODObjCPropertyDynamic];
}

- (BOOL)isEligibleForGarbageCollection {
    return [self hasAttribute:kODObjCPropertyEligibleForGarbageCollection];
}

- (BOOL)isNonatomic {
    return [self hasAttribute:kODObjCPropertyNonAtomic];
}

- (BOOL)isReadOnly {
    return [self hasAttribute:kODObjCPropertyReadOnly];
}

- (BOOL)hasRetainAttribute {
    return [self hasAttribute:kODObjCPropertyRetain];
}

- (BOOL)hasWeakAttribute {
    return [self hasAttribute:kODObjCPropertyWeak];
}

- (NSString *)associatedIvarName {
    return self.attributes[kODObjCPropertyIVarName];
}

- (NSString *)associatedIvarTypeEncoding {
    return self.attributes[kODObjCPropertyTypeEncoding];
}

- (NSString *)oldIvarTypeEncoding {
    return self.attributes[kODObjCPropertyOldTypeEncoding];
}

- (NSString *)customGetterName {
    return self.attributes[kODObjCPropertyCustomGetter];
}

- (NSString *)customSetterName {
    return self.attributes[kODObjCPropertyCustomSetter];
}

- (BOOL)isEqual: (ODObjCProperty *)other {
    return [other isKindOfClass:ODObjCProperty.class] && [self.typeEncoding isEqual:other.typeEncoding] &&
           [self.name isEqual:other.name];
}

- (NSUInteger)hash {
    return self.name.hash ^ self.typeEncoding.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"<%@ %p: %@>", self.class, self, self.name];
}

@end

@implementation ODObjCProperty (Array)

+ (NSArray <ODObjCProperty *> *)propertiesWithList:(objc_property_t *)list count:(unsigned int)count {
    NSMutableArray<ODObjCProperty *> *array = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; ++i) {
        [array addObject:[[self.class alloc] initWithProperty:list[i]]];
    }
    return array;
}

@end