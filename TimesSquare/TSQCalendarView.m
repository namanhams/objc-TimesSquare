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
@property (nonatomic, strong) NSDate *firstDate;
@property (nonatomic, strong) NSDate *lastDate;
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
    if (indexPath.row == 0) {
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

- (void)setFirstDate:(NSDate *)firstDate clampToFirstOfMonth:(BOOL)clampToFirstOfMonth
{
    if(clampToFirstOfMonth)
        _firstDate = [self firstDateOfMonthForDate:firstDate];
    else
        _firstDate = [self normalizeDateForDate:firstDate];
}

- (void)setLastDate:(NSDate *)lastDate clampToLastOfMonth:(BOOL)clampToLastOfMonth
{
    if(clampToLastOfMonth)
        _lastDate = [self lastDateOfMonthForDate:lastDate];
    else
        _lastDate = [self normalizeDateForDate:lastDate];
}

- (void) selectDate:(NSDate *)date {
    self.selectedRange = nil;
    
    date = [self normalizeDateForDate:date];
    assert([self.firstDate earlierDate:date] == self.firstDate && [self.lastDate laterDate:date] == self.lastDate);
    
    [[self cellForRowAtDate:_selectedDate] deselectAllColumns];
    [[self cellForRowAtDate:date] selectColumnForDate:date];
    
    _selectedDate = date;
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

- (NSDate *) firstDateOfMonthForDate:(NSDate *)date {
    return [self clampDate:date toComponents: NSCalendarUnitMonth | NSCalendarUnitYear];
}

- (NSDate *) lastDateOfMonthForDate:(NSDate *)date {
    NSDate *firstOfMonth = [self firstDateOfMonthForDate:date];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.month = 1;
    offsetComponents.day = -1;
    return [self.calendar dateByAddingComponents:offsetComponents toDate:firstOfMonth options:0];
}

- (NSInteger) weekOfMonthFromDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:NSCalendarUnitWeekOfMonth fromDate:date];
    return comps.weekOfMonth;
}

- (NSInteger) monthFromDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:NSCalendarUnitMonth fromDate:date];
    return comps.month;
}

- (NSDate *) clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

- (NSDate *) normalizeDateForDate:(NSDate *)date {
    return [self clampDate:date toComponents: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear];
}

- (NSDate *)firstDateOfMonthForSection:(NSInteger)section
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = section;
    NSDate *dateOfMonth = [self.calendar dateByAddingComponents:offset toDate:self.firstDate options:0];
    NSDate *firstDateOfMonth = [self firstDateOfMonthForDate:dateOfMonth];
    if([firstDateOfMonth earlierDate:self.firstDate] == firstDateOfMonth)
        firstDateOfMonth = self.firstDate;
    
    return firstDateOfMonth;
}

- (NSDate *) lastDateOfMonthForSection:(NSInteger)section {
    NSDate *firstDate = [self firstDateOfMonthForSection:section];
    NSDate *lastDate = [self lastDateOfMonthForDate:firstDate];
    if([lastDate laterDate:self.lastDate] == lastDate)
        lastDate = self.lastDate;
    return lastDate;
}

#pragma mark UIView

- (void)layoutSubviews;
{
    self.tableView.frame = self.bounds;
}

#pragma mark UITableViewDataSource

- (TSQCalendarRowCell *)cellForRowAtDate:(NSDate *)date;
{
    return (TSQCalendarRowCell *)[self.tableView cellForRowAtIndexPath:[self indexPathForRowAtDate:date]];
}

- (NSIndexPath *)indexPathForRowAtDate:(NSDate *)date;
{
    if (!date) {
        return nil;
    }
    
    NSInteger section = [self sectionForDate:date];
    
    NSDate *firstDateOfMonth = [self firstDateOfMonthForSection:section];
    NSInteger firstWeek = [self weekOfMonthFromDate:firstDateOfMonth];
    NSInteger targetWeek = [self weekOfMonthFromDate:date];
    NSInteger row = targetWeek - firstWeek + 1; // add 1 for the section header
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSInteger)sectionForDate:(NSDate *)date;
{
    // Calculate month index
    NSDateComponents *comps_1 = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self.firstDate];
    NSInteger monthIndex_1 = comps_1.year * 12 + comps_1.month;
    NSDateComponents *comps_2 = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:date];
    NSInteger monthIndex_2 = comps_2.year * 12 + comps_2.month;
    
    return monthIndex_2 - monthIndex_1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return [self sectionForDate:self.lastDate] - [self sectionForDate:self.firstDate] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSDate *firstDate = [self firstDateOfMonthForSection:section];
    NSDate *lastDate = [self lastDateOfMonthForSection:section];
    NSInteger firstWeek = [self weekOfMonthFromDate:firstDate];
    NSInteger lastWeek = [self weekOfMonthFromDate:lastDate];
    NSInteger weeks = lastWeek - firstWeek + 1;
    return weeks + 1; // add 1 for section header
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == 0)
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
    NSDate *firstDateOfMonth = [self firstDateOfMonthForSection:indexPath.section];
    
    [(TSQCalendarCell *)cell setFirstOfMonth:firstDateOfMonth];
    
    if (indexPath.row > 0) {
        // Find the first date of the cell to be displayed
        NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstDateOfMonth];
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.day = 1 - ordinalityOfFirstDay;
        dateComponents.week = indexPath.row - 1;
        NSDate *cellBeginningDate = [self.calendar dateByAddingComponents:dateComponents toDate:firstDateOfMonth options:0];
        if([cellBeginningDate earlierDate:firstDateOfMonth] == cellBeginningDate)
            cellBeginningDate = firstDateOfMonth;
        if([cellBeginningDate laterDate:self.lastDate] == cellBeginningDate)
            cellBeginningDate = self.lastDate;
        
        [(TSQCalendarRowCell *)cell setBeginningDate:cellBeginningDate];
        
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
            
            if([self.delegate respondsToSelector:@selector(calendarView:didSelectRange:)])
                [self.delegate calendarView:self didSelectRange:range];
        }
        else {
            [self selectDate:startOfDay];
        }
    }
    else {
        [self selectDate:startOfDay];
    }
}

@end
