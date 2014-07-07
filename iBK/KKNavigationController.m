//
//  KKNavigationController.m
//  TS
//
//  Created by Coneboy_K on 13-12-2.
//  Copyright (c) 2013年 Coneboy_K. All rights reserved.  MIT
//  WELCOME TO MY BLOG  http://www.coneboy.com
//


#import "KKNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>
#import "PublicViewController.h"
#import "UIColor+CatColors.h"


#define TOP_VIEW  [[UIApplication sharedApplication]keyWindow].rootViewController.view

//CGFloat const   kLBBlurredImageDefaultBlurRadius    = 20.0;
//NSString *const kLBBlurredImageErrorDomain          = @"com.lucabernardi.blurred_image_additions";


@interface KKNavigationController ()
{
    CGPoint startTouch;
    
    UIImageView *lastScreenShotView;
    UIView *blackMask;
    UIPanGestureRecognizer *recognizer;
}

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSMutableArray *screenShotsList;

@property (nonatomic,assign) BOOL isMoving;

@end

@implementation KKNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.screenShotsList = [[NSMutableArray alloc]init];
        self.canDragBack = YES;
        self.navigationBarHidden = YES;

    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(paningGestureReceive:)];
    [recognizer delaysTouchesBegan];
//    [self.view addGestureRecognizer:recognizer];
    
    [self printList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self printList];
    [self.screenShotsList addObject:[self capture]];
    [self printList];
    [super pushViewController:viewController animated:animated];
    if (recognizer) {
        [self.view removeGestureRecognizer:recognizer];
    }
    [self performSelector:@selector(changeGesture) withObject:self afterDelay:0.42]; // 添加一个延迟，防止恶意手势导致页面乱跳
}

- (void)changeGesture
{
//    [self.view addGestureRecognizer:recognizer];

}

- (void)printList
{
    for (int i = 0; i < self.screenShotsList.count; i++) {
//        NSLog(@">>>>>?????%@", [self.screenShotsList objectAtIndex:i]);

    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    [self printList];

    return [super popViewControllerAnimated:animated];
}

#pragma mark - Utility Methods -

- (UIImage *)capture
{
//    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);

    
//    CGSize captureSize = CGSizeMake(WINDOW_WEIGHT, WINDOW_HEIGHT);
    UIGraphicsBeginImageContextWithOptions([[[UIApplication sharedApplication] delegate] window].frame.size, self.view.opaque, 0.0);
//    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [[[[UIApplication sharedApplication] delegate] window].layer renderInContext:UIGraphicsGetCurrentContext()];
    
     UIImage * img = UIGraphicsGetImageFromCurrentImageContext();

    return img;
    
    
    /******* xiugai*******/
//    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"00%d.jpg", arc4random()%7+1]];
//    NSLog(@"%@", self);
//    UIGraphicsEndImageContext();
//    
//    
//    
//    CIContext *context   = [CIContext contextWithOptions:nil];
//    CIImage *sourceImage = [CIImage imageWithCGImage:img.CGImage];
//    NSString *clampFilterName = @"CIAffineClamp";
//    CIFilter *clamp = [CIFilter filterWithName:clampFilterName];
//    [clamp setValue:sourceImage
//             forKey:kCIInputImageKey];
//    CIImage *clampResult = [clamp valueForKey:kCIOutputImageKey];
//    NSString *gaussianBlurFilterName = @"CIGaussianBlur";
//    CIFilter *gaussianBlur           = [CIFilter filterWithName:gaussianBlurFilterName];
//    [gaussianBlur setValue:clampResult
//                    forKey:kCIInputImageKey];
//    [gaussianBlur setValue:[NSNumber numberWithFloat:2]  // 设置毛玻璃的马赛克模糊度
//                    forKey:@"inputRadius"];
//    CIImage *gaussianBlurResult = [gaussianBlur valueForKey:kCIOutputImageKey];
//    CGImageRef cgImage = [context createCGImage:gaussianBlurResult
//                                       fromRect:[sourceImage extent]];
//    UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
//    CGImageRelease(cgImage);
//    
//    return blurredImage;
    

}


- (NSError *)errorForNotExistingFilterWithName:(NSString *)filterName
{
    NSString *errorDescription = [NSString stringWithFormat:@"The CIFilter named %@ doesn't exist",filterName];
    NSError *error             = [NSError errorWithDomain:0
                                                     code:0
                                                 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
    return error;
}


- (void)moveViewWithX:(float)x
{

//    NSLog(@"%f", x);
    x = x>320?320:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float alpha = 0.4 - (x/800);

    blackMask.alpha = alpha;
    
    //偏移量的缓冲
    CGFloat aa = abs(startBackViewX)/kkBackViewWidth;
//    NSLog(@"%f", aa);
    CGFloat y = x*aa;
//    NSLog(@"%f", y);
//    NSLog(@"%f", startBackViewX+y);

    CGFloat lastScreenShotViewHeight = kkBackViewHeight;
    
    //TODO: FIX self.edgesForExtendedLayout = UIRectEdgeNone  SHOW BUG
/**
 *  if u use self.edgesForExtendedLayout = UIRectEdgeNone; pls add

    if (!iOS7) {
        lastScreenShotViewHeight = lastScreenShotViewHeight - 20;
    }
 *
 */
    [lastScreenShotView setFrame:CGRectMake(startBackViewX+y,
                                            0,
                                            kkBackViewWidth,
                                            lastScreenShotViewHeight)];
    

}



-(BOOL)isBlurryImg:(CGFloat)tmp
{
    return YES;
}

#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    NSLog(@"%d", recoginzer.state);

    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (self.backgroundView) {
            self.backgroundView = nil;
        }
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
       
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        
        startBackViewX = startX;
        [lastScreenShotView setFrame:CGRectMake(startBackViewX,
                                                lastScreenShotView.frame.origin.y,
                                                lastScreenShotView.frame.size.height,
                                                lastScreenShotView.frame.size.width)];

        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
        if (touchPoint.x - startTouch.x > 50)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                _isMoving = NO;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
            
        }
        return;
        
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        _isMoving = NO;

        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
        if (_isMoving) {
            [self moveViewWithX:touchPoint.x - startTouch.x];
        }

}




@end



