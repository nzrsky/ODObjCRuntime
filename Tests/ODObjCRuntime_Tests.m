//
//  Tests.m
//  Tests
//
//  Created by Alex Nazaroff on 21.11.15.
//  Copyright © 2015 AJR. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ODObjCRuntime.h"
#import "ODObjCProtocol.h"
#import "ODObjCMethod.h"
#import "ODObjCProperty.h"
#import "ODObjCIvar.h"

@protocol ODObjCRuntime_TestProtocol <NSObject>
@required
- (void)testProtocols;
+ (void)testStatic;

@optional
- (void)unknownMethod;
+ (void)unknownStaticMethod;
@end

@protocol ODObjCRuntime_TestProtocolB <NSObject>
@end

@protocol ODObjCRuntime_TestProtocolC <NSObject>
@end


@interface ODObjCRuntime_TestClass : NSObject
@end

@implementation ODObjCRuntime_TestClass
- (int)beefMethod { return 0xbeef; }
- (int)deadMethod { return 0xdead; }
@end

@interface ODObjCRuntime_Test : XCTestCase <ODObjCRuntime_TestProtocol, ODObjCRuntime_TestProtocolB>
@property (nonatomic, assign, readonly) int propertyInt;
@property (atomic, copy, getter=getString, setter=setString:) NSString *propertyString;
@end

@implementation ODObjCRuntime_Test {
    NSString *ivarString;
    int ivarIntArray[10];
    int *ivarIntPtr;
    struct { int x; } ivarStruct;

    id ivarId;
    __unsafe_unretained id *ivarIdPtr;
    void (^ivarBlock)(void);
    
    int ivarInt;
}

#pragma mark - Ivars
- (void)testIvars {
    NSArray<ODObjCIvar *> *ivars = [self.class od_ivars];
    XCTAssert(ivars.count == 10);
    
    ODObjCIvar *ivar = ivars.firstObject;
    XCTAssert(ivar.offset == 24 && [ivar.name isEqualToString:@"ivarString"] && [ivar.typeEncoding isEqualToString:@"@\"NSString\""]);
    XCTAssert([ivar isEqual:[self.class od_ivarWithName:@"ivarString"]]);
    
    ODObjCIvar *tmpIvar = [[ODObjCIvar alloc] initWithName:@"tmpVar" typeEncoding:@"i" offset:2];
    XCTAssert([tmpIvar.name isEqualToString:@"tmpVar"] && [tmpIvar.typeEncoding isEqualToString:@"i"]);
}

#pragma mark - Methods
- (void)testMethods {
    NSArray<ODObjCMethod *> *methods = [self.class od_methods];
    XCTAssert(methods.count == 9);
    
    NSUInteger idx = [methods indexOfObject:[self.class od_methodWithSelector:@selector(testMethods)]];
    XCTAssert(idx != NSNotFound);
    
    ODObjCMethod *method = methods[idx];
    XCTAssert([method.name isEqualToString:NSStringFromSelector(@selector(testMethods))]);
    XCTAssert([method isEqual:[[ODObjCMethod alloc] initWithMethod:method.method]]);
    
    XCTAssert(![self respondsToSelector:NSSelectorFromString(@"beefMethod")]);
    
    method = [ODObjCRuntime_TestClass od_methodWithSelector:@selector(beefMethod)];
    XCTAssert([self.class od_addMethod:[[ODObjCMethod alloc] initWithSelector:method.selector
                                                               implementation:method.implementation
                                                                 typeEncoding:method.typeEncoding]]);
    methods = [self.class od_methods];
    XCTAssert(methods.count == 10);
    XCTAssert([self respondsToSelector:NSSelectorFromString(@"beefMethod")]);
    XCTAssert([(ODObjCRuntime_TestClass *)self beefMethod] == 0xbeef);
    
    XCTAssert([self.class od_addMethod:[ODObjCRuntime_TestClass od_methodWithSelector:@selector(deadMethod)]]);
    methods = [self.class od_methods];
    XCTAssert(methods.count == 11);
    XCTAssert([(ODObjCRuntime_TestClass *)self deadMethod] == 0xdead);

    [method exchangeImplementationsWithMethod:[ODObjCRuntime_TestClass od_methodWithSelector:@selector(deadMethod)]];
    XCTAssert([[ODObjCRuntime_TestClass new] beefMethod] == 0xdead);

    method.implementation = [ODObjCRuntime_TestClass od_methodWithSelector:@selector(deadMethod)].implementation;
    XCTAssert([[ODObjCRuntime_TestClass new] beefMethod] == 0xbeef);
    
    methods = [self.class od_classMethods];
    XCTAssert(methods.count == 1);
    XCTAssert([methods.firstObject.name isEqualToString:@"testStatic"]);
    
    NSArray *args = [[ODObjCIvar od_methodWithSelector:@selector(initWithName:typeEncoding:offset:)] argumentsTypes];
    XCTAssert(args.count == 5);
    XCTAssert([[ODObjCIvar od_methodWithSelector:@selector(initWithName:typeEncoding:offset:)].returnType isEqualToString:@"@"]);
}

