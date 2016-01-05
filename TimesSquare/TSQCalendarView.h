//
//  TSQCalendarState.h
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <UIKit/UIKit.h>


@protocol TSQCalendarViewDelegate;
@protocol TSQCalendarAppearanceDelegate;
@class TSQCalendarAppearance;

@interface TSQDateRange : NSObject
@property (nonatomic, readonly) NSDate *start;
@property (nonatomic, readonly) NSDate *end;
- (instancetype) initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
@end

/** The `TSQCalendarView` class displays a monthly calendar in a self-contained scrolling view. It supports any calendar that `NSCalendar` supports.
 
 The implementation and usage are very similar to `UITableView`: the app provides reusable cells via a data source and controls behavior via a delegate. See `TSQCalendarCell` for a cell superclass.
 */
@interface TSQCalendarView : UIView

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) TSQDateRange *selectedRange;

/** @name Calendar Configuration */

/** The calendar type to use when displaying.
 
 If not set, this defaults to `[NSCalendar currentCalendar]`.
 */
@property (nonatomic, readonly, strong) NSCalendar *calendar;

@property (nonatomic, strong) NSDateFormatter *monthDateFormatter;
@property (nonatomic, strong) NSDateFormatter *weekDayFormatter;


@property (nonatomic, weak) IBOutlet id<TSQCalendarViewDelegate> delegate;

/** Whether or not the calendar snaps to begin a month at the top of its bounds.
 
 This property is roughly equivalent to the one defined on `UIScrollView` except the snapping is to months rather than integer multiples of the view's bounds.
 */
@property (nonatomic) BOOL pagingEnabled;

/** The distance from the edges of the view to where the content begins.
 
 This property is equivalent to the one defined on `UIScrollView`.
 */
@property (nonatomic) UIEdgeInsets contentInset;

/** The point on the calendar where the currently-visible region starts.
 
 This property is equivalent to the one defined on `UIScrollView`.
 */
@property (nonatomic) CGPoint contentOffset;

/** The cell class to use for month headers.
 
 Since there's very little configuration to be done for each cell, this can be set as a shortcut to implementing a data source.
 The class should be a subclass of `TSQCalendarMonthHeaderCell` or at least implement all of its methods.
 */
@property (nonatomic, strong) Class headerCellClass;

/** The cell class to use for week rows.
 
 Since there's very little configuration to be done for each cell, this can be set as a shortcut to implementing a data source.
 The class should be a subclass of `TSQCalendarRowCell` or at least implement all of its methods.
 */
@property (nonatomic, strong) Class rowCellClass;

@property (nonatomic, strong) id<TSQCalendarAppearanceDelegate> appearanceDelegate;

- (void) setFirstDate:(NSDate *)firstDate clampToFirstOfMonth:(BOOL)clampToFirstOfMonth;
- (void) setLastDate:(NSDate *)lastDate clampToLastOfMonth:(BOOL)clampToLastOfMonth;

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;
- (void)scrollDate:(NSDate *)date toPosition:(UITableViewScrollPosition)position animated:(BOOL)animated;

// Date helpers
- (NSDate *) normalizeDateForDate:(NSDate *)date;

@end

/** The methods in the `TSQCalendarViewDelegate` protocol allow the adopting delegate to either prevent a day from being selected or respond to it.
 */
@protocol TSQCalendarViewDelegate <NSObject>

@optional

- (BOOL)calendarView:(TSQCalendarView *)calendarView shouldSelectRangeFirstDate:(NSDate *)date;
- (BOOL)calendarView:(TSQCalendarView *)calendarView shouldSelectRangeSecondDate:(NSDate *)date;
- (void) calendarView:(TSQCalendarView *)calendarView didSelectRange:(TSQDateRange *)range;

@end
