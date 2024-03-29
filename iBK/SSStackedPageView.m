//
//  SSStackView.m
//  SSStackView
//
//  Created by Stevenson on 3/10/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSStackedPageView.h"
#import "CellView.h"
#import "CALayer+WiggleAnimationAdditions.h"

#define OFFSET_TOP 30.f
#define PAGE_PEAK 70.f
#define MINIMUM_ALPHA 0.5f
#define MINIMUM_SCALE 0.92f
#define TOP_OFFSET_HIDE 20.f
#define BOTTOM_OFFSET_HIDE 20.f
#define COLLAPSED_OFFSET 5.f
#define SHADOW_VECTOR CGSizeMake(0.f,-.5f)
#define SHADOW_ALPHA .3f

@interface SSStackedPageView(){
    

}

///ScrollView attached to this view
@property (nonatomic) UIScrollView *theScrollView;

///array containing reusable pages
@property (nonatomic) NSMutableArray *reusablePages;

///index of the current page selected
@property (nonatomic) NSInteger selectedPageIndex;

///tracked translation for the current view being dragged
@property (nonatomic) CGFloat trackedTranslation;

//count of the total number of pages
@property (nonatomic) NSInteger pageCount;

///array of the posts contained
@property (nonatomic) NSMutableArray *pages;

///current posts visible 
@property (nonatomic) NSRange visiblePages;

// begin point
@property (nonatomic) CGPoint beginPoint;

// end point
@property (nonatomic) CGPoint endPoint;

// now alpha
@property (nonatomic) CGFloat detailAlpha;


@end

@implementation SSStackedPageView

// IB Method
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
    
    self.backgroundColor = [UIColor redColor];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(beginPan:)];
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
    
    self.detailAlpha = 1;
}

// normal Method
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self setup];
        [self setup];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(beginPan:)];
        pan.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:pan];
        
        self.detailAlpha = 1;
    }
    
 
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"layoit");
    if (self.delegate) {
        self.pageCount = [self.delegate numberOfPagesForStackView:self];
    }
    
    [self.reusablePages removeAllObjects];
    self.visiblePages = NSMakeRange(0, 0);
    
    for (NSInteger i=0; i < [self.pages count]; i++) {
        [self removePageAtIndex:i];
    }
    [self.pages  removeAllObjects];
    
    for (NSInteger i=0; i<self.pageCount; i++) {
        [self.pages addObject:[NSNull null]];
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.theScrollView.backgroundColor = [UIColor clearColor];
    
    self.theScrollView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.theScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), MAX(CGRectGetHeight(self.bounds), OFFSET_TOP+self.pageCount * PAGE_PEAK));
    [self addSubview:self.theScrollView];
    
    [self setPageAtOffset:self.theScrollView.contentOffset];
    [self reloadVisiblePages];
}

#pragma mark - setup methods
- (void)setup
{
    self.pageCount = 0;
    self.selectedPageIndex = -1;
    
    self.pages = [[NSMutableArray alloc] init];
    self.reusablePages = [[NSMutableArray alloc] init];
    self.visiblePages = NSMakeRange(0, 0);
    
    self.theScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.theScrollView.delegate = self;
    self.theScrollView.backgroundColor = [UIColor clearColor];
    self.theScrollView.showsVerticalScrollIndicator = NO;
    

}

#pragma mark - Page Selection
- (void)selectPageAtIndex:(NSInteger)index WithView:(CellView *)view
{
    if (index != self.selectedPageIndex) {
        NSLog(@"beign:%@", view);
        view.canShake = YES;
        self.selectedPageIndex = index;
        NSInteger visibleEnd = self.visiblePages.location + self.visiblePages.length;
        [self hidePagesBehind:NSMakeRange(self.visiblePages.location, index-self.visiblePages.location)];
        if (index+1 < visibleEnd) {
            NSInteger start = index+1;
            NSInteger stop = visibleEnd-start;
            [self hidePagesInFront:NSMakeRange(start,stop)];
        }
        self.theScrollView.scrollEnabled = NO;
    } else {
        for (int i = 0; i < [[view layer] sublayers].count; i++) {
            CALayer *layer = [[[view layer] sublayers] objectAtIndex:i];
            [layer bts_stopWiggling];
            
        }
        view.canShake = NO;
        self.selectedPageIndex = -1;
        [self resetPages];
    }
}

