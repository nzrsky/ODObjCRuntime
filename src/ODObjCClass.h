//
//  ODObjCClass.h
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 23.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ODObjCIvar, ODObjCProtocol, ODObjCMethod, ODObjCProperty;

@interface ODObjCClass : NSObject

- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name superclass:(Class)superclass;

- (void)addIvar:(ODObjCIvar *)ivar;
- (void)addMethod:(ODObjCMethod *)method;
- (void)addProperty: (ODObjCProperty *)property __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_4_3);
- (void)addProtocol:(ODObjCProtocol *)protocol;

- (Class)registerClass;

@end
