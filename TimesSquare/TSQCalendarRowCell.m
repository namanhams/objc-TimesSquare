//
//  TSQCalendarRowCell.m
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarRowCell.h"
#import "TSQCalendarView.h"
#import "TSQCalendarAppearance.h"

@interface TSQCalendarRowCell ()

@property (nonatomic, strong) NSArray *dayButtons;
@property (nonatomic, assign) NSInteger indexOfTodayButton;
@property (nonatomic, strong) NSDateFormatter *dayFormatter;
@property (nonatomic, strong) NSDateFormatter *accessibilityFormatter;

@property (nonatomic, strong) NSDateComponents *todayDateComponents;
@property (nonatomic) NSInteger monthOfBeginningDate;

@end


@implementation TSQCalendarRowCell

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithCalendar:calendar reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)createDayButtons;
{
    NSMutableArray *dayButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        [button addTarget:self action:@selector(dateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:19.f];
        button.titleLabel.shadowOffset = self.shadowOffset;
        button.adjustsImageWhenDisabled = NO;
        [button setTitleColor:self.calendarView.appearance.normalTextColor forState:UIControlStateNormal];
        
        [dayButtons addObject:button];
        [self.contentView addSubview:button];
    }
    self.dayButtons = dayButtons;
}

- (void)setBeginningDate:(NSDate *)date;
{
    _beginningDate = date;
    
    if (!self.dayButtons) {
        [self createDayButtons];
    }

    NSDateComponents *offset = [NSDateComponents new];
    offset.day = 1;

    self.indexOfTodayButton = -1;
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        NSString *title = [self.dayFormatter stringFromDate:date];
        NSString *accessibilityLabel = [self.accessibilityFormatter stringFromDate:date];
        UIButton *button = self.dayButtons[index];
        
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:self.calendarView.appearance.normalTextColor forState:UIControlStateNormal];
        [button setAccessibilityLabel:accessibilityLabel];
        
        NSDateComponents *thisDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
        NSInteger thisDayMonth = thisDateComponents.month;
        if (self.monthOfBeginningDate != thisDayMonth)
        {
            button.hidden = true;
        }
        else
        {
            button.hidden = false;
            button.enabled = ![self.delegate respondsToSelector:@selector(rowCell:shouldSelectDate:)] || [self.delegate rowCell:self shouldSelectDate:date];
            if ([self.todayDateComponents isEqual:thisDateComponents]) {
                self.indexOfTodayButton = index;
                [button setTitleColor:self.calendarView.appearance.todayTextColor forState:UIControlStateNormal];
                [button setBackgroundImage:self.calendarView.appearance.todayBackgroundImage forState:UIControlStateNormal];
            }
        }

        date = [self.calendar dateByAddingComponents:offset toDate:date options:0];
    }
}

- (void) selectColumnForDate:(NSDate *)date isInBetween:(BOOL)inBetween {
    if(!date)
        return;
    
    NSInteger newIndexOfSelectedButton = -1;
    if (date) {
        NSInteger thisDayMonth = [self.calendar components:NSMonthCalendarUnit fromDate:date].month;
        if (self.monthOfBeginningDate == thisDayMonth) {
            newIndexOfSelectedButton = [self.calendar components:NSDayCalendarUnit fromDate:self.beginningDate toDate:date options:0].day;
            if (newIndexOfSelectedButton >= (NSInteger)self.daysInWeek) {
                newIndexOfSelectedButton = -1;
            }
        }
    }
    
    if (newIndexOfSelectedButton >= 0) {
        UIButton *button = self.dayButtons[newIndexOfSelectedButton];
        if(inBetween) {
            [button setTitleColor:self.calendarView.appearance.inBetweenTextColor forState:UIControlStateNormal];
            [button setBackgroundImage:self.calendarView.appearance.inBetweenBackgroundImage forState:UIControlStateNormal];
        }
        else {
            [button setTitleColor:self.calendarView.appearance.selectedTextColor forState:UIControlStateNormal];
            [button setBackgroundImage:self.calendarView.appearance.selectedBackgroundImage forState:UIControlStateNormal];
        }
    }
}

- (void)selectColumnForDate:(NSDate *)date
{
    [self selectColumnForDate:date isInBetween:false];
}

- (void) deselectAllColumns {
    for(int i = 0; i < self.dayButtons.count; i++) {
        UIButton *button = self.dayButtons[i];
        [button setTitleColor:self.calendarView.appearance.normalTextColor forState:UIControlStateNormal];
        [button setBackgroundImage:self.calendarView.appearance.normalBackgroundImage forState:UIControlStateNormal];
    }
}

- (IBAction)dateButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = [self.dayButtons indexOfObject:sender];
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
    if([self.delegate respondsToSelector:@selector(rowCell:didSelectDate:)])
        [self.delegate rowCell:self didSelectDate:selectedDate];
}

- (IBAction)todayButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = self.indexOfTodayButton;
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
    if([self.delegate respondsToSelector:@selector(rowCell:didSelectDate:)])
        [self.delegate rowCell:self didSelectDate:selectedDate];
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    self.backgroundView.frame = self.bounds;
}

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
{
    UIButton *dayButton = self.dayButtons[index];
    dayButton.frame = rect;
}

- (NSDateFormatter *)dayFormatter;
{
    if (!_dayFormatter) {
        _dayFormatter = [NSDateFormatter new];
        _dayFormatter.calendar = self.calendar;
        _dayFormatter.dateFormat = @"d";
    }
    return _dayFormatter;
}

- (NSDateFormatter *)accessibilityFormatter;
{
    if (!_accessibilityFormatter) {
        _accessibilityFormatter = [NSDateFormatter new];
        _accessibilityFormatter.calendar = self.calendar;
        _accessibilityFormatter.dateStyle = NSDateFormatterLongStyle;
    }
    return _accessibilityFormatter;
}

- (NSInteger)monthOfBeginningDate;
{
    if (!_monthOfBeginningDate) {
        _monthOfBeginningDate = [self.calendar components:NSMonthCalendarUnit fromDate:self.firstOfMonth].month;
    }
    return _monthOfBeginningDate;
}

- (void)setFirstOfMonth:(NSDate *)firstOfMonth;
{
    [super setFirstOfMonth:firstOfMonth];
    self.monthOfBeginningDate = 0;
}

- (NSDateComponents *)todayDateComponents;
{
    if (!_todayDateComponents) {
        self.todayDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    }
    return _todayDateComponents;
}

@end