- (void)resetPages
{
    NSInteger start = self.visiblePages.location;
    NSInteger stop = self.visiblePages.location + self.visiblePages.length;
    [UIView beginAnimations:@"stackReset" context:nil];
    [UIView setAnimationDuration:.4f];
    for (NSInteger i=start;i < stop;i++) {
        CellView *page = [self.pages objectAtIndex:i];
//        page.layer.transform = CATransform3DMakeScale(MINIMUM_SCALE, MINIMUM_SCALE, 1.f);
        
        
        static NSString * const kBTSPulseAnimation = @"BTSPulseAnimation";

        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        [pulseAnimation setDuration:0.2];
        [pulseAnimation setRepeatCount:1];
        
        // The built-in ease in/ ease out timing function is used to make the animation look smooth as the layer
        // animates between the two scaling transformations.
        [pulseAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        // Scale the layer to half the size
        CATransform3D transform = CATransform3DMakeScale(0.95, 0.95, 1.2);
        
        // Tell CA to interpolate to this transformation matrix
        [pulseAnimation setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
        [pulseAnimation setToValue:[NSValue valueWithCATransform3D:transform]];
        
        // Tells CA to reverse the animation (e.g. animate back to the layer's transform)
        [pulseAnimation setAutoreverses:YES];
        // Finally... add the explicit animation to the layer... the animation automatically starts.
        [page.layer addAnimation:pulseAnimation forKey:kBTSPulseAnimation];
        
        
        CGRect thisFrame = page.frame;
        thisFrame.origin.y = OFFSET_TOP + i * PAGE_PEAK;
        page.frame = thisFrame;
    }
    [UIView commitAnimations];
    self.theScrollView.scrollEnabled = YES;
}

- (void)hidePagesBehind:(NSRange)backPages
{
    NSInteger start = backPages.location;
    NSInteger stop = backPages.location + backPages.length;
    [UIView beginAnimations:@"stackHideBack" context:nil];
    [UIView setAnimationDuration:.4f];
    for (NSInteger i=start;i <= stop;i++) {
        CellView *page = (CellView*)[self.pages objectAtIndex:i];
        CGRect thisFrame = page.frame;
        NSInteger visibleIndex = i-self.visiblePages.location;
        thisFrame.origin.y = self.theScrollView.contentOffset.y+TOP_OFFSET_HIDE + visibleIndex * COLLAPSED_OFFSET;
        page.frame = thisFrame;
    }
    [UIView commitAnimations];
}

- (void)hidePagesInFront:(NSRange)frontPages
{
    NSInteger start = frontPages.location;
    NSInteger stop = frontPages.location + frontPages.length;
    [UIView beginAnimations:@"stackHideFront" context:nil];
    [UIView setAnimationDuration:.4f];
    for (NSInteger i=start;i < stop;i++) {
        CellView *page = (CellView*)[self.pages objectAtIndex:i];
//        page.backgroundColor = [UIColor darkGrayColor];
        CGRect thisFrame = page.frame;
        thisFrame.origin.y = self.theScrollView.contentOffset.y+CGRectGetHeight(self.frame)-BOTTOM_OFFSET_HIDE + i * COLLAPSED_OFFSET;
        page.frame = thisFrame;
    }
    [UIView commitAnimations];
}

#pragma mark - displaying pages
- (void)reloadVisiblePages
{
    NSInteger start = self.visiblePages.location;
    NSInteger stop = self.visiblePages.location + self.visiblePages.length;
    
    for (NSInteger i = start; i < stop; i++) {
        CellView *page = [self.pages objectAtIndex:i];
        
        if (i == 0 || [self.pages objectAtIndex:i-1] == [NSNull null]) {
            page.layer.transform = CATransform3DMakeScale(MINIMUM_SCALE, MINIMUM_SCALE, 1.f);
        } else{
            [UIView beginAnimations:@"stackScrolling" context:nil];
            [UIView setAnimationDuration:.4f];
            page.layer.transform = CATransform3DMakeScale(MINIMUM_SCALE, MINIMUM_SCALE, 1.f);
            [UIView commitAnimations];
        }
    }
}

- (void)setPageAtOffset:(CGPoint)offset
{
    if ([self.pages count] > 0 ) {
        CGPoint start = CGPointMake(offset.x - CGRectGetMinX(self.theScrollView.frame), offset.y -(CGRectGetMinY(self.theScrollView.frame)));
        
        CGPoint end = CGPointMake(MAX(0, start.x) + CGRectGetWidth(self.bounds), MAX(OFFSET_TOP, start.y) + CGRectGetHeight(self.bounds));
        
        NSInteger startIndex = 0;
        for (NSInteger i=0; i < [self.pages count]; i++) {
            if (PAGE_PEAK * (i+1) > start.y) {
                startIndex = i;
                break;
            }
        }
        
        NSInteger endIndex = 0;
        for (NSInteger i=0; i < [self.pages count]; i++) {
            if ((PAGE_PEAK * i < end.y && PAGE_PEAK * (i + 1) >= end.y ) || i == [self.pages count]-1) {
                endIndex = i + 1;
                break;
            }
        }
        
        startIndex = MAX(startIndex - 1, 0);
        endIndex = MIN(endIndex, [self.pages count] - 1);
        CGFloat pagedLength = endIndex - startIndex + 1;
        
        if (self.visiblePages.location != startIndex || self.visiblePages.length != pagedLength) {
            _visiblePages.location = startIndex;
            _visiblePages.length = pagedLength;
            for (NSInteger i = startIndex; i <= endIndex; i++) {
                [self setPageAtIndex:i];
            }
            
            for (NSInteger i = 0; i < startIndex; i ++) {
                [self removePageAtIndex:i];
            }
            
            for (NSInteger i = endIndex + 1; i < [self.pages count]; i ++) {
                [self removePageAtIndex:i];
            }
        }
    }
}

- (void)setPageAtIndex:(NSInteger)index
{
    if (index >= 0 && index < [self.pages count]) {
        CellView *page = [self.pages objectAtIndex:index];
        if ((!page || (NSObject*)page == [NSNull null]) && self.delegate) {
            page = [self.delegate stackView:self pageForIndex:index];
            [self.pages replaceObjectAtIndex:index withObject:page];
            page.frame = CGRectMake(0.f, index * PAGE_PEAK, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            if (self.pagesHaveShadows) {
                [page.layer setShadowOpacity:SHADOW_ALPHA];
                [page.layer setShadowOffset:SHADOW_VECTOR];
                page.layer.shadowPath = [UIBezierPath bezierPathWithRect:page.bounds].CGPath;
                page.clipsToBounds = NO;
            }
            page.layer.zPosition = index;
        }
        
        if (![page superview]) {
            if ((index == 0 || [self.pages objectAtIndex:index-1] == [NSNull null]) && index+1 < [self.pages count]) {
                CellView *topPage = [self.pages objectAtIndex:index+1];
                [self.theScrollView insertSubview:page belowSubview:topPage];
            } else {
                [self.theScrollView addSubview:page];
            }
            page.tag = index;
        }
        
        if ([page.gestureRecognizers count] < 2) {
//            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
//            [page addGestureRecognizer:pan];
            
            UITapGestureRecognizer *sigleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
            [page addGestureRecognizer:sigleTap];
            
            // 长按手势
            UILongPressGestureRecognizer *startWiggling = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startWiggling:)];
            [page addGestureRecognizer:startWiggling];
            
            // Double-tap anywhere in the view to stop wiggling
            UITapGestureRecognizer *stopWiggling = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopWiggling:)];
            [stopWiggling setNumberOfTapsRequired:2];
            [page addGestureRecognizer:stopWiggling];
        }
    }
}

