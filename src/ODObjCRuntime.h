//
//  ODObjCRuntime.h
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 21.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class ODObjCIvar, ODObjCProtocol, ODObjCMethod, ODObjCProperty;

@interface NSObject (ODObjCRuntime)

@property (nonatomic, assign) Class od_class;
+ (Class)od_setSuperclass:(Class)superclass;

+ (NSArray<Class> *)od_subclasses;
+ (Class)od_createSubclass:(NSString *)name;

+ (BOOL)od_isMetaClass;
+ (void)od_removeClass;

+ (size_t)od_instanceSize;
+ (NSString *)od_objCType;

/** Ivars of current class */
+ (NSArray<ODObjCIvar *> *)od_ivars;

/** All ivars available of current class, including superclass ivars */
+ (NSArray<ODObjCIvar *> *)od_availableIvars;

+ (ODObjCIvar *)od_ivarWithName:(NSString *)name;

+ (NSArray<ODObjCMethod *> *)od_methods;
+ (NSArray<ODObjCMethod *> *)od_classMethods;
+ (ODObjCMethod *)od_methodWithSelector:(SEL)selector;
+ (ODObjCMethod *)od_classMethodWithSelector:(SEL)selector;
+ (BOOL)od_addMethod:(ODObjCMethod *)method;

+ (IMP)od_methodImplementation:(SEL)selector;
+ (IMP)od_replaceMethod:(ODObjCMethod *)method with:(ODObjCMethod *)otherMethod;
+ (void)od_swizzleMethod:(ODObjCMethod *)method with:(ODObjCMethod *)swizzledMethod;

+ (NSArray<ODObjCProperty *> *)od_properties;
+ (ODObjCProperty *)od_propertyWithName: (NSString *)name;
+ (void)od_addProperty: (ODObjCProperty *)property __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_4_3);

+ (NSArray<ODObjCProtocol *> *)od_protocols;
+ (BOOL)od_addProtocol:(ODObjCProtocol *)protocol;

- (id)od_getAssociatedProperty:(SEL)getter;
- (void)od_addAssociatedProperty:(SEL)getter value:(id)value policy:(objc_AssociationPolicy)policy;
- (void)od_removeAssociatedProperties;
    
- (id)od_valueOfIvar:(ODObjCIvar *)ivar;
- (void)od_setValue:(id)value forIvar:(ODObjCIvar *)ivar;

@end

@interface ODObjCRuntime : NSObject
+ (void)enumerateClassesUsingBlock:(void (^)(Class cls, NSUInteger idx, BOOL *stop))block NS_AVAILABLE(10_6, 4_0);
+ (NSArray<Class> *)allClasses;

+ (NSArray<NSString *> *)loadedLibraries;
+ (NSString *)libraryOfClass:(Class)cls;
+ (NSArray<NSString *> *)classNamesInLibrary:(NSString *)library;

+ (BOOL)addProperty:(ODObjCProperty *)property toClass:(Class)cls;

@end