//
//  ODObjCRuntime.m
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 21.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import "ODObjCRuntime.h"
#import "ODObjCIvar.h"
#import "ODObjCMethod.h"
#import "ODObjCProperty.h"
#import "ODObjCProtocol.h"
#import "ODObjCClass.h"
#import <dlfcn.h>
#import <mach-o/ldsyms.h>

@implementation NSObject (ODObjCRuntime)

+ (NSArray<ODObjCIvar *> *)od_ivars {
    unsigned int count;
    Ivar *list = class_copyIvarList(self, &count);
    NSArray<ODObjCIvar *> *array = [ODObjCIvar ivarsWithList:list count:count];
    free(list);
    return array;
}

+ (NSArray<ODObjCIvar *> *)od_availableIvars {
    NSMutableArray *ivars = [self od_ivars].mutableCopy ?: [NSMutableArray new];
    Class cls = self.class;
    while ((cls = cls.superclass) && ![cls isEqual:NSObject.class]) {
        [ivars addObjectsFromArray:[cls od_ivars]];
    }
    return ivars;
}

+ (ODObjCIvar *)od_ivarWithName:(NSString *)name {
    Ivar ivar = class_getInstanceVariable(self, name.UTF8String);
    return ivar ? [[ODObjCIvar alloc] initWithIvar:ivar] : nil;
}

+ (NSArray<ODObjCMethod *> *)od_methods {
    unsigned int count;
    Method *list = class_copyMethodList(self, &count);
    NSArray<ODObjCMethod *> *array = [ODObjCMethod methodsWithList:list count:count];
    free(list);
    return array;
}

+ (NSArray<ODObjCMethod *> *)od_classMethods {
    unsigned int count;
    Method *list = class_copyMethodList(self.od_class, &count);
    NSArray<ODObjCMethod *> *array = [ODObjCMethod methodsWithList:list count:count];
    free(list);
    return array;
}

+ (ODObjCMethod *)od_methodWithSelector:(SEL)selector {
    Method method = class_getInstanceMethod(self, selector);
    return method ? [[ODObjCMethod alloc] initWithMethod:method] : nil;
}

+ (ODObjCMethod *)od_classMethodWithSelector:(SEL)selector {
    Method method = class_getClassMethod(self, selector);
    return method ? [[ODObjCMethod alloc] initWithMethod:method] : nil;
}

+ (BOOL)od_addMethod:(ODObjCMethod *)method {
    return class_addMethod(self, method.selector, method.implementation, method.typeEncoding.UTF8String);
}

+ (IMP)od_methodImplementation:(SEL)selector {
    return class_getMethodImplementation(self, selector);
}

+ (IMP)od_replaceMethod:(ODObjCMethod *)method with:(ODObjCMethod *)otherMethod {
    return class_replaceMethod(self, method.selector, otherMethod.implementation, otherMethod.typeEncoding.UTF8String);
}

+ (void)od_swizzleMethod:(ODObjCMethod *)method with:(ODObjCMethod *)swizzledMethod {
    Class cls = self.class;

    BOOL added = class_addMethod(cls, method.selector, swizzledMethod.implementation, swizzledMethod.typeEncoding.UTF8String);
    if (added) {
        class_replaceMethod(cls, swizzledMethod.selector, method.implementation, method.typeEncoding.UTF8String);
    } else {
        method_exchangeImplementations(method.method, swizzledMethod.method);
    }
}

+ (NSArray<ODObjCProperty *> *)od_properties {
    unsigned int count;
    objc_property_t *list = class_copyPropertyList(self, &count);
    NSArray<ODObjCProperty *> *array = [ODObjCProperty propertiesWithList:list count:count];
    free(list);
    return array;
}

+ (ODObjCProperty *)od_propertyWithName: (NSString *)name {
    objc_property_t property = class_getProperty(self, name.UTF8String);
    return property ? [[ODObjCProperty alloc] initWithProperty:property] : nil;
}

+ (void)od_addProperty: (ODObjCProperty *)property {
    [ODObjCRuntime addProperty:property toClass:self];
}

+ (NSArray<ODObjCProtocol *> *)od_protocols {
    unsigned int count;
    Protocol * __unsafe_unretained *list = class_copyProtocolList(self, &count);
    NSArray<ODObjCProtocol *> *array = [ODObjCProtocol protocolsWithList:list count:count];
    free(list);
    return array;
}

+ (BOOL)od_addProtocol:(ODObjCProtocol *)protocol {
    return class_addProtocol(self, protocol.protocol);
}

- (Class)od_class {
    return object_getClass(self);
}

- (void)setOd_class:(Class)cls {
    object_setClass(self, cls);
}

