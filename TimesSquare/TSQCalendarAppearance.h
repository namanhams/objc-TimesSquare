//
//  TSQCalendarAppearance.h
//  TimesSquare
//
//  Created by Pham Hoang Le on 9/10/15.
//  Copyright © 2015 Square. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TSQCalendarAppearance : NSObject

/** @name Images */

@property (nonatomic, strong) UIImage *rowBackgroundImage;

/** The background image for a day that's selected.
 
 This is blue in the system's built-in Calendar app. You probably want to use a stretchable image.
 */
@property (nonatomic, strong) UIImage *selectedBackgroundImage;

/** The background image for a day that's "today".
 
 This is dark gray in the system's built-in Calendar app. You probably want to use a stretchable image.
 */
@property (nonatomic, strong) UIImage *todayBackgroundImage;

@property (nonatomic, strong) UIImage *normalBackgroundImage;

@property (nonatomic, strong) UIImage *inBetweenBackgroundImage;

@property (nonatomic, strong) UIColor *selectedTextColor;

@property (nonatomic, strong) UIColor *todayTextColor;

@property (nonatomic, strong) UIColor *normalTextColor;

@property (nonatomic, strong) UIColor *inBetweenTextColor;

+ (instancetype) defaultAppearance;

@end
