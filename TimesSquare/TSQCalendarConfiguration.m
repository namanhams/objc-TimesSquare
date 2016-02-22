//
//  TSQCalendarConfiguration.m
//  TimesSquare
//
//  Created by Pham Hoang Le on 9/10/15.
//  Copyright © 2015 Square. All rights reserved.
//

#import "TSQCalendarConfiguration.h"

@implementation TSQCalendarConfiguration

- (id) init {
    self.calendar = [NSCalendar currentCalendar];
    self.locale = [NSLocale currentLocale];
    
    self.normalTextColor = [UIColor darkGrayColor];
    self.todayTextColor = [UIColor blueColor];
    self.selectedTextColor = [UIColor whiteColor];
    self.inBetweenTextColor = self.normalTextColor;
    
    self.selectedBackgroundColor = [UIColor blueColor];
    self.inBetweenBackgroundColor = [self.selectedBackgroundColor colorWithAlphaComponent:0.2];
    self.dateFont = [UIFont systemFontOfSize:14];
    
    return self;
}

- (void) configureButton:(UIButton *)button forSelectedDate:(NSDate *)date {
    if(self.selectedBackgroundImage)
        [button setBackgroundImage:self.selectedBackgroundImage forState:UIControlStateNormal];
    else
        [button setBackgroundColor:self.selectedBackgroundColor];
    
    [button setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
    [button.titleLabel setFont:self.dateFont];
}

- (void) configureButtonForToday:(UIButton *)button {
    if(self.todayBackgroundImage)
        [button setBackgroundImage:self.todayBackgroundImage forState:UIControlStateNormal];
    else
        [button setBackgroundColor:self.todayBackgroundColor];
    
    [button setTitleColor:self.todayTextColor forState:UIControlStateNormal];
    [button.titleLabel setFont:self.dateFont];
}

- (void) configureButton:(UIButton *)button forNormalDate:(NSDate *)date {
    if(self.normalBackgroundImage)
        [button setBackgroundImage:self.normalBackgroundImage forState:UIControlStateNormal];
    else
        [button setBackgroundColor:self.normalBackgroundColor];
    
    [button setTitleColor:self.normalTextColor forState:UIControlStateNormal];
    [button.titleLabel setFont:self.dateFont];
}

- (void) configureButton:(UIButton *)button forInBetweenDay:(NSDate *)date {
    if(self.inBetweenBackgroundImage)
        [button setBackgroundImage:self.inBetweenBackgroundImage forState:UIControlStateNormal];
    else
        [button setBackgroundColor:self.inBetweenBackgroundColor];
    
    [button setTitleColor:self.inBetweenTextColor forState:UIControlStateNormal];
    [button.titleLabel setFont:self.dateFont];
}

@end


@implementation UIImage (Extension)

+ (UIImage *) imageFromColor:(UIColor *)color
{
    UIView *selectedBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    selectedBackground.backgroundColor = color;
    
    UIGraphicsBeginImageContext(CGSizeMake(selectedBackground.frame.size.width, selectedBackground.frame.size.height));
    [selectedBackground drawViewHierarchyInRect:CGRectMake(0, 0, selectedBackground.frame.size.width, selectedBackground.frame.size.height) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end