#ifdef __clang__
#pragma clang diagnostic push
#endif
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (Class)od_setSuperclass:(Class)superclass {
    return class_setSuperclass(self, superclass);
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif

+ (BOOL)od_isMetaClass {
    return class_isMetaClass(self);
}

+ (void)od_removeClass {
    objc_disposeClassPair(self);
}

+ (size_t)od_instanceSize {
    return class_getInstanceSize(self);
}

+ (NSString *)od_objCType {
    return [NSString stringWithFormat:@"%s\"%@\"", @encode(id), NSStringFromClass(self)];
}

+ (NSArray<Class> *)od_subclasses {
    NSMutableArray<Class> *array = [NSMutableArray array];
    [ODObjCRuntime enumerateClassesUsingBlock:^(__unsafe_unretained Class cls, NSUInteger idx, BOOL *stop) {
        Class superclass = cls;
        while ((superclass = class_getSuperclass(superclass))) {
            if (superclass == self) {
                [array addObject:cls];
                break;
            }
        }
    }];
    
    return array;
}

+ (Class)od_createSubclass:(NSString *)name {
    return [[[ODObjCClass alloc] initWithName:name superclass:self] registerClass];
}

- (void)od_addAssociatedProperty:(SEL)getter value:(id)value policy:(objc_AssociationPolicy)policy {
    objc_setAssociatedObject(self, getter, value, policy);
}

- (id)od_getAssociatedProperty:(SEL)getter {
    return objc_getAssociatedObject(self, getter);
}

- (void)od_removeAssociatedProperties {
    objc_removeAssociatedObjects(self);
}

- (id)od_valueOfIvar:(ODObjCIvar *)ivar {
    return object_getIvar(self, ivar.ivar);
}

- (void)od_setValue:(id)value forIvar:(ODObjCIvar *)ivar {
    object_setIvar(self, ivar.ivar, value);
}

- (void)od_valueOfIvarWithName:(NSString *)name {
//    
}

@end

@implementation ODObjCRuntime

+ (void)enumerateClassesUsingBlock:(void (^)(Class cls, NSUInteger idx, BOOL *stop))block {
    if (!block) return;
    
    Class *classes = NULL;
    
    int n, size; BOOL stop = NO;
    do {
        n = objc_getClassList(NULL, 0);
        classes = (Class *)realloc(classes, n * sizeof(*classes));
        size = objc_getClassList(classes, n);
    } while (size != n);
    
    if (classes) {
        for (unsigned int i = 0; i < n && !stop; ++i) {
            block(classes[i], i, &stop);
        }
        
        free(classes);
    }
}

+ (NSArray<Class> *)allClasses {
    NSMutableArray<Class> *array = [NSMutableArray array];
    [self enumerateClassesUsingBlock:^(__unsafe_unretained Class cls, NSUInteger idx, BOOL *stop) {
        if (class_getClassMethod(cls, @selector(doesNotRecognizeSelector:))) {
            [array addObject:cls];
        }
        
        // Problem with classes:
        // NSLeafProxy, __ARCLite__,  __NSGenericDeallocHandler, __ARCLite__, __NSMessageBuilder
        // JSExport, __NSAtom, _NSZombie_, Object
    }];
    
    return array;
}

+ (NSArray<NSString *> *)loadedLibraries {
    unsigned int count;
    const char **names = objc_copyImageNames(&count);
    if (names) {
        NSMutableArray<NSString *> *array = [NSMutableArray arrayWithCapacity:count];
        for (unsigned int i = 0; i < count; ++i) {
            [array addObject:[NSString stringWithUTF8String:names[i]]];
        }
        free(names);
        return array;
    }
    return nil;
}

+ (NSString *)libraryOfClass:(Class)cls {
    return [NSString stringWithUTF8String:class_getImageName(cls)];
}

+ (NSArray<NSString *> *)classNamesInLibrary:(NSString *)library {
    unsigned int count;
    const char **names = objc_copyClassNamesForImage(library.UTF8String, &count);
    if (names) {
        NSMutableArray<NSString *> *array = [NSMutableArray arrayWithCapacity:count];
        for (unsigned int i = 0; i < count; ++i) {
            [array addObject:[NSString stringWithUTF8String:names[i]]];
        }
        free(names);
        return array;
    }
    return nil;
}

+ (BOOL)addProperty:(ODObjCProperty *)property toClass:(Class)cls {
    objc_property_attribute_t *attrs = nil;
    unsigned int count;
    
    if (!property.property) {
        NSDictionary<NSString *, NSString *> *attrsDict = property.attributes;
        attrs = (objc_property_attribute_t*)calloc(attrsDict.count, sizeof(objc_property_attribute_t));
        [attrsDict.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            attrs[idx].name = key.UTF8String;
            attrs[idx].value = attrsDict[key].UTF8String;
        }];
        count = (unsigned int)attrsDict.count;
    } else {
        attrs = property_copyAttributeList(property.property, &count);
    }
    
    if (attrs) {
        BOOL result = class_addProperty(cls, property.name.UTF8String, attrs, count);
        free(attrs);
        return result;
    }
    
    return NO;
}

@end
