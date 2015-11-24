//
//  ODObjCIvar.h
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 21.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface ODObjCIvar : NSObject
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *typeEncoding;
@property (nonatomic, assign, readonly) ptrdiff_t offset;

@property (nonatomic, assign, readonly) Ivar ivar;

- (instancetype)initWithIvar:(Ivar)ivar;
- (instancetype)initWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding offset:(ptrdiff_t)offset;
@end

@interface ODObjCIvar (Array)
+ (NSArray <ODObjCIvar *> *)ivarsWithList:(Ivar *)list count:(unsigned int)count;
@end