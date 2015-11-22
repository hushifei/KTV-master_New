

#import "HuToast.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface HuToast ()
@property (nonatomic, strong) NSString *viewFrame;
@property (nonatomic, assign) NSString *textAlign;
@property (nonatomic, copy)   NSString *message;
@property (nonatomic, assign) CGFloat time;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) CGFloat textFont;
@property (nonatomic,strong)  UIView *tempView;
@end

@implementation HuToast


- (instancetype)init
{
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
    }
    return self;
}

+ (void)showToastWithMessage:(NSString *)message WithTimeDismiss:(NSString *)time messageType:(KMessageStyle)style;{
    HuToast *myToast=[[HuToast alloc]init];
    [myToast setMessage:message];
    [myToast setTime:[time floatValue]];
    myToast.label.font = [UIFont systemFontOfSize:12];
    UIWindow  *window = [UIApplication sharedApplication].keyWindow;
    UIFont *font = [UIFont systemFontOfSize:12];
    CGRect width = [myToast.message boundingRectWithSize:CGSizeMake(300, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName :font} context:nil];
    myToast.label.frame = CGRectMake(5, 5, width.size.width+10, width.size.height+20);
    myToast.tempView = [[UIView alloc] initWithFrame:CGRectMake(0, myToast.frame.origin.y-10, width.size.width+20,width.size.height+30)];
    myToast.tempView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-100);
    
    switch (style) {
        case KMessageSuccess: {
            myToast.tempView.backgroundColor = [UIColor greenColor];
            myToast.label.textColor=[UIColor blueColor];
            break;
        }
        case KMessageStyleError: {
            myToast.tempView.backgroundColor = [UIColor redColor];
            myToast.label.textColor=[UIColor whiteColor];
            break;
        }
        case KMessageWarning:{
            myToast.tempView.backgroundColor = [UIColor yellowColor];
            myToast.label.textColor=[UIColor blackColor];
            break;
        }
        case KMessageStyleInfo: {
            myToast.tempView.backgroundColor = [UIColor blueColor];
            myToast.label.textColor=[UIColor groupTableViewBackgroundColor];
        }
        default: {
            myToast.tempView.backgroundColor = [UIColor lightGrayColor];
            myToast.label.textColor=[UIColor blackColor];
        }
            break;
    }
    myToast.tempView.layer.cornerRadius = 10;
     myToast.tempView.clipsToBounds = YES;
    [ myToast.tempView addSubview:myToast.label];
    [window addSubview: myToast.tempView];
}

- (void)setMessage:(NSString *)message{
    _message = message;
    _label.alpha = 1;
    _label.text = message;
}

-(void)setTime:(CGFloat)time{
    _time = time;
    _label.alpha = 1;
    if (time < 1) {
        //n秒后view变淡
        [self performSelector:@selector(laterRun) withObject:nil afterDelay:1];
    }else{
        //n秒后view变淡
        [self performSelector:@selector(laterRun) withObject:nil afterDelay:2];
    }
    
}

- (void)laterRun{
    [UIView animateWithDuration:0.4 animations:^{
        _tempView.alpha = 0;
        _label.alpha = 0;
        [_label removeFromSuperview];
        [_tempView removeFromSuperview];
    }];
}
//}
@end
