//
//  NSDate+TimeSquare.m
//  TimesSquare
//
//  Created by Pham Hoang Le on 19/10/15.
//  Copyright © 2015 Square. All rights reserved.
//

#import "NSDate+TimeSquare.h"
#import "TimesSquare.h"

@implementation NSDate (TimeSquare)

+ (NSDate *) firstDateOfMonthForDate:(NSDate *)date {
    return [date clampToComponents: NSCalendarUnitMonth | NSCalendarUnitYear];
}

+ (NSDate *) lastDateOfMonthForDate:(NSDate *)date {
    NSDate *firstOfMonth = [self firstDateOfMonthForDate:date];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.month = 1;
    offsetComponents.day = -1;
    return [TimesSquare.calendar dateByAddingComponents:offsetComponents toDate:firstOfMonth options:0];
}

- (NSInteger) weekOfMonth {
    NSDateComponents *comps = [TimesSquare.calendar components:NSCalendarUnitWeekOfMonth fromDate:self];
    return comps.weekOfMonth;
}

- (NSInteger) month {
    NSDateComponents *comps = [TimesSquare.calendar components:NSCalendarUnitMonth fromDate:self];
    return comps.month;
}

- (NSDate *) clampToComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [TimesSquare.calendar components:unitFlags fromDate:self];
    return [TimesSquare.calendar dateFromComponents:components];
}

- (NSInteger) numberOfDaysFromDate:(NSDate *)date {
    return [TimesSquare.calendar components:NSCalendarUnitDay fromDate:date toDate:self options:0].day;
}

@end
