//
//  CMToast.m
//  SuningEBuy
//
//  Created by xzoscar on 15/11/16.
//  Copyright © 2015年 苏宁易购. All rights reserved.
//

#import "CMToast.h"

@interface CMToastView : UIView<CAAnimationDelegate>

@property(nonatomic, strong) UILabel *textLabel;

@property(nonatomic, strong) UIView *iconView;

@property(nonatomic, strong) CAShapeLayer *circleLayer;

@property(nonatomic, strong) CAShapeLayer *rightLayer;

- (id)initWithString:(NSString *)toastString;

- (void)setToastString:(NSString *)toastString;

@end

@implementation CMToastView

- (id)initWithString:(NSString *)toastString {
    if (self = [super init]) {
        
        {
            self.backgroundColor    = [UIColor blackColor];
            self.clipsToBounds      = YES;
            self.layer.cornerRadius = 4.0f;
        }
        
        if (nil != toastString) {
            [self setToastString:toastString];
        }
    }
    return self;
}

#pragma mark toast
- (void)toast {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self addSubview:self.textLabel];
    
    NSArray *hLys =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[_textLabel]-12-|"
                                            options:0
                                            metrics:nil
                                              views:NSDictionaryOfVariableBindings(_textLabel)];
    NSArray *vLys =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[_textLabel]-24-|"
                                            options:0
                                            metrics:nil
                                              views:NSDictionaryOfVariableBindings(_textLabel)];
    [self addConstraints:hLys];
    [self addConstraints:vLys];
}

#pragma mark toastSuccess
- (void)toastSuccess {
    //移除以前的
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.iconView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    [self addSubview:self.iconView];
    [self addSubview:self.textLabel];
    
    //textLabel
    NSArray *hLys =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_textLabel]-15-|"
                                            options:0
                                            metrics:nil
                                              views:NSDictionaryOfVariableBindings(_textLabel)];
    NSArray *vLys =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-49-[_textLabel]-15-|"
                                            options:0
                                            metrics:nil
                                              views:NSDictionaryOfVariableBindings(_textLabel)];
    [self addConstraints:hLys];
    [self addConstraints:vLys];
    
    //iconView
    NSLayoutConstraint *xLyout =
    [NSLayoutConstraint constraintWithItem:self
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.iconView
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0f
                                  constant:.0f];
    hLys =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=26)-[_iconView(26)]-(>=26)-|"
                                            options:0
                                            metrics:nil
                                              views:NSDictionaryOfVariableBindings(_iconView)];
    vLys =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-11-[_iconView(26)]"
                                            options:0
                                            metrics:nil
                                              views:NSDictionaryOfVariableBindings(_iconView)];
    [self addConstraint:xLyout];
    [self addConstraints:hLys];
    [self addConstraints:vLys];
    
    //弹出动画
    self.iconView.hidden = YES;
    [self drawBounceAnimation];
    
    //创建外部圆形的图层
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.iconView.hidden = NO;
        
        [weakSelf drawCircleAnimation];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf drawRightAnimation];
    });
}

- (void)drawBounceAnimation {
    CAKeyframeAnimation *zoomAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    zoomAnimation.values = @[@1.01, @1.2, @0.96, @1.0];
    zoomAnimation.duration = 0.45f;
    zoomAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:zoomAnimation forKey:@"drawBounceAnimation_zoom"];
}

