//
//  Tests.m
//  Tests
//
//  Created by Tanner on 4/18/19.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "Watchdog.h"

#define ReleaseAndAwaitDealloc(property) { \
    XCTestExpectation *e = self.property.expectation; \
    self.property = nil; \
    [self waitForExpectations:@[e] timeout:1.5]; \
}

@interface Tests : XCTestCase
@property (nonatomic) DeallocWatchdog *dog;
@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) SEL lastTest;
@end

@implementation Tests

- (void)setUp {
    self.dog = [DeallocWatchdog new];
    self.expectation = self.dog.expectation;
}

- (void)tearDown {
    self.dog = nil;
    [self waitForExpectations:@[self.expectation] timeout:1.5];
}

- (void)testBridge { _lastTest = _cmd;
    void *objectReturnedFromMethod = [self getInvocationReturnValue];
    __unused id returnObject = (__bridge id)objectReturnedFromMethod;
}

/// Expected to over-release, EXC_BAD_ACCESS
/// (Watchdog is deallocated early and self.dog is invalid)
- (void)testBridgeTransfer { _lastTest = _cmd;
    void *objectReturnedFromMethod = [self getInvocationReturnValue];
    __unused id returnObject = (__bridge_transfer id)objectReturnedFromMethod;
}

/// Expected to under-release / over-retain
/// (Watchdog is never deallocated)
- (void)testRetained { _lastTest = _cmd;
    self.expectation.inverted = YES;
    void *objectReturnedFromMethod = [self getInvocationReturnValue];
    __unsafe_unretained id object = (__bridge id)objectReturnedFromMethod;
    __unused void *afterARC = (__bridge_retained void *)object;
}

- (void)testBridgeWithoutInvocation { _lastTest = _cmd;
    const void *objectReturnedFromMethod = (__bridge void *)self.dog;
    __unused id afterARC = (__bridge id)objectReturnedFromMethod;
}

/// Expected to over-release, EXC_BAD_ACCESS
/// (Watchdog is deallocated early and self.dog is invalid)
- (void)testBridgeTransferWithoutInvocation { _lastTest = _cmd;
    const void *objectReturnedFromMethod = (__bridge void *)self.dog;
    __unused id afterARC = (__bridge_transfer id)objectReturnedFromMethod;
}

/// Expected to under-release / over-retain
/// (Watchdog is never deallocated)
- (void)testRetainedWithoutInvocation { _lastTest = _cmd;
    self.expectation.inverted = YES;
    __unused void *afterARC = (__bridge_retained void *)self.dog;
}

- (void)testBridgeAlsoWorks { _lastTest = _cmd;
    NSObject *obj = [NSObject new];
    NSString *safeStringPointer = [NSString stringWithFormat:@"%p", obj];

    const void *ptr = nil;
    unsigned long long tmp = 0;
    NSScanner *scanner = [NSScanner scannerWithString:safeStringPointer];
    [scanner scanHexLongLong:&tmp];
    ptr = (const void *)tmp;

    XCTAssertEqual(ptr, (__bridge void *)obj);
}

- (void *)getInvocationReturnValue {
    SEL watchdog = @selector(dog);
    NSMethodSignature *sig = [self methodSignatureForSelector:watchdog];
    NSInvocation *getWatchdogInvocation = [NSInvocation invocationWithMethodSignature:sig];
    getWatchdogInvocation.target = self;
    getWatchdogInvocation.selector = watchdog;
    [getWatchdogInvocation invoke];

    void *retVal = nil;
    [getWatchdogInvocation getReturnValue:&retVal];

    return retVal;
}

@end
