//
//  TSQCalendarRowCell.h
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarCell.h"

@protocol TSQCalendarRowCellDelegate;

/** The `TSQCalendarRowCell` class is a cell that represents one week in the calendar.
 
 Each of the seven columns can represent a day that's in this month, a day that's not in this month, a selected day, today, or an unselected day. The cell uses several images placed strategically to achieve the effect.
 */
@interface TSQCalendarRowCell : TSQCalendarCell

@property (nonatomic, strong) NSDate *beginningDate;

@property (nonatomic, weak) id<TSQCalendarRowCellDelegate> delegate;

/** Method to select a specific date within the week.

 This is funneled through and called by the calendar view, to facilitate deselection of other rows.
 
 @param date The date to select, or nil to deselect all columns.
 */
- (void)selectColumnForDate:(NSDate *)date;
- (void)selectColumnForDate:(NSDate *)date isInBetween:(BOOL)inBetween;

- (void) deselectAllColumns;

@end


@protocol TSQCalendarRowCellDelegate <NSObject>

- (BOOL) rowCell:(TSQCalendarRowCell *)cell shouldSelectDate:(NSDate *)date;
- (void) rowCell:(TSQCalendarRowCell *)cell didSelectDate:(NSDate *)date;

@end