- (void)drawCircleAnimation {
    self.circleLayer = [CAShapeLayer layer];
    self.circleLayer.frame = CGRectMake(0, 0, 26, 26);
    self.circleLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.iconView.layer addSublayer:self.circleLayer];
    
    self.circleLayer.strokeStart = 0.2f;// 设置最终效果，防止动画结束之后效果改变
    self.circleLayer.strokeEnd = 1.0f;
    
    const int STROKE_WIDTH = 2;// 默认的划线线条宽度
    
    // 设置当前图层的绘制属性
    self.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.lineCap = kCALineCapRound;// 圆角画笔
    self.circleLayer.lineWidth = STROKE_WIDTH;
    
    // 半圆+动画的绘制路径初始化
    UIBezierPath *path = [UIBezierPath bezierPath];
    // 绘制大半圆
    [path addArcWithCenter:CGPointMake(self.circleLayer.frame.size.width/2.0f, self.circleLayer.frame.size.height/2.0f) radius:self.circleLayer.frame.size.width/2.0f-STROKE_WIDTH+1.0f startAngle:180*M_PI/180 endAngle:-270*M_PI/180 clockwise:NO];
    // 把路径设置为当前图层的路径
    self.circleLayer.path = path.CGPath;
    
    CGFloat duration = 0.35f;
    
    // 创建路径顺序绘制的动画
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.duration = duration;// 动画使用时间
    strokeEndAnimation.fromValue = [NSNumber numberWithFloat:0.0f];// 从头
    strokeEndAnimation.toValue = [NSNumber numberWithFloat:1.0f];// 画到尾
    
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.duration = duration;// 动画使用时间
    strokeStartAnimation.fromValue = [NSNumber numberWithFloat:0.0f];// 从头
    strokeStartAnimation.toValue = [NSNumber numberWithFloat:0.2f];// 画到尾
    
    [self.circleLayer addAnimation:strokeEndAnimation forKey:@"drawCircleAnimation_strokeEnd"];// 添加俩动画
    [self.circleLayer addAnimation:strokeStartAnimation forKey:@"drawCircleAnimation_strokeStart"];
}

- (void)drawRightAnimation{
    self.rightLayer = [CAShapeLayer layer];
    self.rightLayer.frame = CGRectMake(0, 0, 26, 26);
    self.rightLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.circleLayer addSublayer:self.rightLayer];
    
    self.rightLayer.strokeStart = 0;// 设置最终效果，防止动画结束之后效果改变
    self.rightLayer.strokeEnd = 1.0f;
    
    const int STROKE_WIDTH = 2;// 默认的划线线条宽度
    
    // 设置当前图层的绘制属性
    self.rightLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.rightLayer.fillColor = [UIColor clearColor].CGColor;
    self.rightLayer.lineCap = kCALineCapRound;// 圆角画笔
    self.rightLayer.lineWidth = STROKE_WIDTH;
    
    // 半圆+动画的绘制路径初始化
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.rightLayer.frame.size.width * 0.27, self.rightLayer.frame.size.width * 0.52)];
    // 绘制对号第一笔
    [path addLineToPoint:CGPointMake(self.rightLayer.frame.size.width * 0.42, self.rightLayer.frame.size.width * 0.67)];
    // 绘制对号第二笔
    [path addLineToPoint: CGPointMake(self.rightLayer.frame.size.width * 0.75, self.rightLayer.frame.size.width * 0.38)];
    // 把路径设置为当前图层的路径
    self.rightLayer.path = path.CGPath;
    
    // 创建路径顺序从结尾开始消失的动画
    CAKeyframeAnimation *strokeEndAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.values = @[@0, @1.0, @0.8, @1.0];
    strokeEndAnimation.duration = 0.67f;
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.rightLayer addAnimation:strokeEndAnimation forKey:@"drawRightAnimation_strokeEnd"];
}

