//
//  TSQCalendarConfiguration.h
//  TimesSquare
//
//  Created by Pham Hoang Le on 9/10/15.
//  Copyright © 2015 Square. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TSQCalendarConfiguration : NSObject

//
//  UI configuration
//

@property (nonatomic, strong) UIImage *rowBackgroundImage;

@property (nonatomic, strong) UIImage *selectedBackgroundImage;
@property (nonatomic, strong) UIImage *todayBackgroundImage;
@property (nonatomic, strong) UIImage *normalBackgroundImage;
@property (nonatomic, strong) UIImage *inBetweenBackgroundImage;

@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, strong) UIColor *todayBackgroundColor;
@property (nonatomic, strong) UIColor *normalBackgroundColor;
@property (nonatomic, strong) UIColor *inBetweenBackgroundColor;

@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *todayTextColor;
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *inBetweenTextColor;

@property (nonatomic, strong) UIFont *dateFont;

- (void) configureButton:(UIButton *)button forSelectedDate:(NSDate *)date;
- (void) configureButtonForToday:(UIButton *)button;
- (void) configureButton:(UIButton *)button forNormalDate:(NSDate *)date;
- (void) configureButton:(UIButton *)button forInBetweenDay:(NSDate *)date;

@end

@interface UIImage (Extension)
+ (UIImage *) imageFromColor:(UIColor *)color;
- (UIImage *) imageByApplyingAlpha:(CGFloat) alpha;
@end