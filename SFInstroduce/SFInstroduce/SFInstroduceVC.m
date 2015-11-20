//
//  SFInstroduceVC.m
//  SFInstroduce
//
//  Created by stevenhu on 15/11/19.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "SFInstroduceVC.h"
#import "UIView+Masony.h"
#import "NewFeatureScrollView.h"
#import "NewFeatureImageV.h"
#import "UIApplication+Extend.h"
#import "CoreArchive.h"
@interface FeatureModel : NSObject

@property (nonatomic,strong) UIImage *image;
/*
 *  初始化
 */
+(instancetype)model:(UIImage *)image;

@end

@implementation FeatureModel

/*
 *  初始化
 */
+(instancetype)model:(UIImage *)image{
    
    FeatureModel *model = [[FeatureModel alloc] init];
    
    model.image = image;
    
    return model;
}


@end

NSString *const NewFeatureVersionKey = @"NewFeatureVersionKey";

@interface SFInstroduceVC ()

/** 模型数组 */
@property (nonatomic,strong) NSArray *models;

/** scrollView */
@property (nonatomic,weak) NewFeatureScrollView *scrollView;

@property (nonatomic,copy) void(^enterBlock)();

@end

@implementation SFInstroduceVC


/*
 *  初始化
 */
+(instancetype)createSFIntroduceVCWithModels:(NSArray<FeatureModel*>*)models enterBlock:(void(^)())enterBlock{
    
    SFInstroduceVC *sfInstroduceVC = [[SFInstroduceVC alloc] init];
    
    sfInstroduceVC.models = models;
    
    //记录block
    sfInstroduceVC.enterBlock =enterBlock;
    
    return sfInstroduceVC;
}

+(instancetype)createSFIntroduceVCEnterBlock:(void(^)())enterBlock {
    //解析xml文件
    //根据xml解析之后的模型创建FeatureModel
    
    NSBundle *currentBundle=[NSBundle bundleForClass:[self class]];
    NSString *path1=[currentBundle pathForResource:@"f1@2x" ofType:@"png"];
    NSString *path2=[currentBundle pathForResource:@"f2@2x" ofType:@"png"];
    NSString *path3=[currentBundle pathForResource:@"f3@2x" ofType:@"png"];

    FeatureModel *m1 = [FeatureModel model:[UIImage imageNamed:path1]];
    FeatureModel *m2 = [FeatureModel model:[UIImage imageNamed:path2]];
    FeatureModel *m3 = [FeatureModel model:[UIImage imageNamed:path3]];
   return  [self createSFIntroduceVCWithModels:@[m1,m2,m3] enterBlock:enterBlock];
}


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    //控制器准备
    [self vcPrepare];
    
    //显示了版本新特性，保存版本号
    [self saveVersion];
}


/*
 *  显示了版本新特性，保存版本号
 */
-(void)saveVersion{
    
    //系统直接读取的版本号
    NSString *versionValueStringForSystemNow=[UIApplication sharedApplication].version;
    
    //保存版本号
    [CoreArchive setStr:versionValueStringForSystemNow key:NewFeatureVersionKey];
}



/*
 *  控制器准备
 */
-(void)vcPrepare{
    
    //添加scrollView
    NewFeatureScrollView *scrollView = [[NewFeatureScrollView alloc] init];
    
    _scrollView = scrollView;
    
    //添加
    [self.view addSubview:scrollView];
    
    //添加约束
    [scrollView masViewAddConstraintMakeEqualSuperViewWithInsets:UIEdgeInsetsZero];
    
    //添加图片
    [self imageViewsPrepare];
}




/*
 *  添加图片
 */
-(void)imageViewsPrepare{
    
    [self.models enumerateObjectsUsingBlock:^(FeatureModel *model, NSUInteger idx, BOOL *stop) {
        
        NewFeatureImageV *imageV = [[NewFeatureImageV alloc] init];
        
        //设置图片
        imageV.image = model.image;
        
        //记录tag
        imageV.tag = idx;
        
        if(idx == self.models.count -1) {
            
            //开启交互
            imageV.userInteractionEnabled = YES;
            
            //添加手势
            [imageV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)]];
        }
        
        [_scrollView addSubview:imageV];
    }];
}



-(void)gestureAction:(UITapGestureRecognizer *)tap{
    
    UIView *tapView = tap.view;
    
    //禁用
    tapView.userInteractionEnabled = NO;
    
    if(UIGestureRecognizerStateEnded == tap.state) [self dismiss];
}

-(void)dismiss{
    
    if(self.enterBlock != nil) _enterBlock();
}

/*
 *  是否应该显示版本新特性页面
 */
+(BOOL)canShowNewFeature{
    
    //系统直接读取的版本号
    NSString *versionValueStringForSystemNow=[UIApplication sharedApplication].version;
    
    //读取本地版本号
    NSString *versionLocal = [CoreArchive strForKey:NewFeatureVersionKey];
    
    if(versionLocal!=nil && [versionValueStringForSystemNow isEqualToString:versionLocal]){//说明有本地版本记录，且和当前系统版本一致
        
        return NO;
        
    }else{//无本地版本记录或本地版本记录与当前系统版本不一致
        
        //保存
        [CoreArchive setStr:versionValueStringForSystemNow key:NewFeatureVersionKey];
        
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