#pragma mark property
- (UILabel *)textLabel {
    if (nil == _textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:14.0f];
        _textLabel.textColor    = [UIColor whiteColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _textLabel;
}

- (UIView *)iconView {
    if (nil == _iconView) {
        _iconView = [[UIView alloc] init];
        _iconView.backgroundColor = [UIColor clearColor];
        
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _iconView;
}

- (void)setToastString:(NSString *)toastString {
    self.textLabel.text = toastString;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    self.hidden = YES;
}

@end

@interface CMToast ()
@property (nonatomic,strong) CMToastView *toastView;
@end

@implementation CMToast

+ (CMToast *)sharedToast {
    static dispatch_once_t once;
    static CMToast *obj = nil;
    dispatch_once(&once, ^{
        obj = [[CMToast alloc] init];
    });
    return obj;
}

- (CMToastView *)toastView {
    if (nil == _toastView) {
        _toastView = [[CMToastView alloc] initWithString:nil];
    }
    return _toastView;
}

- (void)animateToVisible {
    if (nil != _toastView && !_toastView.hidden) {
        // animate to show
        _toastView.alpha  = .0f;
        [UIView animateWithDuration:.35f animations:^{
            _toastView.alpha = 0.8f;
        } completion:^(BOOL finished) {
            [self performSelector:@selector(hideToast) withObject:nil afterDelay:2.5f];
        }];
    }
}

- (void)hideToast {
    if (nil != _toastView) {
        [_toastView setHidden:YES];
    }
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (void)showToast {
    if (nil != _toastView) {
        [self.class cancelPreviousPerformRequestsWithTarget:self
                                                   selector:@selector(hideToast)
                                                     object:nil];
        
        [_toastView toast];
        [_toastView setHidden:NO];
        // bringSubviewToFront
        [_toastView.superview bringSubviewToFront:_toastView];
        [self animateToVisible];
    }
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, _toastView.textLabel);
}

- (void)showSuccessToast {
    if (nil != _toastView) {
        [self.class cancelPreviousPerformRequestsWithTarget:self
                                                   selector:@selector(hideToast)
                                                     object:nil];
        
        [_toastView toastSuccess];
        [_toastView setHidden:NO];
        [_toastView.superview bringSubviewToFront:_toastView];
        [self animateToVisible];
    }
}

- (void)removeToastFromSuperView {
    if (nil != _toastView) {
        [_toastView removeFromSuperview];
    }
}

/*
 * toast on top 'fromView'
 * @xzoscar
 */

+ (void)toast:(NSString *)toastString view:(UIView *)fromView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (nil == toastString || toastString.length == 0 || nil == fromView) {
            return;
        }
        [[self sharedToast] hideToast];
        
        if (![fromView.subviews containsObject:[self sharedToast].toastView]) {
            [fromView addSubview:[self sharedToast].toastView];
            
            // layout
            CMToastView *toastView = [self sharedToast].toastView;
            toastView.translatesAutoresizingMaskIntoConstraints = NO;
            NSLayoutConstraint *xLyout =
            [NSLayoutConstraint constraintWithItem:fromView
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:toastView
                                         attribute:NSLayoutAttributeCenterX
                                        multiplier:1.0f
                                          constant:.0f];
            NSLayoutConstraint *yLyout =
            [NSLayoutConstraint constraintWithItem:fromView
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:toastView
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0f
                                          constant:.0f];
            
            NSArray *hLays = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=44)-[toastView]-(>=44)-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(toastView)];
            [fromView addConstraint:xLyout];
            [fromView addConstraint:yLyout];
            [fromView addConstraints:hLays];
        }
        
        [[self sharedToast].toastView setToastString:toastString];
        [[self sharedToast] showToast];

    });
    
}

/*
 * toast on top window
 * @xzoscar
 */
+ (void)toast:(NSString *)toastString {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].windows.firstObject;
        [self.class toast:toastString view:win];
        
    });
}

#pragma mark toastSuccess
/*
 * toast on top window
 * @xzoscar
 */
+ (void)toastSuccess:(NSString *)toastString {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].windows.firstObject;
        [self.class toastSuccess:toastString view:win];
        
    });
}

/*
 * toast on top 'fromView'
 * @xzoscar
 */

+ (void)toastSuccess:(NSString *)toastString view:(UIView *)fromView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (nil == toastString || toastString.length == 0 || nil == fromView) {
            return;
        }
        [[self sharedToast] hideToast];
        
        if (![fromView.subviews containsObject:[self sharedToast].toastView]) {
            [fromView addSubview:[self sharedToast].toastView];
            
            // layout
            CMToastView *toastView = [self sharedToast].toastView;
            toastView.translatesAutoresizingMaskIntoConstraints = NO;
            NSLayoutConstraint *xLyout =
            [NSLayoutConstraint constraintWithItem:fromView
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:toastView
                                         attribute:NSLayoutAttributeCenterX
                                        multiplier:1.0f
                                          constant:.0f];
            NSLayoutConstraint *yLyout =
            [NSLayoutConstraint constraintWithItem:fromView
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:toastView
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0f
                                          constant:.0f];
            
            NSArray *hLays = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=44)-[toastView]-(>=44)-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(toastView)];
            [fromView addConstraint:xLyout];
            [fromView addConstraint:yLyout];
            [fromView addConstraints:hLays];
        }
        
        [[self sharedToast].toastView setToastString:toastString];
        [[self sharedToast] showSuccessToast];
        
    });
}

#pragma mark hideToast
/*
 * hide Toast
 * @xzoscar
 */
+ (void)hideToast {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedToast] hideToast];
    });
}

@end
