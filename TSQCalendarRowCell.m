//
//  TSQCalendarRowCell.m
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarRowCell.h"
#import "TimesSquare.h"

@interface TSQCalendarRowCell () {
    NSInteger _currentMonth;
    NSDate *_startDate;
    NSDate *_endDate;
}

@property (nonatomic, strong) NSArray *dayButtons;
@property (nonatomic, assign) NSInteger indexOfTodayButton;
@property (nonatomic, strong) NSDateFormatter *dayFormatter;
@property (nonatomic, strong) NSDateFormatter *accessibilityFormatter;

@property (nonatomic, strong) NSDateComponents *todayDateComponents;

@end


@implementation TSQCalendarRowCell

- (id)initWithCalendarView:(TSQCalendarView *)calendarView reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithCalendarView:calendarView reuseIdentifier:reuseIdentifier];
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
        button.titleLabel.shadowOffset = self.shadowOffset;
        button.adjustsImageWhenDisabled = NO;
        [dayButtons addObject:button];
        [self.contentView addSubview:button];
    }
    self.dayButtons = dayButtons;
}

- (void) setBeginningDate:(NSDate *)date
{
    if(! date)
        return;
    
    date = [self.calendarView normalizeDateForDate:date];
    
    _beginningDate = date;
    _currentMonth = date.month;
    
    NSCalendar *calendar = TimesSquare.calendar;
    
    if (!self.dayButtons)
        [self createDayButtons];
    
    const NSInteger beginIndex = [self indexOfButtonForDate:date];
    
    // Calculate the start and end date
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.day = -beginIndex;
    _startDate = [calendar dateByAddingComponents:comps toDate:date options:0];
    comps.day = self.daysInWeek - beginIndex - 1;
    _endDate = [calendar dateByAddingComponents:comps toDate:date options:0];
    
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = 1;
    
    self.indexOfTodayButton = -1;
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        UIButton *button = self.dayButtons[index];
        
        if(index < beginIndex || date.month != _currentMonth) {
            button.hidden = true;
            continue;
        }
        
        
        button.hidden = false;

        NSString *title = [self.dayFormatter stringFromDate:date];
        NSString *accessibilityLabel = [self.accessibilityFormatter stringFromDate:date];
        [button setTitle:title forState:UIControlStateNormal];
        [self.calendarView.configuration configureButton:button forNormalDate:date];
        [button setAccessibilityLabel:accessibilityLabel];
        
        button.enabled = ![self.delegate respondsToSelector:@selector(rowCell:shouldSelectDate:)] || [self.delegate rowCell:self shouldSelectDate:date];
        
        NSDateComponents *thisDateComponents = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear
                                                           fromDate:date];
        if ([self.todayDateComponents isEqual:thisDateComponents]) {
            self.indexOfTodayButton = index;
            [self.calendarView.configuration configureButtonForToday:button];
        }
        
        // Next date
        date = [calendar dateByAddingComponents:offset toDate:date options:0];
    }
}

- (void) selectColumnForDate:(NSDate *)date isInBetween:(BOOL)inBetween {
    if(!date)
        return;
    
    date = [self.calendarView normalizeDateForDate:date];
    NSInteger newIndexOfSelectedButton = -1;
    if (date) {
        if ([_startDate earlierDate:date] == _startDate && [_endDate laterDate:date] == _endDate) {
            newIndexOfSelectedButton = [self indexOfButtonForDate:date];
            if (newIndexOfSelectedButton >= (NSInteger)self.daysInWeek) {
                newIndexOfSelectedButton = -1;
            }
        }
    }
    
    if (newIndexOfSelectedButton >= 0) {
        UIButton *button = self.dayButtons[newIndexOfSelectedButton];
        if(inBetween) {
            [self.calendarView.configuration configureButton:button forInBetweenDay:date];
        }
        else {
            [self.calendarView.configuration configureButton:button forSelectedDate:date];
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
        [self.calendarView.configuration configureButton:button forNormalDate:nil];
    }
}

- (NSInteger) indexOfButtonForDate:(NSDate *)date {
    return [TimesSquare.calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:date] - 1;
}

- (IBAction)dateButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = [self.dayButtons indexOfObject:sender];
    NSDate *selectedDate = [TimesSquare.calendar dateByAddingComponents:offset toDate:_startDate options:0];
    if([self.delegate respondsToSelector:@selector(rowCell:didSelectDate:)])
        [self.delegate rowCell:self didSelectDate:selectedDate];
}

- (IBAction)todayButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = self.indexOfTodayButton;
    NSDate *selectedDate = [TimesSquare.calendar dateByAddingComponents:offset toDate:_startDate options:0];
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
        _dayFormatter = [[NSDateFormatter alloc] init];
        _dayFormatter.calendar = TimesSquare.calendar;
        _dayFormatter.locale = TimesSquare.locale;
        _dayFormatter.dateFormat = @"d";
    }
    return _dayFormatter;
}

- (NSDateFormatter *)accessibilityFormatter;
{
    if (!_accessibilityFormatter) {
        _accessibilityFormatter = [[NSDateFormatter alloc] init];
        _accessibilityFormatter.calendar = TimesSquare.calendar;
        _accessibilityFormatter.locale = TimesSquare.locale;
        _accessibilityFormatter.dateStyle = NSDateFormatterLongStyle;
    }
    return _accessibilityFormatter;
}

- (NSDateComponents *)todayDateComponents;
{
    if (!_todayDateComponents) {
        self.todayDateComponents = [TimesSquare.calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear
                                                           fromDate:[NSDate date]];
    }
    return _todayDateComponents;
}

@end
