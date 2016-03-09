//
//  TimeSquare.m
//  Kaligo
//
//  Created by Pham Hoang Le on 9/3/16.
//  Copyright © 2016 Kaligo. All rights reserved.
//

#import "TimesSquare.h"

@implementation TimesSquare

static NSCalendar *_calendar = nil;
static NSLocale *_locale = nil;

+ (void) setCalendar:(NSCalendar *)calendar andLocale:(NSLocale *)locale {
    _calendar = calendar;
    _locale = locale;
}

+ (NSCalendar *) calendar {
    return _calendar;
}

+ (NSLocale *) locale {
    return _locale;
}

@end
