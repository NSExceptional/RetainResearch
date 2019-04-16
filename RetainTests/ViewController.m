//
//  ViewController.m
//  RetainTests
//
//  Created by Alexander Leontev on 16/04/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

#import "ViewController.h"

@interface DeallocWatchdog: NSObject
@end

@implementation DeallocWatchdog

- (void)dealloc {
    NSLog(@"%@", @"I was deallocated, woof");
}

@end

@interface ViewController ()

@property (nonatomic) DeallocWatchdog *watchdog;

@end

@implementation ViewController

- (IBAction)testBridgeTransfer:(id)sender {
    SEL watchdogSelector = @selector(watchdog);
    NSInvocation *getWatchdogInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:watchdogSelector]];
    getWatchdogInvocation.target = self;
    getWatchdogInvocation.selector = watchdogSelector;
    
    [getWatchdogInvocation invoke];
    
    id returnObject = nil;

    const void *objectReturnedFromMethod = nil;
    [getWatchdogInvocation getReturnValue:&objectReturnedFromMethod];
    returnObject = (__bridge_transfer id)objectReturnedFromMethod;
    NSLog(@"%@", returnObject);
}

- (IBAction)testBridge:(id)sender {
    SEL watchdogSelector = @selector(watchdog);
    NSInvocation *getWatchdogInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:watchdogSelector]];
    getWatchdogInvocation.target = self;
    getWatchdogInvocation.selector = watchdogSelector;
    
    [getWatchdogInvocation invoke];
    
    id returnObject = nil;
    
    const void *objectReturnedFromMethod = nil;
    [getWatchdogInvocation getReturnValue:&objectReturnedFromMethod];
    returnObject = (__bridge id)objectReturnedFromMethod;
    NSLog(@"%@", returnObject);
}

- (IBAction)testBridgeWithoutInvocation:(id)sender {
    const void *objectReturnedFromMethod = [self pointerToWatchdog];
    id returnObject = (__bridge id)objectReturnedFromMethod;
    NSLog(@"%@", returnObject);
}

- (IBAction)testBridgeTransferWithoutInvocation:(id)sender {
    const void *objectReturnedFromMethod = [self pointerToWatchdog];
    id returnObject = (__bridge_transfer id)objectReturnedFromMethod;
    NSLog(@"%@", returnObject);
}

- (const void *)pointerToWatchdog {
    NSString *safeStringPointer = [NSString stringWithFormat:@"%p", self.watchdog];
    
    const void *ptr = nil;
    unsigned long long tmp = 0;
    NSScanner *scanner = [NSScanner scannerWithString:safeStringPointer];
    [scanner scanHexLongLong:&tmp];
    ptr = (const void *)tmp;
    return ptr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.watchdog = [DeallocWatchdog new];
}


@end
