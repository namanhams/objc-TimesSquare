//
//  TimesSquare.h
//  TimesSquare
//
//  Created by Jim Puls on 12/5/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarMonthHeaderCell.h"
#import "TSQCalendarRowCell.h"
#import "TSQCalendarView.h"
#import "TSQCalendarConfiguration.h"
#import "NSDate+TimeSquare.h"

#import <Foundation/Foundation.h>

@interface TimesSquare: NSObject

+ (void) setCalendar:(NSCalendar *)calendar andLocale:(NSLocale *)locale;
+ (NSCalendar *) calendar;
+ (NSLocale *) locale;

@end