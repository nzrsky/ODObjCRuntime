//
//  ODObjCMethod.h
//  ODObjCRuntime
//
//  Created by Alex Nazaroff on 21.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface ODObjCMethod : NSObject

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, unsafe_unretained, readonly) Method method;

@property (nonatomic, assign, readonly) SEL selector;
@property (nonatomic, copy, readonly) NSString *typeEncoding;
@property (nonatomic, assign) IMP implementation;

- (instancetype)initWithMethod:(Method)method;
- (instancetype)initWithSelector:(SEL)sel implementation:(IMP)imp typeEncoding:(NSString *)type;

- (NSArray<NSString *> *)argumentsTypes;
- (NSString *)returnType;

- (void)exchangeImplementationsWithMethod:(ODObjCMethod *)anotherMethod;
@end

@interface ODObjCMethod (Array)
+ (NSArray <ODObjCMethod *> *)methodsWithDescriptions:(struct objc_method_description *)descriptions count:(unsigned int)count;
+ (NSArray <ODObjCMethod *> *)methodsWithList:(Method *)list count:(unsigned int)count;
@end