#pragma mark - reuse methods
- (void)enqueueReusablePage:(CellView*)page
{
    [self.reusablePages addObject:page];
}

- (CellView*)dequeueReusablePage
{
    CellView *page = [self.reusablePages lastObject];
    if (page && (NSObject*)page != [NSNull null]) {
        [self.reusablePages removeLastObject];
        return page;
    }
    return nil;
}

- (void)removePageAtIndex:(NSInteger)index
{
    CellView *page = [self.pages objectAtIndex:index];
    if (page && (NSObject*)page != [NSNull null]) {
        page.layer.transform = CATransform3DIdentity;
        [page removeFromSuperview];
        [self enqueueReusablePage:page];
        [self.pages replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

#pragma mark - gesture recognizer

static int confirm_length = 150;

- (void)beginPan:(UIGestureRecognizer *)sender
{

    if (sender.state == UIGestureRecognizerStateBegan) {
        self.beginPoint = [sender locationInView:self];
    }
    
    if (sender.state == UIGestureRecognizerStateCancelled) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [sender locationInView:self];
        
        // 如果是向左滑动的
        if (point.x < self.beginPoint.x) {
            
            if (self.detailAlpha <= 0.07) {
                self.detailAlpha = 0;
                self.theScrollView.alpha = 0;
                return;
            }
            float length = self.beginPoint.x-point.x;
            int detailLength =  (int)length%confirm_length;
            if ((int)length/confirm_length) {
                self.detailAlpha = 0;
                self.theScrollView.alpha = 0;
                return;
            }
            if (detailLength != 0) {
                NSLog(@"%f---%d----%f", length, detailLength, self.detailAlpha-(float)detailLength/confirm_length);
                self.theScrollView.alpha = self.detailAlpha - (float)detailLength/confirm_length;
//                self.detailAlpha = self.theScrollView.alpha;
            }else{
                self.theScrollView.alpha = 0;
                self.detailAlpha = 0;
            }
        }
        
        // 如果是向右滑动的
        if (point.x > self.beginPoint.x) {
            
            if (self.detailAlpha >= 0.93) {
                self.detailAlpha = 1;
                self.theScrollView.alpha = 1;
                return;
            }
            
            float length = point.x-self.beginPoint.x;
            int detailLength =  (int)length%confirm_length;
            if ((int)length/confirm_length>=1) {
                self.detailAlpha = 1;
                self.theScrollView.alpha = 1;
                return;
            }
            if (detailLength != 0) {
                NSLog(@"%f---%d----%f", length, detailLength, self.detailAlpha+(float)detailLength/confirm_length);
                self.theScrollView.alpha = self.detailAlpha + (float)detailLength/confirm_length;
//                self.detailAlpha = self.theScrollView.alpha;
            }else{
                self.theScrollView.alpha = 1;
                self.detailAlpha = 1;
            }
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.detailAlpha = self.theScrollView.alpha;
        NSLog(@"%f", self.detailAlpha);
        
        if (self.theScrollView.alpha >= 0.51) {
            [UIView animateWithDuration:0.42
                             animations:^{
                                 self.detailAlpha = 1;
                                 self.theScrollView.alpha = 1;
                                 self.theScrollView.userInteractionEnabled = NO;
                                 
                             } completion:^(BOOL finished) {
                                 self.theScrollView.userInteractionEnabled = YES;
                             }];
        }else{
            [UIView animateWithDuration:0.42
                             animations:^{
                                 self.detailAlpha = 0;
                                 self.theScrollView.alpha = 0;
                                 self.theScrollView.userInteractionEnabled = NO;
                             } completion:^(BOOL finished) {
                                 self.theScrollView.userInteractionEnabled = YES;
                             }];
        }
    }
}

- (void)tapped:(UIGestureRecognizer*)sender
{
   
    CellView *page = (CellView *)[sender view];
    NSLog(@"tap:%@", page);
    NSInteger index = [self.pages indexOfObject:page];
    
    if (index == self.pages.count-1) {
        NSLog(@"begin animation");
        return;
    }
    
    CGRect pageTouchFrame = page.frame;
    if (self.selectedPageIndex == index) {
        pageTouchFrame.size.height = CGRectGetHeight(pageTouchFrame)-COLLAPSED_OFFSET;
    } else if (self.selectedPageIndex != -1) {
        pageTouchFrame.size.height = COLLAPSED_OFFSET;
    } else if ( index+1 < [self.pages count] ) {
        pageTouchFrame.size.height = PAGE_PEAK;
    }
    
    
    static NSString * const kBTSPulseAnimation = @"BTSPulseAnimation";
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [pulseAnimation setDuration:0.2];
    [pulseAnimation setRepeatCount:1];
    
    // The built-in ease in/ ease out timing function is used to make the animation look smooth as the layer
    // animates between the two scaling transformations.
    [pulseAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    // Scale the layer to half the size
    CATransform3D transform = CATransform3DMakeScale(1.02, 0.95, 1.2);
    
    // Tell CA to interpolate to this transformation matrix
    [pulseAnimation setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [pulseAnimation setToValue:[NSValue valueWithCATransform3D:transform]];
    
    // Tells CA to reverse the animation (e.g. animate back to the layer's transform)
    [pulseAnimation setAutoreverses:YES];
    // Finally... add the explicit animation to the layer... the animation automatically starts.
    [page.layer addAnimation:pulseAnimation forKey:kBTSPulseAnimation];
    
    [self selectPageAtIndex:index WithView:page];
    [self.delegate stackView:self selectedPageAtIndex:index];
}

- (void)panned:(UIPanGestureRecognizer*)recognizer
{
    CellView *page = (CellView *)[recognizer view];
    CGPoint translation = [recognizer translationInView:page];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.trackedTranslation = 0;
    } else if (recognizer.state ==UIGestureRecognizerStateChanged) {
        CGRect pageFrame = page.frame;
        pageFrame.origin.y += translation.y;
        page.frame = pageFrame;
        
        self.trackedTranslation += translation.y;
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:page];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.trackedTranslation < -PAGE_PEAK) {
            NSInteger pageIndex = [self.pages indexOfObject:page];
            [self selectPageAtIndex:pageIndex WithView:page];
            [self.delegate stackView:self selectedPageAtIndex:pageIndex];
        } else {
            self.selectedPageIndex = -1;
            [self resetPages];
        }
    }
}

- (void)startWiggling:(UIGestureRecognizer *)gesture
{
    CellView *cell = (CellView *)[gesture view];
    

//    CellView *page = (CellView *)[gesture view];
//    NSInteger index = [self.pages indexOfObject:page];
    
    if (!cell.canShake) {
        return;
    }
    if ([gesture state] == UIGestureRecognizerStateBegan) {
//        CALayer *wiggleLayer = [[[cell layer] sublayers] lastObject];
        for (int i = 0; i < [[cell layer] sublayers].count; i++) {
            CALayer *layer = [[[cell layer] sublayers] objectAtIndex:i];
            [layer bts_startWiggling];

        }
//        [wiggleLayer bts_startWiggling];
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

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setPageAtOffset:scrollView.contentOffset];
    [self reloadVisiblePages];
}

@end
