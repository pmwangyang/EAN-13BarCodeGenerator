# EAN-13BarCodeGenerator
One day,I need to generate EAN-13 bar code in my app. 
I tryed to pod "ZXing" for several times but all failed. 
And I think "ZXing" is too big for my tiny app. 
So I decide to write my own third party code to generate EAN-13 bar code. 
My "EAN13BarCodeMaker" is very easy to use.
Just copy two files into your project as a common class,no need to pod. 
And call the method :- (UIView *)generateEAN13BarCodeWithString:(NSString *)string Size:(CGSize)size; 
Give it a CGSize and 12 numbers long NSString,it will return a EAN-13 bar code View.

在做某个app时，我需要生成一个EAN-13条形码，但cocoapods始终无法pod"ZXing"。 
而且我个人觉得"ZXing"对于我这个轻量级的app来说，功能显得有点太多。 
所以我决定自己写一个生成EAN-13条形码的第三方。 
使用时，只需要像拷贝其他类那样，将两个文件复制到你的工程里。 
然后调用方法：- (UIView *)generateEAN13BarCodeWithString:(NSString *)string Size:(CGSize)size; 
传入一个CGSize和12位数字组成的NSString，就会返回一个EAN-13条形码。
