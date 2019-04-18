//
//  Watchdog.h
//  Tests
//
//  Created by Tanner on 4/18/19.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XCTestExpectation;

@interface DeallocWatchdog: NSObject
@property (nonatomic, readonly) XCTestExpectation *expectation;
@end
