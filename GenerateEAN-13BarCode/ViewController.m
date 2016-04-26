//
//  ViewController.m
//  GenerateEAN-13BarCode
//
//  Created by 王阳 on 16/4/26.
//  Copyright © 2016年 0.5 Studio. All rights reserved.
//

#import "ViewController.h"
#import "EAN13BarCodeMaker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EAN13BarCodeMaker *maker = [[EAN13BarCodeMaker alloc]init];
    //generate 12 numbers long NSString
    //生成12位随机数
    NSMutableString *str = [[NSMutableString alloc]init];
    for (int i = 0 ; i < 12 ; i ++ ) {
        [str appendString:[NSString stringWithFormat:@"%u",arc4random()%10]];
    }
    //generate bar code
    //生成条形码
    UIView *barCodeView = [maker generateEAN13BarCodeWithString:str Size:CGSizeMake(200, 100)];
    barCodeView.frame = CGRectMake(100, 100, 200, 100);
    [self.view addSubview:barCodeView];
}

@end
