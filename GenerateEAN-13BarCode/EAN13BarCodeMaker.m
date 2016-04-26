//
//  EAN13BarCodeMaker.m
//  EAN13TEST
//
//  Created by 王阳 on 16/4/13.
//  Copyright © 2016年 王阳. All rights reserved.
//

#import "EAN13BarCodeMaker.h"

static const NSString *leftSpace = @"00000000000";  //左侧空白
static const NSString *startSymbol = @"101";        //起始符
static const NSString *middleSymbol = @"01010";     //中间分隔符
static const NSString *endSymbol = @"101";          //结尾符
static const NSString *rightSpace = @"0000000";     //右侧空白


@interface EAN13BarCodeMaker ()
@property (nonatomic,strong)NSArray *subsSetA;      //A子集
@property (nonatomic,strong)NSArray *subsSetB;      //B子集
@property (nonatomic,strong)NSArray *subsSetC;      //C子集
@property (nonatomic,strong)NSArray *preCode1;      //左侧奇偶表1
@property (nonatomic,strong)NSArray *preCode2;      //左侧奇偶表2
@property (nonatomic,strong)NSArray *preCode3;      //左侧奇偶表3
@property (nonatomic,strong)NSArray *preCode4;      //左侧奇偶表4
@property (nonatomic,strong)NSArray *preCode5;      //左侧奇偶表5
@property (nonatomic,strong)NSArray *preCode6;      //左侧奇偶表6

@end

@implementation EAN13BarCodeMaker
- (UIView *)generateEAN13BarCodeWithString:(NSString *)string Size:(CGSize)size{
    NSMutableArray *numbers = [[NSMutableArray alloc]initWithCapacity:13];
    NSRange range;
    range.length = 1;
    NSInteger oddNumber = 0;
    NSInteger evenNumber = 0;
    //将字符串存到数组
    for (int i = 0; i < 12; i ++) {
        range.location = i;
        NSString *str = [string substringWithRange:range];
        int num = [str intValue];
        [numbers addObject:[NSString stringWithFormat:@"%d",num]];
        //分别计算奇数位和偶数位的加权值
        if (i%2) {
            evenNumber += [str integerValue];
        }
        else{
            oddNumber += [str integerValue];
        }
    }
    //计算校验码
    NSInteger verifyNumber =  ( oddNumber + evenNumber * 3 ) % 10;
    if (verifyNumber != 0) {
        verifyNumber = 10 - verifyNumber;
    }
    //将校验码加入到数组末尾
    [numbers addObject:[NSString stringWithFormat:@"%ld",(long)verifyNumber]];
    
    //记录首位数字（用来确定奇偶性）
    NSInteger firstNumber = [numbers[0] integerValue];
    
    //将首位删除，其余位数前移
    NSMutableString *labelString = [[NSMutableString alloc]init];
    for (int i = 0; i < 12; i ++) {
        numbers[i] = numbers[i+1];
        [labelString appendString:numbers[i]];
    }
    [numbers removeLastObject];
    
    //根据位置和奇偶表获取相应子集对应的二进制码
    NSMutableArray *binaryArray = [[NSMutableArray alloc]initWithCapacity:13];
    for (int i = 0; i < 12; i ++) {
        NSString *subSet;
        if (i < 6) {
            //左侧数据区根据位置获取子集类型
            switch (i) {
                case 0:
                    subSet = [self.preCode1 objectAtIndex:firstNumber];
                    break;
                case 1:
                    subSet = [self.preCode2 objectAtIndex:firstNumber];
                    break;
                case 2:
                    subSet = [self.preCode3 objectAtIndex:firstNumber];
                    break;
                case 3:
                    subSet = [self.preCode4 objectAtIndex:firstNumber];
                    break;
                case 4:
                    subSet = [self.preCode5 objectAtIndex:firstNumber];
                    break;
                case 5:
                    subSet = [self.preCode6 objectAtIndex:firstNumber];
                    break;
            }
            //根据子集类型获取二进制码
            if ([subSet isEqualToString:@"A"]) {
                [binaryArray addObject:[self.subsSetA objectAtIndex:[numbers[i] integerValue] ]];
            }
            else{
                [binaryArray addObject:[self.subsSetB objectAtIndex:[numbers[i] integerValue] ]];

            }
        }
        else{
            //右侧数据区全部采用C子集
            [binaryArray addObject:[self.subsSetC objectAtIndex:[numbers[i] integerValue] ]];
        }
    }

    //添加空白和分隔符
    [binaryArray insertObject:leftSpace atIndex:0];
    [binaryArray insertObject:startSymbol atIndex:1];
    [binaryArray insertObject:middleSymbol atIndex:8];
    [binaryArray insertObject:endSymbol atIndex:15];
    [binaryArray insertObject:rightSpace atIndex:16];

    //将二进制数组转化为字符串
    NSMutableString *barCodeString = [[NSMutableString alloc]init];
    [binaryArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [barCodeString appendString:binaryArray[idx]];
    }];
    
    //绘制二维码
    UIView *barCodeView = [[UIView alloc]init];
    CGRect frame ;
    frame.size = size;
    barCodeView.frame = frame;
    for (int i = 0 ; i < barCodeString.length; i ++) {
        CGFloat heightScale;
        if ((i < 14)||( i > 56 && i < 61)||(i > 101)) {
            heightScale = 0.85;
        }
        else {
            heightScale = 0.75;
        }
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(i * CGRectGetWidth(barCodeView.frame)/120, CGRectGetHeight(barCodeView.frame) * 0.05 , CGRectGetWidth(barCodeView.frame)/113, CGRectGetHeight(barCodeView.frame)* heightScale)];
        NSRange range;
        range.length = 1;
        range.location = i;
        if ([[barCodeString substringWithRange:range] isEqualToString:@"1"]) {
            line.backgroundColor = [UIColor blackColor];
        }
        [barCodeView addSubview:line];
    }
    //添加字符label
    UILabel *firstNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(barCodeView.frame) * 3 / 113, CGRectGetHeight(barCodeView.frame) - CGRectGetHeight(barCodeView.frame)*0.17, CGRectGetWidth(barCodeView.frame) * 18 / 113 , 10)];
    firstNumberLabel.text = [NSString stringWithFormat:@"%ld",(long)firstNumber];
    firstNumberLabel.font = [UIFont systemFontOfSize:10];
    [barCodeView addSubview:firstNumberLabel];
    
    UILabel *leftNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(barCodeView.frame) * 13 / 113, CGRectGetHeight(barCodeView.frame) - CGRectGetHeight(barCodeView.frame)*0.17, CGRectGetWidth(barCodeView.frame) * 40 / 113, 10)];
    leftNumberLabel.text = [labelString substringWithRange:NSMakeRange(0, 6)];
    leftNumberLabel.textAlignment = NSTextAlignmentCenter;
    leftNumberLabel.font = [UIFont systemFontOfSize:10];
    [barCodeView addSubview:leftNumberLabel];
    
    UILabel *rightNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(barCodeView.frame) * 57 / 113, CGRectGetHeight(barCodeView.frame) - CGRectGetHeight(barCodeView.frame)*0.17, CGRectGetWidth(barCodeView.frame) * 40 / 113, 10)];
    rightNumberLabel.text = [labelString substringWithRange:NSMakeRange(6, 6)];
    rightNumberLabel.textAlignment = NSTextAlignmentCenter;
    rightNumberLabel.font = [UIFont systemFontOfSize:10];
    [barCodeView addSubview:rightNumberLabel];
    return barCodeView;
}