#pragma mark - Protocols
- (void)testProtocols {
    NSString *name = NSStringFromProtocol(@protocol(ODObjCRuntime_TestProtocol));
    ODObjCProtocol *protocol = [[ODObjCProtocol alloc] initWithName:name];
    XCTAssert([protocol.name isEqualToString:name]);
    XCTAssert([[[ODObjCProtocol alloc] initWithProtocol:@protocol(ODObjCRuntime_TestProtocol)].name isEqualToString:name]);
    
    NSArray <ODObjCProtocol *> *protocols = [ODObjCProtocol allProtocols];
    XCTAssert([protocols indexOfObject:protocol] != NSNotFound);

    XCTAssert([protocols.firstObject isEqual:
               [[ODObjCProtocol alloc] initWithProtocol:protocols.firstObject.protocol]]);
    
    XCTAssert([protocols.firstObject isEqual:
               [[ODObjCProtocol alloc] initWithName:protocols.firstObject.name]]);
    
    XCTAssert([[protocol parentProtocols] indexOfObject:
               [[ODObjCProtocol alloc] initWithProtocol:@protocol(NSObject)]] != NSNotFound);
    
    protocols = [self.class od_protocols];
    XCTAssert(protocols.count == 2 &&
              [protocols indexOfObject:[[ODObjCProtocol alloc] initWithProtocol:@protocol(ODObjCRuntime_TestProtocol)]] != NSNotFound &&
              [protocols indexOfObject:[[ODObjCProtocol alloc] initWithProtocol:@protocol(ODObjCRuntime_TestProtocolB)]] != NSNotFound);
    
    XCTAssert([self.class od_addProtocol:[[ODObjCProtocol alloc] initWithProtocol:@protocol(ODObjCRuntime_TestProtocolC)]]);
    XCTAssert([self.class od_protocols].count == 3);
    
    XCTAssert([[[ODObjCProtocol alloc] initWithProtocol:@protocol(ODObjCRuntime_TestProtocol)] methodsIsRequired:YES instance:YES].count == 1);
    XCTAssert([[[ODObjCProtocol alloc] initWithProtocol:@protocol(ODObjCRuntime_TestProtocol)] methodsIsRequired:YES instance:NO].count == 1);
    XCTAssert([[[ODObjCProtocol alloc] initWithProtocol:@protocol(ODObjCRuntime_TestProtocol)] methodsIsRequired:NO instance:YES].count == 1);
    XCTAssert([[[ODObjCProtocol alloc] initWithProtocol:@protocol(ODObjCRuntime_TestProtocol)] methodsIsRequired:NO instance:NO].count == 1);
}

#pragma mark - Properties
- (void)testProperties {
    NSArray<ODObjCProperty *> *props = [self.class od_properties];
    XCTAssert(props.count > 0);
    
    XCTAssert([self.class od_propertyWithName:@"propertyInt"]);
    
    NSUInteger idx = [props indexOfObject:[self.class od_propertyWithName:@"propertyInt"]];
    XCTAssert(idx != NSNotFound);
    
    ODObjCProperty *intP = [self.class od_propertyWithName:@"propertyInt"];
    XCTAssert(intP.isReadOnly);
    XCTAssert(intP.isNonatomic);
    XCTAssert(!intP.hasCopyAtribute && !intP.hasRetainAttribute);
    XCTAssert([intP.associatedIvarName isEqualToString:@"_propertyInt"]);
    XCTAssert([intP.associatedIvarTypeEncoding isEqualToString:@"i"]);
    
    ODObjCProperty *intS = [self.class od_propertyWithName:@"propertyString"];
    XCTAssert(!intS.isReadOnly);
    XCTAssert(!intS.isNonatomic);
    XCTAssert(intS.hasCopyAtribute);
    XCTAssert([intS.associatedIvarName isEqualToString:@"_propertyString"]);
    XCTAssert([intS.associatedIvarTypeEncoding isEqualToString:@"@\"NSString\""]);
    XCTAssert([intS.customGetterName isEqualToString:@"getString"]);
    XCTAssert([intS.customSetterName isEqualToString:@"setString:"]);
}

#pragma mark - Runtime
- (void)testRuntime {
    XCTAssert([XCTestCase.class od_subclasses].count == 1 && [XCTestCase.class od_subclasses].firstObject == self.class);
    XCTAssert([[ODObjCRuntime allClasses] indexOfObject:self.class] != NSNotFound);
    
    XCTAssert([[ODObjCRuntime libraryOfClass:NSObject.class].lastPathComponent isEqualToString:@"libobjc.A.dylib"]);
    XCTAssert([ODObjCRuntime loadedLibraries].count > 0);
    
    for (NSString *str in [ODObjCRuntime loadedLibraries]) {
        if ([str.lastPathComponent isEqualToString:@"libobjc.A.dylib"]) {
            XCTAssert([[ODObjCRuntime classNamesInLibrary:str] indexOfObject:@"NSObject"] != NSNotFound);
            break;
        }
    }
}

+ (void)testStatic {
}

@end
