//
//  HJPickerView.h
//  HJPickerViewDemo
//
//  Created by WHJ on 16/5/20.
//  Copyright © 2016年 WHJ. All rights reserved.
//

#import <UIKit/UIKit.h>


@class HJPickerView;

@protocol HJPickerViewDelegate <NSObject>

-(void)selectedValues:(nullable NSArray *)values;



@end


@interface HJPickerView : UIViewController



- (instancetype)initWithDatas:(NSArray *)datas delegate:(id)delegate valuesDic:(nullable NSDictionary *)valuesDic, ... NS_REQUIRES_NIL_TERMINATION ;

-(void)show;
@end
