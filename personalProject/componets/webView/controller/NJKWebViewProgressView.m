//
//  NJKWebViewProgressView.m
//
//  Created by Satoshi Aasanoon 11/16/13.
//  Copyright (c) 2013 Satoshi Asano. All rights reserved.
//

#import "NJKWebViewProgressView.h"

@interface NJKWebViewProgressView ()

@property(nonatomic, assign) CGFloat fakeProgress;//假进度
@property(nonatomic, assign) CGFloat viewProgress;//进度条进度

@end

@implementation NJKWebViewProgressView

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureViews];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureViews];
}

-(void)configureViews
{
    self.userInteractionEnabled = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _progressBarView = [[UIView alloc] initWithFrame:self.bounds];
    _progressBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    UIColor *tintColor = [UIColor colorWithRed:22.f / 255.f green:126.f / 255.f blue:251.f / 255.f alpha:1.0]; // iOS7 Safari bar color
    
    /* @xzoscar 2015/12/21
    if ([UIApplication.sharedApplication.delegate.window respondsToSelector:@selector(setTintColor:)] && UIApplication.sharedApplication.delegate.window.tintColor) {
        tintColor = UIApplication.sharedApplication.delegate.window.tintColor;
    }*/
     
    _progressBarView.backgroundColor = tintColor;
    [self addSubview:_progressBarView];
    
    _barAnimationDuration = 1.0f;
    _fadeAnimationDuration = 1.0f;
    _fadeOutDelay = 0.5f;
}

-(void)setProgress:(float)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    //假进度条
    if (fabs(progress-0.1) < FLT_EPSILON) {//重新开始
        self.fakeProgress = progress;
        [self performSelector:@selector(setFakeProgressWithNumber:) withObject:[NSNumber numberWithFloat:0.3f] afterDelay:0.3f];
    } else if (progress == 1.0f) {//结束
        self.fakeProgress = 1.0f;
    }
    
    //不是重新开始，进度小于进度条进度，不处理
    if (progress>0 && progress<self.viewProgress) {
        return;
    }
    
    self.viewProgress = progress;
    
    //更新进度条
    BOOL isGrowing = progress > 0.0;
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:(isGrowing && animated) ? _barAnimationDuration : 0.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = weakSelf.progressBarView.frame;
        frame.size.width = progress * self.bounds.size.width;
        weakSelf.progressBarView.frame = frame;
    } completion:nil];

    //展示、隐藏进度条
    if (progress >= 1.0) {
        [UIView animateWithDuration:animated ? _fadeAnimationDuration : 0.0 delay:_fadeOutDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
            weakSelf.progressBarView.alpha = 0.0;
        } completion:^(BOOL completed){
            CGRect frame = weakSelf.progressBarView.frame;
            frame.size.width = 0;
            weakSelf.progressBarView.frame = frame;
        }];
    }
    else {
        [UIView animateWithDuration:animated ? _fadeAnimationDuration : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            weakSelf.progressBarView.alpha = 1.0;
        } completion:nil];
    }
}

- (void)setFakeProgressWithNumber:(NSNumber *)progressNumber {
    //如果当前进度为1，不设置
    if (self.fakeProgress >= 1.0f) {
        return;
    }
    
    self.fakeProgress = [progressNumber floatValue];
    [self setProgress:self.fakeProgress animated:YES];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.fakeProgress == 0.3f) {
        [self performSelector:@selector(setFakeProgressWithNumber:) withObject:[NSNumber numberWithFloat:0.5f] afterDelay:0.5];
    } else if (self.fakeProgress == 0.5f) {
        [self performSelector:@selector(setFakeProgressWithNumber:) withObject:[NSNumber numberWithFloat:0.8] afterDelay:1];
    }
}

@end
