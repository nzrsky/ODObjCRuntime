//
//  ODObjCProtocol.h
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 21.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class ODObjCMethod;

@interface ODObjCProtocol : NSObject
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) Protocol *protocol;

- (instancetype)initWithProtocol:(Protocol *)protocol;
- (instancetype)initWithName:(NSString *)name;

- (NSArray<ODObjCMethod *> *)methodsIsRequired:(BOOL)isRequired instance:(BOOL)isInstance;
- (NSArray<ODObjCProtocol *> *)parentProtocols;
    
+ (NSArray <ODObjCProtocol *> *)allProtocols;
@end

@interface ODObjCProtocol (Array)
+ (NSArray <ODObjCProtocol *> *)protocolsWithList:(Protocol * __unsafe_unretained *)list count:(unsigned int)count;
@end