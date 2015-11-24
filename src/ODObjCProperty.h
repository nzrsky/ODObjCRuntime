//
//  ODObjCProperty.h
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 21.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

extern NSString * const kODObjCPropertyTypeEncoding;
extern NSString * const kODObjCPropertyIVarName;
extern NSString * const kODObjCPropertyCopy;
extern NSString * const kODObjCPropertyCustomGetter;
extern NSString * const kODObjCPropertyCustomSetter;
extern NSString * const kODObjCPropertyDynamic;
extern NSString * const kODObjCPropertyEligibleForGarbageCollection;
extern NSString * const kODObjCPropertyNonAtomic;
extern NSString * const kODObjCPropertyOldTypeEncoding;
extern NSString * const kODObjCPropertyReadOnly;
extern NSString * const kODObjCPropertyRetain;
extern NSString * const kODObjCPropertyWeak;

@interface ODObjCProperty : NSObject
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *typeEncoding;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *attributes;
    
@property (nonatomic, unsafe_unretained, readonly) objc_property_t property;

- (instancetype)initWithProperty:(objc_property_t)property;

// Attributes
- (BOOL)hasAttribute: (NSString *)attrType;
- (BOOL)hasCopyAtribute;
- (BOOL)isDynamic;
- (BOOL)isEligibleForGarbageCollection;
- (BOOL)isNonatomic;
- (BOOL)isReadOnly;
- (BOOL)hasRetainAttribute;
- (BOOL)hasWeakAttribute;
- (NSString *)associatedIvarName;
- (NSString *)associatedIvarTypeEncoding;
- (NSString *)oldIvarTypeEncoding;
- (NSString *)customGetterName;
- (NSString *)customSetterName;
@end

@interface ODObjCProperty (Array)
+ (NSArray <ODObjCProperty *> *)propertiesWithList:(objc_property_t *)list count:(unsigned int)count;
@end