- (NSArray *)subsSetA{
    if (!_subsSetA) {
        _subsSetA = @[@"0001101",
                    @"0011001",
                    @"0010011",
                    @"0111101",
                    @"0100011",
                    @"0110001",
                    @"0101111",
                    @"0111011",
                    @"0110111",
                    @"0001011"];
    }
    return _subsSetA;
}

- (NSArray *)subsSetB{
    if (!_subsSetB) {
        _subsSetB = @[@"0100111",
                    @"0110011",
                    @"0011011",
                    @"0100001",
                    @"0011101",
                    @"0111001",
                    @"0000101",
                    @"0010001",
                    @"0001001",
                    @"0010111"];
    }
    return _subsSetB;
}

- (NSArray *)subsSetC{
    if (!_subsSetC) {
        _subsSetC = @[@"1110010",
                    @"1100110",
                    @"1101100",
                    @"1000010",
                    @"1011100",
                    @"1001110",
                    @"1010000",
                    @"1000100",
                    @"1001000",
                    @"1110100"];
    }
    return _subsSetC;
}

- (NSArray *)preCode1{
    if (!_preCode1) {
        _preCode1 = @[@"A",
                      @"A",
                      @"A",
                      @"A",
                      @"A",
                      @"A",
                      @"A",
                      @"A",
                      @"A",
                      @"A"];
    }
    return _preCode1;
}

- (NSArray *)preCode2{
    if (!_preCode2) {
        _preCode2 = @[@"A",
                      @"A",
                      @"A",
                      @"A",
                      @"B",
                      @"B",
                      @"B",
                      @"B",
                      @"B",
                      @"B"];
    }
    return _preCode2;
}

- (NSArray *)preCode3{
    if (!_preCode3) {
        _preCode3 = @[@"A",
                     @"B",
                     @"B",
                     @"B",
                     @"A",
                     @"B",
                     @"B",
                     @"A",
                     @"A",
                     @"B"];
    }
    return _preCode3;
}
- (NSArray *)preCode4{
    if (!_preCode4) {
        _preCode4 = @[@"A",
                     @"A",
                     @"B",
                     @"B",
                     @"A",
                     @"A",
                     @"B",
                     @"B",
                     @"B",
                     @"A"];
    }
    return _preCode4;
}
- (NSArray *)preCode5{
    if (!_preCode5) {
        _preCode5 = @[@"A",
                     @"B",
                     @"A",
                     @"B",
                     @"B",
                     @"A",
                     @"A",
                     @"A",
                     @"B",
                     @"B"];
    }
    return _preCode5;
}
- (NSArray *)preCode6{
    if (!_preCode6) {
        _preCode6 = @[@"A",
                     @"B",
                     @"B",
                     @"A",
                     @"B",
                     @"B",
                     @"A",
                     @"B",
                     @"A",
                     @"A"];
    }
    return _preCode6;
}

@end
