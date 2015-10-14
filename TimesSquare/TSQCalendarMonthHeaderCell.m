//
//  TSQCalendarMonthHeaderCell.m
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarMonthHeaderCell.h"
#import "TSQCalendarView.h"

static const CGFloat TSQCalendarMonthHeaderCellMonthsHeight = 20.f;


@interface TSQCalendarMonthHeaderCell ()
@property (nonatomic, strong) NSArray *headerLabels;
@end


@implementation TSQCalendarMonthHeaderCell

- (id)initWithCalendarView:(TSQCalendarView *)calendarView reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithCalendarView:calendarView reuseIdentifier:reuseIdentifier];
    return self;
}


+ (CGFloat)cellHeight;
{
    return 65.0f;
}

- (NSArray *) headerLabels {
    if(!_headerLabels) {
        [self createHeaderLabels];
    }
    
    return _headerLabels;
}

- (void)createHeaderLabels;
{
    NSDate *referenceDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = 1;
    NSMutableArray *headerLabels = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    dayFormatter.calendar = self.calendarView.calendar;
    dayFormatter.dateFormat = @"cccccc";
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        [headerLabels addObject:@""];
    }
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        NSInteger ordinality = [self.calendarView.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:referenceDate];
        UILabel *label = [[UILabel alloc] initWithFrame:self.frame];
        label.textAlignment = UITextAlignmentCenter;
        label.text = [self headerLabelForDate:referenceDate];
        label.font = [UIFont boldSystemFontOfSize:12.f];
        label.backgroundColor = self.backgroundColor;
        label.textColor = self.textColor;
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = self.shadowOffset;
        [label sizeToFit];
        headerLabels[ordinality - 1] = label;
        [self.contentView addSubview:label];
        
        referenceDate = [self.calendarView.calendar dateByAddingComponents:offset toDate:referenceDate options:0];
    }
    
    self.headerLabels = headerLabels;
    self.textLabel.textAlignment = UITextAlignmentCenter;
    self.textLabel.textColor = self.textColor;
    self.textLabel.shadowColor = [UIColor whiteColor];
    self.textLabel.shadowOffset = self.shadowOffset;
}

- (NSString *) headerLabelForDate:(NSDate *)referenceDate {
    return [self.calendarView.weekDayFormatter stringFromDate:referenceDate];
}

- (void)layoutSubviews;
{
    [super layoutSubviews];

    CGRect bounds = self.contentView.bounds;
    bounds.size.height -= TSQCalendarMonthHeaderCellMonthsHeight;
    self.textLabel.frame = CGRectOffset(bounds, 0.0f, 5.0f);
}

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
{
    UILabel *label = self.headerLabels[index];
    CGRect labelFrame = rect;
    labelFrame.size.height = TSQCalendarMonthHeaderCellMonthsHeight;
    labelFrame.origin.y = self.bounds.size.height - TSQCalendarMonthHeaderCellMonthsHeight;
    label.frame = labelFrame;
}

- (void)setFirstOfMonth:(NSDate *)firstOfMonth;
{
    [super setFirstOfMonth:firstOfMonth];
    self.textLabel.text = [self.calendarView.monthDateFormatter stringFromDate:firstOfMonth];
    self.accessibilityLabel = self.textLabel.text;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    for (UILabel *label in self.headerLabels) {
        label.backgroundColor = backgroundColor;
    }
}

@end
