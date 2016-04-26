//
//  EAN13BarCodeMaker.h
//  EAN13TEST
//
//  Created by 王阳 on 16/4/13.
//  Copyright © 2016年 王阳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EAN13BarCodeMaker : NSObject
- (UIView *)generateEAN13BarCodeWithString:(NSString *)string Size:(CGSize)size;
@end
