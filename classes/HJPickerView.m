//
//  HJPickerView.m
//  HJPickerViewDemo
//
//  Created by WHJ on 16/5/20.
//  Copyright © 2016年 WHJ. All rights reserved.
//

#import "HJPickerView.h"
@interface HJPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>{

    UIView *toolView;
    NSArray *datas;
}

@property (strong ,nonatomic) UIPickerView *pickerView;

@property (strong ,nonatomic) UIWindow *alertWindow;

@property (strong ,nonatomic) UIWindow *mainWindow;//用于还原

@property (weak ,nonatomic) id<HJPickerViewDelegate> delegate;

@end



@implementation HJPickerView

- (instancetype)initWithDatas:(NSArray *)data delegate:(id)delegate valuesDic:(nullable NSDictionary *)valuesDic, ... NS_REQUIRES_NIL_TERMINATION ;
{
    self = [super init];
    if (self) {
      
        self.delegate = delegate;
        _mainWindow = [self windowWithLevel:UIWindowLevelNormal];
        _alertWindow = [self windowWithLevel:UIWindowLevelAlert];
        if (!_alertWindow) {
            _alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            _alertWindow.windowLevel = UIWindowLevelAlert;
        }
        _alertWindow.backgroundColor = [UIColor clearColor];
      
        //获取可变参数
        NSMutableArray *dats = [[NSMutableArray alloc]init];
        [dats addObject:data];
        va_list args;
        va_start(args, valuesDic);
        if(valuesDic){
            [dats addObject:valuesDic];
            NSDictionary *dic;
            while(1){
                dic = va_arg(args, NSDictionary *);
                if(dic == nil)//可变参数最后一个参数必须为nil的原因
                    break;
                [dats addObject:dic];
            }
        }
        
        va_end(args);
        
        datas = [NSArray arrayWithArray:dats];
        
        [self setupUI];
    }
    return self;
}



-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
}



-(void)setupUI{
    
    CGFloat toolViewHeight = 40;
    CGFloat pickerViewHeight = [UIScreen mainScreen].bounds.size.height*9/30.f;

    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.alpha = 0.5f;
    
    
    toolView = [[UIView alloc]init];
    toolView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:toolView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:cancelBtn];

    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    completeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [completeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(completeAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:completeBtn];
    
    
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    [self.view addSubview:pickerView];
    
    toolView.frame = CGRectMake(0, self.view.frame.size.height-toolViewHeight-pickerViewHeight, self.view.frame.size.width, toolViewHeight);
    
    pickerView.frame = CGRectMake(0, CGRectGetMaxY(toolView.frame), CGRectGetWidth(self.view.frame), pickerViewHeight);
    self.pickerView = pickerView;
    
    cancelBtn.frame = CGRectMake(20, 0, 44, toolViewHeight);
    
    completeBtn.frame = CGRectMake(self.view.frame.size.width-20-CGRectGetWidth(cancelBtn.frame), 0, CGRectGetWidth(cancelBtn.frame), toolViewHeight);
    

}


#pragma mark - Event Response
-(void)cancelAction:(UIButton *)sender{
    
    [self dismiss:sender];
}


-(void)completeAction:(UIButton *)sender{
  
    //获取所有选项
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:datas.count];
    
    for (int i=0; i<datas.count; i++) {
        NSArray *tmpArr = [self showDatasWithPickerView:self.pickerView andComponent:i];
         NSInteger selectedIndex = [self.pickerView selectedRowInComponent:i];
        [values addObject:tmpArr[selectedIndex]];
    }

    //回调所有选中结果
    if ([self.delegate respondsToSelector:@selector(selectedValues:)]) {
        [self.delegate selectedValues:values];
    }
    
    //取消显示
    [self dismiss:sender];

}



#pragma mark - Private Methods
-(UIWindow *)windowWithLevel:(UIWindowLevel)windowLevel{
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window  in windows) {
        if (window.windowLevel == windowLevel) {
            return window;
        }
    }
    return nil;
}


-(void)show{
    
    _alertWindow.rootViewController = self;
    [_alertWindow makeKeyAndVisible];
}

- (void)dismiss:(id)sender
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        _mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        [_mainWindow tintColorDidChange];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [_mainWindow makeKeyAndVisible];
    }];
    
    _alertWindow.rootViewController = nil;
}


-(NSArray *)showDatasWithPickerView:(UIPickerView *)pickerView
                          andComponent:(NSInteger)component;{

    
    NSString *keyStr = nil;
    NSArray *dataArr = [NSArray array];
   
    if (component==0) {
        dataArr = datas[0];
        return dataArr;
    }
    
    NSInteger selectedIndex = 0;
    for (int i=0; i<=component; i++) {
        
        id data = datas[i];
        if ([data isKindOfClass:[NSArray class]]) {
            dataArr = data;
        }else{
            NSDictionary *dataDic = datas[i];
            dataArr = [dataDic objectForKey:keyStr];
        }
        
        selectedIndex = [pickerView selectedRowInComponent:i];
        keyStr =  [dataArr objectAtIndex:selectedIndex];

    }

    return dataArr;
}


//refresh components
-(void)reloadPickerViewWithPickerView:(UIPickerView *)pickerView
                            Component:(NSInteger)component;{
    //reset component
    for (NSInteger i=component+1; i<datas.count; i++) {
        [pickerView selectRow:0 inComponent:i animated:NO];
    }
    [pickerView reloadAllComponents];
}

#pragma mark - UIPickerViewDelegate/UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;{

    return datas.count;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;{
    NSArray *dataArr = [self showDatasWithPickerView:pickerView andComponent:component];
    return dataArr.count;
}


- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED;{
    NSArray *dataArr = [self showDatasWithPickerView:pickerView andComponent:component];
    return  dataArr[row];
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED;{

    return 35.f;
}
//
//
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
//
//
//    return 100.f;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED;{
    
    [self reloadPickerViewWithPickerView:pickerView Component:component];

}


@end