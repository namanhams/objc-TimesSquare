//
//  NSDate+TimeSquare.h
//  TimesSquare
//
//  Created by Pham Hoang Le on 19/10/15.
//  Copyright © 2015 Square. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TimeSquare)

+ (NSDate *) firstDateOfMonthForDate:(NSDate *)date;
+ (NSDate *) lastDateOfMonthForDate:(NSDate *)date;

- (NSInteger) weekOfMonth;
- (NSInteger) month;
- (NSDate *) clampToComponents:(NSUInteger)unitFlags;

@end
