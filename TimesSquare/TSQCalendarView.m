//
//  TSQCalendarState.m
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarView.h"
#import "TSQCalendarMonthHeaderCell.h"
#import "TSQCalendarRowCell.h"
#import "TSQCalendarAppearance.h"

@interface TSQCalendarView () <UITableViewDataSource, UITableViewDelegate, TSQCalendarRowCellDelegate> {
    NSDate *_selectedDate;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TSQCalendarMonthHeaderCell *headerView; // nil unless pinsHeaderToTop == YES
@end


@implementation TSQDateRange

- (instancetype) initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    self = [super init];
    _start = startDate;
    _end = endDate;
    
    assert(_start);
    assert(_end);
    
    return self;
}

@end

@implementation TSQCalendarView

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }

    [self _TSQCalendarView_commonInit];

    return self;
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    [self _TSQCalendarView_commonInit];
    
    return self;
}

- (void)_TSQCalendarView_commonInit;
{
    self.appearance = [TSQCalendarAppearance defaultAppearance];

    _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tableView.delaysContentTouches = true;
    [self addSubview:_tableView];    
}

- (void)dealloc;
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (NSCalendar *)calendar;
{
    if (!_calendar) {
        self.calendar = [NSCalendar currentCalendar];
    }
    return _calendar;
}

- (Class)headerCellClass;
{
    if (!_headerCellClass) {
        self.headerCellClass = [TSQCalendarMonthHeaderCell class];
    }
    return _headerCellClass;
}

- (Class)rowCellClass;
{
    if (!_rowCellClass) {
        self.rowCellClass = [TSQCalendarRowCell class];
    }
    return _rowCellClass;
}

- (Class)cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == 0 && !self.pinsHeaderToTop) {
        return [self headerCellClass];
    } else {
        return [self rowCellClass];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    [self.tableView setBackgroundColor:backgroundColor];
}

- (void)setPinsHeaderToTop:(BOOL)pinsHeaderToTop;
{
    _pinsHeaderToTop = pinsHeaderToTop;
    [self setNeedsLayout];
}

- (void)setFirstDate:(NSDate *)firstDate;
{
    // clamp to the beginning of its month
    _firstDate = [self clampDate:firstDate toComponents:NSMonthCalendarUnit|NSYearCalendarUnit];
}

- (void)setLastDate:(NSDate *)lastDate;
{
    // clamp to the end of its month
    NSDate *firstOfMonth = [self clampDate:lastDate toComponents:NSMonthCalendarUnit|NSYearCalendarUnit];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.month = 1;
    offsetComponents.day = -1;
    _lastDate = [self.calendar dateByAddingComponents:offsetComponents toDate:firstOfMonth options:0];
}

- (void) selectDate:(NSDate *)date {
    self.selectedRange = nil;
    
    // clamp to beginning of its day
    NSDate *startOfDay = [self clampDate:date toComponents:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit];
    assert([self.firstDate earlierDate:startOfDay] == self.firstDate && [self.lastDate laterDate:startOfDay] == self.lastDate);
    
    [[self cellForRowAtDate:_selectedDate] deselectAllColumns];
    [[self cellForRowAtDate:startOfDay] selectColumnForDate:startOfDay];
    
    _selectedDate = startOfDay;
}


- (void) setSelectedRange:(TSQDateRange *)selectedRange {
    if(_selectedRange == selectedRange)
        return;
    
    if(_selectedRange != nil) {
        // Unselected the old range
        NSInteger numberOfDates = [self.calendar components:NSCalendarUnitDay fromDate:_selectedRange.start toDate:_selectedRange.end options:0].day;
        NSDateComponents *components = [[NSDateComponents alloc] init];
        for(int i = 0; i <= numberOfDates; i++) {
            components.day = i;
            NSDate *date = [self.calendar dateByAddingComponents:components toDate:_selectedRange.start options:0];
            TSQCalendarRowCell *cell = [self cellForRowAtDate:date];
            [cell deselectAllColumns];
        }
    }

    _selectedRange = selectedRange;
    
    if(_selectedRange != nil) {
        NSInteger numberOfDates = [self.calendar components:NSCalendarUnitDay fromDate:_selectedRange.start toDate:_selectedRange.end options:0].day;
        NSDateComponents *components = [[NSDateComponents alloc] init];
        for(int i = 0; i <= numberOfDates; i++) {
            components.day = i;
            NSDate *date = [self.calendar dateByAddingComponents:components toDate:_selectedRange.start options:0];
            TSQCalendarRowCell *cell = [self cellForRowAtDate:date];
            if(i > 0 && i < numberOfDates) {
                [cell selectColumnForDate:date isInBetween:true];
            }
            else {
                [cell selectColumnForDate:date isInBetween:false];
            }
        }
    }
    
    _selectedDate = nil;
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
  NSInteger section = [self sectionForDate:date];
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

- (void)scrollDate:(NSDate *)date toPosition:(UITableViewScrollPosition)position animated:(BOOL)animated {
    NSIndexPath *cellPath = [self indexPathForRowAtDate:date];

    [self.tableView scrollToRowAtIndexPath:cellPath
                          atScrollPosition:position
                                  animated:animated];
}



- (TSQCalendarMonthHeaderCell *)makeHeaderCellWithIdentifier:(NSString *)identifier;
{
    TSQCalendarMonthHeaderCell *cell = [[[self headerCellClass] alloc] initWithCalendar:self.calendar reuseIdentifier:identifier];
    cell.backgroundColor = self.backgroundColor;
    cell.calendarView = self;
    return cell;
}

#pragma mark Calendar calculations

- (NSDate *)firstOfMonthForSection:(NSInteger)section;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = section;
    return [self.calendar dateByAddingComponents:offset toDate:self.firstDate options:0];
}

