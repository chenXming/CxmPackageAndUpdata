//
//  UIView+LBDashesLineView.h
//  funlive
//
//  Created by liubo on 16/8/8.
//  Copyright © 2016年 renzhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LBDashesLineView)

/*
 * lineView         需要绘制成虚线的view
 * lineLength       虚线的宽度
 * lineSpacing      虚线的间距
 * lineColor        虚线的颜色
 */
+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;

@end
