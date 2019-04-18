//
//  Watchdog.m
//  Tests
//
//  Created by Tanner on 4/18/19.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

#import "Watchdog.h"
#import <XCTest/XCTest.h>

@implementation DeallocWatchdog

- (id)init {
    self->_expectation = [[XCTestExpectation alloc] initWithDescription:self.description];
    return self;
}

- (void)dealloc {
    [_expectation fulfill];
}

@end
