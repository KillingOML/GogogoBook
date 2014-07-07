//
//  CellView.m
//  SSStackView
//
//  Created by 宜信 on 14-6-25.
//  Copyright (c) 2014年 Steven Stevenson. All rights reserved.
//

#import "CellView.h"
#import "CALayer+WiggleAnimationAdditions.h"
#import "UIColor+CatColors.h"

@implementation CellView


@synthesize canShake;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        int abc = arc4random()%5;
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 66+420*0.8, 220, 25)];
        detailLabel.text = @"你好吗？ 我很好";
        [self addSubview:detailLabel];
        detailLabel.textColor = [UIColor blackColor];
        
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 60, 320*0.8, 421*0.8)];
        headImageView.image = [UIImage imageNamed:@"psb.jpg"];
        [self addSubview:headImageView];
//        detailLabel.layer.backgroundColor = [[UIColor blackColor] CGColor];
//        [self.layer addSublayer:detailLabel.layer];
        switch (abc) {
            case 0:
                self.layer.backgroundColor = [[UIColor colorWithHexString:@"FFF0F5"] CGColor];
                break;
            case 1:
                self.layer.backgroundColor = [[UIColor colorWithHexString:@"F0FFF0"] CGColor];
                break;
            case 2:
                self.layer.backgroundColor = [[UIColor colorWithHexString:@"C0FF3E"] CGColor];
                break;
            case 3:
                self.layer.backgroundColor = [[UIColor colorWithHexString:@"B23AEE"] CGColor];
                break;
            case 4:
                self.layer.backgroundColor = [[UIColor colorWithHexString:@"8B6508"] CGColor];
                break;
                
            default:
                break;
                
                
       
        }
        
        self.canShake = NO;
        
//        UILongPressGestureRecognizer *startWiggling = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startWiggling:)];
//        [self addGestureRecognizer:startWiggling];
//        
//        // Double-tap anywhere in the view to stop wiggling
//        UITapGestureRecognizer *stopWiggling = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopWiggling:)];
//        [stopWiggling setNumberOfTapsRequired:2];
//        [self addGestureRecognizer:stopWiggling];
    }
    return self;
}


- (void)startWiggling:(UIGestureRecognizer *)gesture
{
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        CALayer *wiggleLayer = [[[self layer] sublayers] lastObject];
        [wiggleLayer bts_startWiggling];
    }
}

- (void)stopWiggling:(UIGestureRecognizer *)gesture
{
    // remember discrete gestures are simply recognized
    if ([gesture state] == UIGestureRecognizerStateRecognized) {
        CALayer *wiggleLayer = [[[self layer] sublayers] lastObject];
        [wiggleLayer bts_stopWiggling];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
