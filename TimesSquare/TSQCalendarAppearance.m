//
//  TSQCalendarAppearance.m
//  TimesSquare
//
//  Created by Pham Hoang Le on 9/10/15.
//  Copyright © 2015 Square. All rights reserved.
//

#import "TSQCalendarAppearance.h"

@implementation TSQCalendarAppearance

+ (instancetype) defaultAppearance {
    TSQCalendarAppearance *instance = [[TSQCalendarAppearance alloc] init];
    instance.normalTextColor = [UIColor darkGrayColor];
    instance.todayTextColor = [UIColor blueColor];
    instance.selectedTextColor = [UIColor whiteColor];
    instance.inBetweenTextColor = instance.normalTextColor;
    instance.selectedBackgroundImage = [UIImage imageFromColor:[UIColor blueColor]];
    instance.inBetweenBackgroundImage = [instance.selectedBackgroundImage imageByApplyingAlpha:0.2];
    return instance;
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