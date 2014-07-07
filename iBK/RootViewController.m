//
//  RootViewController.m
//  iBK
//
//  Created by 宜信 on 14-7-7.
//  Copyright (c) 2014年 siyejituan. All rights reserved.
//

#import "RootViewController.h"
#import "SSStackedPageView.h"
#import "CPKenburnsView.h"
#import "CellView.h"
#import "UIColor+CatColors.h"

@interface RootViewController ()<SSStackedViewDelegate>


@property (nonatomic) SSStackedPageView     *stackView;
@property (nonatomic) NSMutableArray        *userDatasArray;    // 用户的便签容器
@property (nonatomic) UIImageView           *bacImageView;      // 便签视图
@property (nonatomic) float                 time_interval;
@property (nonatomic) CPKenburnsImageView   *kenbunrsView;      // 背景图
@property (nonatomic) NSMutableArray        *backImagesArray;   // 背景图容器
@property (nonatomic) int                   preNum;             // 记录上一张背景图  防止重复

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 获取用户信息
    [self catchUserData];
    
    // 配置动态背景
    [self configBackImages];
    
    // 配置主视图
    [self configDetailView];
    
    
   
	// Do any additional setup after loading the view.
}

#pragma mark -  config UI && catch Data

- (void)catchUserData
{
    
}

- (void)configBackImages
{
    // 数据
    self.backImagesArray = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"IMG_1830.JPG"], [UIImage imageNamed:@"IMG_1833.JPG"], [UIImage imageNamed:@"IMG_1834.JPG"], [UIImage imageNamed:@"IMG_1827.JPG"], [UIImage imageNamed:@"IMG_1829.JPG"],nil];
    self.preNum = 1;
    
    // 背景图
    self.kenbunrsView = [[CPKenburnsImageView alloc] initWithFrame:self.view.frame];
    self.kenbunrsView.image = self.backImagesArray[self.preNum];
    [self.view addSubview:self.kenbunrsView];
    
    // runloop模式下 开启timer
    self.time_interval = 5;
    NSTimer *timer = [NSTimer timerWithTimeInterval:self.time_interval target:self selector:@selector(changeBackLayer:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)configDetailView
{
    // 用户便签视图
    self.stackView = [[SSStackedPageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [self.view addSubview:self.stackView];
    [self.view bringSubviewToFront:self.stackView];
    self.stackView.backgroundColor = [UIColor greenColor];
    
    self.stackView.delegate = self;
    self.stackView.pagesHaveShadows = YES;
    self.userDatasArray = [[NSMutableArray alloc] init];
    for (int i=0;i<30;i++) {
        CellView *thisView = [[CellView alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 100.f)];
        [self.userDatasArray addObject:thisView];
    }
}

#pragma mark - timer method
- (void)changeBackLayer:(id)sender
{
    // 确保配置的动态背景图不出现连续的情况
    int allPages = self.backImagesArray.count;
    int numPage = arc4random()%allPages;
    if (numPage == self.preNum) {
        self.preNum=(self.preNum+3)%allPages;
    }else{
        self.preNum = numPage;
    }
    NSLog(@"%d", self.preNum);
    self.kenbunrsView.image = self.backImagesArray[self.preNum];
}

#pragma mark - ssstackview delegate
- (CellView *)stackView:(SSStackedPageView *)stackView pageForIndex:(NSInteger)index
{
    CellView *thisView = (CellView *)[stackView dequeueReusablePage];
    if (!thisView) {
        thisView = [self.userDatasArray objectAtIndex:index];
        thisView.backgroundColor = [UIColor getRandomColor];
        thisView.layer.cornerRadius = 5;
        thisView.layer.masksToBounds = YES;
    }
    return thisView;
}

- (NSInteger)numberOfPagesForStackView:(SSStackedPageView *)stackView
{
    return [self.userDatasArray count];
}

- (void)stackView:(SSStackedPageView *)stackView selectedPageAtIndex:(NSInteger) index
{
    NSLog(@"selected page: %i",(int)index);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