- (TSQCalendarRowCell *)cellForRowAtDate:(NSDate *)date;
{
    return (TSQCalendarRowCell *)[self.tableView cellForRowAtIndexPath:[self indexPathForRowAtDate:date]];
}

- (NSInteger)sectionForDate:(NSDate *)date;
{
  return [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDate toDate:date options:0].month;
}

- (NSIndexPath *)indexPathForRowAtDate:(NSDate *)date;
{
    if (!date) {
        return nil;
    }
    
    NSInteger section = [self sectionForDate:date];
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    
    NSInteger firstWeek = [self.calendar components:NSWeekOfMonthCalendarUnit fromDate:firstOfMonth].weekOfMonth;
    NSInteger targetWeek = [self.calendar components:NSWeekOfMonthCalendarUnit fromDate:date].weekOfMonth;
    
    return [NSIndexPath indexPathForRow:(self.pinsHeaderToTop ? 0 : 1) + targetWeek - firstWeek inSection:section];
}

#pragma mark UIView

- (void)layoutSubviews;
{
    if (self.pinsHeaderToTop) {
        if (!self.headerView) {
            self.headerView = [self makeHeaderCellWithIdentifier:nil];
            if (self.tableView.visibleCells.count > 0) {
                self.headerView.firstOfMonth = [self.tableView.visibleCells[0] firstOfMonth];
            } else {
                self.headerView.firstOfMonth = self.firstDate;
            }
            [self addSubview:self.headerView];
        }
        CGRect bounds = self.bounds;
        CGRect headerRect;
        CGRect tableRect;
        CGRectDivide(bounds, &headerRect, &tableRect, [[self headerCellClass] cellHeight], CGRectMinYEdge);
        self.headerView.frame = headerRect;
        self.tableView.frame = tableRect;
    } else {
        if (self.headerView) {
            [self.headerView removeFromSuperview];
            self.headerView = nil;
        }
        self.tableView.frame = self.bounds;
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1 + [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDate toDate:self.lastDate options:0].month;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSRange rangeOfWeeks = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstOfMonth];
    return (self.pinsHeaderToTop ? 0 : 1) + rangeOfWeeks.length;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == 0 && !self.pinsHeaderToTop)
    {
        // month header
        static NSString *identifier = @"header";
        TSQCalendarMonthHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [self makeHeaderCellWithIdentifier:identifier];
        }
        return cell;
    }
    else
    {
        static NSString *identifier = @"row";
        TSQCalendarRowCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[self rowCellClass] alloc] initWithCalendar:self.calendar reuseIdentifier:identifier];
            cell.backgroundColor = self.backgroundColor;
            cell.calendarView = self;
            cell.delegate = self;
        }
        return cell;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    [(TSQCalendarCell *)cell setFirstOfMonth:firstOfMonth];
    if (indexPath.row > 0 || self.pinsHeaderToTop) {
        NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.day = 1 - ordinalityOfFirstDay;
        dateComponents.week = indexPath.row - (self.pinsHeaderToTop ? 0 : 1);
        [(TSQCalendarRowCell *)cell setBeginningDate:[self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0]];
        [(TSQCalendarRowCell *)cell deselectAllColumns];
        if(_selectedDate) {
            [(TSQCalendarRowCell *)cell selectColumnForDate:_selectedDate];
        }
        else if(_selectedRange) {
            NSInteger numberOfDates = [self.calendar components:NSCalendarUnitDay fromDate:_selectedRange.start toDate:_selectedRange.end options:0].day;
            NSDateComponents *components = [[NSDateComponents alloc] init];
            for(int i = 0; i <= numberOfDates; i++) {
                components.day = i;
                NSDate *date = [self.calendar dateByAddingComponents:components toDate:_selectedRange.start options:0];
                if(i > 0 && i < numberOfDates) {
                    [(TSQCalendarRowCell *)cell selectColumnForDate:date isInBetween:true];
                }
                else {
                    [(TSQCalendarRowCell *)cell selectColumnForDate:date isInBetween:false];
                }
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [[self cellClassForRowAtIndexPath:indexPath] cellHeight];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
{
    if (self.pagingEnabled) {
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:*targetContentOffset];
        // If the target offset is at the third row or later, target the next month; otherwise, target the beginning of this month.
        NSInteger section = indexPath.section;
        if (indexPath.row > 2) {
            section++;
        }
        CGRect sectionRect = [self.tableView rectForSection:section];
        *targetContentOffset = sectionRect.origin;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if (self.pinsHeaderToTop && self.tableView.visibleCells.count > 0) {
        TSQCalendarCell *cell = self.tableView.visibleCells[0];
        self.headerView.firstOfMonth = cell.firstOfMonth;
    }
}

- (NSDate *)clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

#pragma mark TSQCalendarRowCellDelegate

- (BOOL) rowCell:(TSQCalendarRowCell *)cell shouldSelectDate:(NSDate *)date {
    return true;
}

- (void) rowCell:(TSQCalendarRowCell *)cell didSelectDate:(NSDate *)date {
    NSDate *startOfDay = [self clampDate:date toComponents:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit];
    if ([self.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)] && ![self.delegate calendarView:self shouldSelectDate:startOfDay])
        return;
    
    if(self.selectedRange != nil) {
        [self selectDate:startOfDay];
        return;
    }
    
    if(_selectedDate != nil) {
        if([_selectedDate earlierDate:startOfDay] == _selectedDate) {
            TSQDateRange *range = [[TSQDateRange alloc] initWithStartDate:_selectedDate endDate:startOfDay];
            self.selectedRange = range;
        }
        else {
            [self selectDate:startOfDay];
        }
    }
    else {
        [self selectDate:startOfDay];
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.delegate calendarView:self didSelectDate:startOfDay];
    }
}

@end
