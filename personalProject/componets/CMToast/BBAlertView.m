//
//  BBAlertView.m
//  BlueBoxDemo
//
//  Created by 刘坤 on 12-6-21.
//  Copyright (c) 2012年 Suning. All rights reserved.
//

#import "BBAlertView.h"
#import "UIView+Additions.h"
#import "CMCommonHeader.h"
#import <QuartzCore/QuartzCore.h>

#define leftBtnImage        [UIImage streImageNamed:@"button_white_normal.png"]
#define rightBtnImage       [UIImage streImageNamed:@"button_orange_normal.png"]

#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

#ifndef kScreenHeight
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#endif

#ifndef kScreenWidth
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#endif

#ifndef GetHeight
#define GetHeight(h)  (h) * kScreenWidth / 320
#endif

#ifndef GetWidth
#define GetWidth(w)   (w) * kScreenWidth / 320
#endif

#ifndef Get375Height
#define Get375Height(h)  (h) * kScreenWidth / 375
#endif

#ifndef Get375Width
#define Get375Width(w)   (w) * kScreenWidth / 375
#endif


#define kContentLabelWidth      260.0f

static CGFloat kTransitionDuration = 0.3f;
static NSMutableArray *gAlertViewStack = nil;
static UIWindow *gPreviouseKeyWindow = nil;
static UIWindow *gMaskWindow = nil;

@implementation NSObject (BBAlert)

- (void)alertCustomDlg:(NSString *)message
{
    BBAlertView *alert = [[BBAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"好的"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)dismissAllCustomAlerts
{
    for (BBAlertView *alert in gAlertViewStack)
    {
        if ([alert delegate] == self && alert.visible) {
            [alert setDelegate:nil];
            [alert dismiss];
        }
    }
}

@end

/*********************************************************************/

@interface BBAlertView()
{
    NSInteger clickedButtonIndex;
}

//orientation
- (void)registerObservers;
- (void)removeObservers;
- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation;
- (void)sizeToFitOrientation:(BOOL)transform;
- (CGAffineTransform)transformForOrientation;

+ (BBAlertView *)getStackTopAlertView;
+ (void)pushAlertViewInStack:(BBAlertView *)alertView;
+ (void)popAlertViewFromStack;

+ (void)presentMaskWindow;
+ (void)dismissMaskWindow;

+ (void)addAlertViewOnMaskWindow:(BBAlertView *)alertView;
+ (void)removeAlertViewFormMaskWindow:(BBAlertView *)alertView;

- (void)bounce0Animation;
- (void)bounce1AnimationDidStop;
- (void)bounce2AnimationDidStop;
- (void)bounceDidStop;

- (void)dismissAlertView;


//tools
+ (CGFloat)heightOfString:(NSString *)message;
@end

/*********************************************************************/

@implementation BBAlertView

@synthesize delegate = _delegate;
@synthesize visible = _visible;
@synthesize dimBackground = _dimBackground;
@synthesize style = _style;

@synthesize titleLabel = _titleLabel;
@synthesize bodyTextLabel = _bodyTextLabel;
@synthesize bodyTextView = _bodyTextView;
@synthesize customView = _customView;
@synthesize backgroundView = _backgroundView;
@synthesize contentView = _contentView;
@synthesize cancelButton = _cancelButton;
@synthesize otherButton = _otherButton;
@synthesize shouldDismissAfterConfirm = _shouldDismissAfterConfirm;
@synthesize contentAlignment = _contentAlignment;


- (void)dealloc {
    _delegate = nil;
    
    TT_RELEASE_SAFELY(_titleLabel);
    TT_RELEASE_SAFELY(_bodyTextLabel);
    TT_RELEASE_SAFELY(_bodyTextView);
    TT_RELEASE_SAFELY(_customView);
    TT_RELEASE_SAFELY(_backgroundView);
    TT_RELEASE_SAFELY(_contentView);
    TT_RELEASE_SAFELY(_cancelButton);
    TT_RELEASE_SAFELY(_otherButton);
    _cancelBlock = nil;
    _confirmBlock = nil;
    [self removeObserver:self forKeyPath:@"dimBackground"];
    [self removeObserver:self forKeyPath:@"contentAlignment"];
}

- (void)drawRect:(CGRect)rect {
    if (_dimBackground) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        size_t gradLocationsNum = 2;
        CGFloat gradLocations[2] = {0.0f, 0.0f};
        CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.40f};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
        CGColorSpaceRelease(colorSpace);
        
        //Gradient center
        CGPoint gradCenter = self.contentView.center;
        //Gradient radius
        float gradRadius = 320 ;
        //Gradient draw
        CGContextDrawRadialGradient (context, gradient, gradCenter,
                                     0, gradCenter, gradRadius,
                                     kCGGradientDrawsAfterEndLocation);
        CGGradientRelease(gradient);
    }
}

- (void)initData {
    _shouldDismissAfterConfirm = YES;
    _dimBackground = YES;
    self.backgroundColor = [UIColor clearColor];
    _contentAlignment = NSTextAlignmentCenter;
    
    [self addObserver:self
           forKeyPath:@"dimBackground"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    
    [self addObserver:self
           forKeyPath:@"contentAlignment"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"dimBackground"]) {
        [self setNeedsDisplay];
    }else if ([keyPath isEqualToString:@"contentAlignment"]){
        self.bodyTextLabel.textAlignment = self.contentAlignment;
        self.bodyTextView.textAlignment = self.contentAlignment;
    }
}

#pragma mark 5.1 before method
-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
             image:(UIImage *)image
          delegate:(id <BBAlertViewDelegate>)delegate
       cancelImage:(UIImage *)cancelImage
 otherButtonTitles:(NSString *)otherButtonTitle {
    
    return [self initWithTitle:title message:message image:image delegate:delegate cancelImage:cancelImage otherButtonTitles:otherButtonTitle showTitle:NO];
    
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id<BBAlertViewDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitle {
    
    return [self initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle showTitle:NO];
    
}


- (id)initWithContentView:(UIView *)contentView {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self initData];
        
        self.contentView = contentView;
        self.contentView.center = self.center;
        [self addSubview:self.contentView];
        _style = BBAlertViewStyleCustomView;
        
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2;
    }
    return self;
}

- (id)initWithStyle:(BBAlertViewStyle)style
              Title:(NSString *)title
            message:(NSString *)message
         customView:(UIView *)customView
           delegate:(id<BBAlertViewDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitle {
    
    return [self initWithStyle:style Title:title message:message customView:customView delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle showTitle:NO];
    
}

- (id)initWithContentY:(NSInteger)contentY
                 Title:(NSString *)title
               message:(NSString *)message
              delegate:(id <BBAlertViewDelegate>)delegate
     cancelButtonTitle:(NSString *)cancelButtonTitle
     otherButtonTitles:(NSString *)otherButtonTitle {
    
    return [self initWithContentY:contentY Title:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle showTitle:NO];
    
}

#pragma mark 5.1 new method
-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
             image:(UIImage *)image
          delegate:(id <BBAlertViewDelegate>)delegate
       cancelImage:(UIImage *)cancelImage
 otherButtonTitles:(NSString *)otherButtonTitle
         showTitle:(BOOL)showTitle {
    //如果不显示title，title置空
    if (!showTitle) {
        title = nil;
    }
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self initData];
        _delegate = delegate;
        _style = BBAlertViewStyleDefault;
        
        //content view
        CGFloat boxWidth = 270;   //弹出框宽度
        CGFloat contentWidth = 240;
        
        CGFloat frameY = 0;
        
        //X按钮 取消
        [self.cancelButton setTitle:@"" forState:UIControlStateNormal];
        [self.cancelButton setImage:cancelImage forState:UIControlStateNormal];
        [self.cancelButton setFrame:CGRectMake(boxWidth-44, 0, 44, 44)];
        [self.cancelButton setTag:0];
        [self.contentView addSubview:self.cancelButton];
        
        if (!IsStrEmpty(title)) {
            //titleLabel
            self.titleLabel.text = title;
            self.titleLabel.textColor = [UIColor colorWithRGBHex:0x222222];
            self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
            self.titleLabel.numberOfLines = 2;
            [self.contentView addSubview:self.titleLabel];
            
            CGFloat width = [title sizeOfSingleLineWithFont:self.titleLabel.font].width;
            if (width > contentWidth) {
                //两行
                self.titleLabel.frame = CGRectMake((boxWidth-contentWidth)/2.0f, 22-7, contentWidth, 34+14);
                
                frameY = 57;
            } else {
                self.titleLabel.frame = CGRectMake((boxWidth-contentWidth)/2.0f, 22-2, contentWidth, 17+4);
                
                frameY = 38;
            }
        } else{
            //图片 没有title
            self.imageViewIcon.image = image;
            self.imageViewIcon.frame = CGRectMake((boxWidth-211)/2.0f, 22, 211, 69);
            [self.contentView addSubview:self.imageViewIcon];
            
            frameY = 91;
        }
        
        //content
        if (!IsStrEmpty(message)) {
            UIFont *contentFont = [UIFont systemFontOfSize:14];
            CGFloat contentHeight = [message sizeWithFont:contentFont
                                              limitedSize:CGSizeMake(contentWidth, 1000)
                                            lineBreakMode:NSLineBreakByCharWrapping].height;
            BOOL isNeedUseTextView = NO;
            if (contentHeight > 300) {  //content最高240,12行
                isNeedUseTextView = YES;
                contentHeight = 300;
            }
            CGRect contentFrame = CGRectMake((boxWidth-contentWidth)/2.0f, frameY+11, contentWidth, contentHeight);
            //message
            if (isNeedUseTextView) {
                self.bodyTextView.text = message;
                self.bodyTextView.frame = contentFrame;
                self.bodyTextView.font = contentFont;
                self.bodyTextView.textColor = [UIColor colorWithRGBHex:0x222222];
                [self.contentView addSubview:self.bodyTextView];
            }else{
                self.bodyTextLabel.text = message;
                self.bodyTextLabel.frame = contentFrame;
                self.bodyTextLabel.font = contentFont;
                self.bodyTextLabel.textColor = [UIColor colorWithRGBHex:0x222222];
                [self.contentView addSubview:self.bodyTextLabel];
            }
            
            frameY = frameY+11+contentHeight;
        } else {
            frameY = frameY;
        }
        
        CGFloat btnTop = frameY + 20;;
        CGFloat btnHeight = 43;
        CGFloat btnWidth = boxWidth;
        
        self.otherButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.otherButton setTitleColor:[UIColor colorWithRGBHex:0xff6600]
                               forState:UIControlStateNormal];
        [self.otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
        [self.otherButton setFrame:CGRectMake((boxWidth-btnWidth)/2.0f, btnTop, btnWidth, btnHeight)];
        [self.otherButton setTag:1];
        
        //分割线
        self.seplineH.frame = CGRectMake(0, btnTop, self.width, 0.5f);
        
        [self.contentView addSubview:self.otherButton];
        [self.contentView addSubview:self.seplineH];
        frameY = frameY+22+btnHeight;
        
        CGFloat boxHeight = frameY;
        CGRect boxFrame = CGRectMake((self.width-boxWidth)/2.0f, (self.height-boxHeight)/2.0f, boxWidth, boxHeight);
        self.contentView.frame = boxFrame;
        self.contentView.clipsToBounds = YES;
        self.contentView.layer.cornerRadius = 8.0f;
        self.contentView.backgroundColor = [UIColor colorWithRGBHex:0xffffff];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2;
    }

    return self;
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id<BBAlertViewDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitle
          showTitle:(BOOL)showTitle {
    
    return [self initWithContentY:0 Title:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle showTitle:showTitle];
    
}

- (id)initWithStyle:(BBAlertViewStyle)style
              Title:(NSString *)title
            message:(NSString *)message
         customView:(UIView *)customView
           delegate:(id<BBAlertViewDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitle
          showTitle:(BOOL)showTitle
{
    //如果不显示title，title置空
    if (!showTitle) {
        title = nil;
    }
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _style = style;
        switch (style) {
            case BBAlertViewStyleDefault:
            {
                return [self initWithTitle:title
                                   message:message
                                  delegate:delegate
                         cancelButtonTitle:cancelButtonTitle
                         otherButtonTitles:otherButtonTitle
                        showTitle:showTitle];
                break;
                
            }
            case BBAlertViewStyleCustomView:
            {
                BBAlertView *al = [self initWithTitle:title
                                              message:message
                                             delegate:delegate
                                    cancelButtonTitle:cancelButtonTitle
                                    otherButtonTitles:otherButtonTitle
                                   showTitle:showTitle];
                al.customView = customView;
                [al.contentView addSubview:customView];
                al.contentView.width = customView.width;
                
                al.bodyTextView.hidden  = al.bodyTextLabel.hidden = al.titleLabel.hidden = YES;
                al.customView.frame = CGRectMake(0, 0, al.customView.width, al.customView.height);
                
                al.cancelButton.top = al.otherButton.top = customView.height + 22;
                al.contentView.height = MAX(al.cancelButton.bottom, al.otherButton.bottom);
                
                al.seplineH.frame = CGRectMake(0, al.cancelButton.top, al.contentView.width, 0.5f);
                if (cancelButtonTitle && otherButtonTitle) {
                    al.cancelButton.width = al.contentView.width/2.0f;
                    al.otherButton.left = al.cancelButton.right;
                    al.otherButton.width = al.contentView.width/2.0f;
                    al.seplineV.frame = CGRectMake(al.cancelButton.right, al.cancelButton.top, 0.5f, al.cancelButton.height);
                } else {
                    al.cancelButton.width = al.contentView.width;
                    al.otherButton.width = al.contentView.width;
                    al.seplineV.hidden = YES;
                }
                
                CGRect boxFrame = CGRectMake((al.width-al.contentView.width)/2.0f, (al.height-al.contentView.height)/2.0f, al.contentView.width, al.contentView.height);
                al.contentView.frame = boxFrame;
                
                return al;
                break;
                
            }
            case BBAlertViewStyleCustomViewNew:
            {
                BBAlertView *al = [self initWithTitle:title
                                              message:nil
                                             delegate:delegate
                                    cancelButtonTitle:cancelButtonTitle
                                    otherButtonTitles:otherButtonTitle
                                            showTitle:showTitle];
                al.customView = customView;
                [al.contentView addSubview:customView];
                al.contentView.width = customView.width;
                
                al.titleLabel.hidden = !showTitle;
                CGFloat customTop = showTitle?al.titleLabel.bottom+0.5f:0;
                al.customView.frame = CGRectMake(0, customTop, al.customView.width, al.customView.height);
                
                al.cancelButton.top = al.otherButton.top = customView.bottom;
                al.contentView.height = MAX(al.cancelButton.bottom, al.otherButton.bottom);
                
                al.seplineH.frame = CGRectMake(0, al.cancelButton.top, al.contentView.width, 0.5f);
                if (cancelButtonTitle && otherButtonTitle) {
                    al.cancelButton.width = al.contentView.width/2.0f;
                    al.otherButton.left = al.cancelButton.right;
                    al.otherButton.width = al.contentView.width/2.0f;
                    al.seplineV.frame = CGRectMake(al.cancelButton.right, al.cancelButton.top, 0.5f, al.cancelButton.height);
                } else {
                    al.cancelButton.width = al.contentView.width;
                    al.otherButton.width = al.contentView.width;
                    al.seplineV.hidden = YES;
                }
                
                CGRect boxFrame = CGRectMake((al.width-al.contentView.width)/2.0f, (al.height-al.contentView.height)/2.0f, al.contentView.width, al.contentView.height);
                al.contentView.frame = boxFrame;
                
                return al;
                break;
                
            }
            default:
                break;
        }
    }
    return self;
}

- (id)initWithContentY:(NSInteger)contentY
                 Title:(NSString *)title
               message:(NSString *)message
              delegate:(id <BBAlertViewDelegate>)delegate
     cancelButtonTitle:(NSString *)cancelButtonTitle
     otherButtonTitles:(NSString *)otherButtonTitle
             showTitle:(BOOL)showTitle {
    //如果不显示title，title置空
    if (!showTitle) {
        title = nil;
    }
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self initData];
        _delegate = delegate;
        _style = BBAlertViewStyleDefault;
        
        //默认为系统提示
        if (![title length]) {
            //title = L(@"system-error");
        }
        
        //content view
        CGFloat boxWidth = 270;   //弹出框宽度
        CGFloat contentWidth = 240;
        
        CGFloat frameY = 0;
        
        //titleLabel
        if (!IsStrEmpty(title)) {
            self.titleLabel.text = title;
            self.titleLabel.textColor = [UIColor colorWithRGBHex:0x222222];
            self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
            self.titleLabel.numberOfLines = 2;
            [self.contentView addSubview:self.titleLabel];
            
            CGFloat width = [title sizeOfSingleLineWithFont:self.titleLabel.font].width;
            if (width > contentWidth) {
                //两行
                self.titleLabel.frame = CGRectMake((boxWidth-contentWidth)/2.0f, 22-7, contentWidth, 34+14);
                
                frameY = 57;
            } else {
                self.titleLabel.frame = CGRectMake((boxWidth-contentWidth)/2.0f, 22-2, contentWidth, 17+4);
                
                frameY = 38;
            }
        } else {
            frameY = 7;
        }
        
        //content
        if (!IsStrEmpty(message)) {
            UIFont *contentFont = [UIFont systemFontOfSize:14];
            CGFloat contentHeight = [message sizeWithFont:contentFont
                                              limitedSize:CGSizeMake(contentWidth, 1000)
                                            lineBreakMode:NSLineBreakByCharWrapping].height;
            BOOL isNeedUseTextView = NO;
            if (contentHeight > 300) {  //content最高240,12行
                isNeedUseTextView = YES;
                contentHeight = 300;
            }
            CGRect contentFrame = CGRectMake((boxWidth-contentWidth)/2.0f, frameY+11, contentWidth, contentHeight);
            //message
            if (isNeedUseTextView) {
                self.bodyTextView.text = message;
                self.bodyTextView.frame = contentFrame;
                self.bodyTextView.font = contentFont;
                self.bodyTextView.textColor = [UIColor colorWithRGBHex:0x222222];
                [self.contentView addSubview:self.bodyTextView];
            }else{
                self.bodyTextLabel.text = message;
                self.bodyTextLabel.frame = contentFrame;
                self.bodyTextLabel.font = contentFont;
                self.bodyTextLabel.textColor = [UIColor colorWithRGBHex:0x222222];
                [self.contentView addSubview:self.bodyTextLabel];
            }
            
            frameY = frameY+11+contentHeight;
        } else {
            frameY = frameY;
        }
        
        //button
        CGFloat btnTop = frameY+22;
        CGFloat btnHeight = 43;
        if (cancelButtonTitle && otherButtonTitle) {
            CGFloat btnWidth = boxWidth/2.0f;
            
            [self.cancelButton setTitleColor:[UIColor colorWithRGBHex:0x999999]
                                    forState:UIControlStateNormal];
            self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [self.cancelButton setFrame:CGRectMake(0, btnTop, btnWidth, btnHeight)];
            [self.cancelButton setTag:0];
            
            [self.otherButton setTitleColor:[UIColor colorWithRGBHex:0xff6600]
                                   forState:UIControlStateNormal];
            self.otherButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [self.otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
            [self.otherButton setFrame:CGRectMake(self.cancelButton.right, btnTop, btnWidth, btnHeight)];
            [self.otherButton setTag:1];
            
            //分割线
            self.seplineH.frame = CGRectMake(0, self.cancelButton.top, self.width, 0.5f);
            self.seplineV.frame = CGRectMake(self.cancelButton.right, self.cancelButton.top, 0.5f, btnHeight);
            
            [self.contentView addSubview:self.cancelButton];
            [self.contentView addSubview:self.otherButton];
            [self.contentView addSubview:self.seplineH];
            [self.contentView addSubview:self.seplineV];
        } else if (cancelButtonTitle){
            CGFloat btnWidth = boxWidth;
            self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [self.cancelButton setTitleColor:[UIColor colorWithRGBHex:0x999999]
                                    forState:UIControlStateNormal];
            [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [self.cancelButton setFrame:CGRectMake((boxWidth-btnWidth)/2.0f, btnTop, btnWidth, btnHeight)];
            [self.cancelButton setTag:0];
            
            //分割线
            self.seplineH.frame = CGRectMake(0, self.cancelButton.top, self.width, 0.5f);
            
            [self.contentView addSubview:self.cancelButton];
            [self.contentView addSubview:self.seplineH];
        } else if (otherButtonTitle){
            CGFloat btnWidth = boxWidth;
            
            self.otherButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [self.otherButton setTitleColor:[UIColor colorWithRGBHex:0xff6600]
                                   forState:UIControlStateNormal];
            [self.otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
            [self.otherButton setFrame:CGRectMake((boxWidth-btnWidth)/2.0f, btnTop, btnWidth, btnHeight)];
            [self.otherButton setTag:0];
            
            //分割线
            self.seplineH.frame = CGRectMake(0, self.otherButton.top, self.width, 0.5f);
            
            [self.contentView addSubview:self.seplineH];
            [self.contentView addSubview:self.otherButton];
        }
        frameY = frameY+22+btnHeight;
        
        CGFloat boxHeight = frameY;
        CGRect boxFrame = CGRectMake((self.width-boxWidth)/2.0f, (self.height-boxHeight)/2.0f, boxWidth, boxHeight);
        self.contentView.frame = boxFrame;
        self.contentView.top = self.contentView.top+contentY;
        self.contentView.clipsToBounds = YES;
        self.contentView.layer.cornerRadius = 8.0f;
        self.contentView.backgroundColor = [UIColor colorWithRGBHex:0xffffff];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2;
    }
    return self;
}

#pragma mark orientation

- (void)registerObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationDidChange:(NSNotification*)notify
{
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ([self shouldRotateToOrientation:orientation]) {
        if ([_delegate respondsToSelector:@selector(didRotationToInterfaceOrientation:view:alertView:)]) {
            [_delegate didRotationToInterfaceOrientation:UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) view:_customView alertView:self];
        }
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [self sizeToFitOrientation:YES];
        [UIView commitAnimations];
    }
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation
{
    BOOL result = NO;
    if (_orientation != orientation) {
        result = (orientation == UIInterfaceOrientationPortrait ||
                  orientation == UIInterfaceOrientationPortraitUpsideDown ||
                  orientation == UIInterfaceOrientationLandscapeLeft ||
                  orientation == UIInterfaceOrientationLandscapeRight);
    }
    
    return result;
}

- (void)sizeToFitOrientation:(BOOL)transform
{
    if (transform) {
        self.transform = CGAffineTransformIdentity;
    }
    _orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self sizeToFit];
    [self setCenter:CGPointMake(kScreenWidth/2.0f, kScreenHeight/2.0f)];
    if (transform) {
        self.transform = [self transformForOrientation];
    }
}

- (CGAffineTransform)transformForOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5f);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2.0f);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}


#pragma mark -
#pragma mark view getters
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (UILabel *)bodyTextLabel {
    if (!_bodyTextLabel) {
        _bodyTextLabel = [[UILabel alloc] init];
        _bodyTextLabel.numberOfLines = 0;
        _bodyTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _bodyTextLabel.textAlignment = _contentAlignment;
        _bodyTextLabel.backgroundColor = [UIColor clearColor];
    }
    return _bodyTextLabel;
}

- (UITextView *)bodyTextView {
    if (!_bodyTextView) {
        _bodyTextView = [[UITextView alloc] init];
        _bodyTextView.textAlignment = _contentAlignment;
        _bodyTextView.bounces = NO;
        _bodyTextView.backgroundColor = [UIColor clearColor];
        _bodyTextView.editable = NO;
    }
    return _bodyTextView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitle:@"好的" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)otherButton{
    if (!_otherButton) {
        _otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_otherButton setTitle:@"好的" forState:UIControlStateNormal];
        [_otherButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherButton;
}

- (UIView *)seplineH {
    if (!_seplineH) {
        _seplineH = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5f)];
        _seplineH.backgroundColor = [UIColor colorWithRGBHex:0xdadada];
    }
    return _seplineH;
}

- (UIView *)seplineV {
    if (!_seplineV) {
        _seplineV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5f, 41)];
        _seplineV.backgroundColor = [UIColor colorWithRGBHex:0xdadada];
    }
    return _seplineV;
}

-(UIImageView *)imageViewIcon{
    
    if (!_imageViewIcon) {
        
        _imageViewIcon = [[UIImageView alloc] init];
        
    }
    
    return _imageViewIcon;
}

#pragma mark -
#pragma mark block setter

- (void)setCancelBlock:(BBBasicBlock)block
{
    _cancelBlock = [block copy];
}

- (void)setConfirmBlock:(BBBasicBlock)block
{
    _confirmBlock = [block copy];
}

#pragma mark -
#pragma mark button action

- (void)buttonTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    clickedButtonIndex = tag;
    
    if ([_delegate conformsToProtocol:@protocol(BBAlertViewDelegate)]) {
        
        if ([_delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
            
            [_delegate alertView:self willDismissWithButtonIndex:tag];
        }
    }
    
    if (button == self.cancelButton) {
        if (_cancelBlock) {
            _cancelBlock();
        }
        [self dismiss];
    }
    else if (button == self.otherButton)
    {
        if (_confirmBlock) {
            _confirmBlock();
        }
        if (_shouldDismissAfterConfirm) {
            [self dismiss];
        }
    }
    
}

#pragma mark -
#pragma mark lify cycle

- (void)show
{
    if (_visible) {
        return;
    }
    _visible = YES;
    
    [self registerObservers];//添加消息，在设备发生旋转时会有相应的处理
    [self sizeToFitOrientation:YES];
    
    
    //如果栈中没有alertview,就表示maskWindow没有弹出，所以弹出maskWindow
    if (![BBAlertView getStackTopAlertView]) {
        [BBAlertView presentMaskWindow];
    }
    
    //如果有背景图片，添加背景图片
    if (nil != self.backgroundView && ![[gMaskWindow subviews] containsObject:self.backgroundView]) {
        [gMaskWindow addSubview:self.backgroundView];
    }
    //将alertView显示在window上
    [BBAlertView addAlertViewOnMaskWindow:self];
    
    self.alpha = 1.0;
    
    //alertView弹出动画
    [self bounce0Animation];
    
    if (!IOS10_OR_LATER)
    {
        [self becomeFirstResponder];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)dismiss
{
    if (!_visible) {
        return;
    }
    _visible = NO;
    
    UIView *__bgView = self->_backgroundView;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissAlertView)];
    self.alpha = 0;
    [UIView commitAnimations];
    
    if (__bgView && [[gMaskWindow subviews] containsObject:__bgView]) {
        [__bgView removeFromSuperview];
    }
}

- (void)dismissAlertView{
    [BBAlertView removeAlertViewFormMaskWindow:self];
    
    // If there are no dialogs visible, dissmiss mask window too.
    if (![BBAlertView getStackTopAlertView]) {
        [BBAlertView dismissMaskWindow];
    }
    
    if (_style != BBAlertViewStyleCustomView) {
        if ([_delegate conformsToProtocol:@protocol(BBAlertViewDelegate)]) {
            if ([_delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
                [_delegate alertView:self didDismissWithButtonIndex:clickedButtonIndex];
            }
        }
    }
    
    [self removeObservers];
}


+ (void)presentMaskWindow{
    
    if (!gMaskWindow) {
        gMaskWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        
        //edited by gjf 修改alertview leavel
        gMaskWindow.windowLevel = UIWindowLevelStatusBar + 300;
        gMaskWindow.backgroundColor = [UIColor clearColor];
        gMaskWindow.hidden = YES;
        
        // FIXME: window at index 0 is not awalys previous key window.
        gPreviouseKeyWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [gMaskWindow makeKeyAndVisible];
        
        // Fade in background
        gMaskWindow.alpha = 0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        gMaskWindow.alpha = 1;
        [UIView commitAnimations];
    }
}

+ (void)dismissMaskWindow{
    // make previouse window the key again
    if (gMaskWindow) {
        [gPreviouseKeyWindow makeKeyWindow];
        gPreviouseKeyWindow = nil;
        
        gMaskWindow = nil;
    }
}

+ (BBAlertView *)getStackTopAlertView{
    BBAlertView *topItem = nil;
    if (0 != [gAlertViewStack count]) {
        topItem = [gAlertViewStack lastObject];
    }
    
    return topItem;
}

+ (void)addAlertViewOnMaskWindow:(BBAlertView *)alertView{
    if (!gMaskWindow ||[gMaskWindow.subviews containsObject:alertView]) {
        return;
    }
    
    [gMaskWindow addSubview:alertView];
    alertView.hidden = NO;
    
    BBAlertView *previousAlertView = [BBAlertView getStackTopAlertView];
    if (previousAlertView) {
        previousAlertView.hidden = YES;
    }
    [BBAlertView pushAlertViewInStack:alertView];
}

+ (void)removeAlertViewFormMaskWindow:(BBAlertView *)alertView{
    if (!gMaskWindow || ![gMaskWindow.subviews containsObject:alertView]) {
        return;
    }
    
    [alertView removeFromSuperview];
    alertView.hidden = YES;
    
    [BBAlertView popAlertViewFromStack];
    BBAlertView *previousAlertView = [BBAlertView getStackTopAlertView];
    if (previousAlertView) {
        previousAlertView.hidden = NO;
        [previousAlertView bounce0Animation];
    }
}

+ (void)pushAlertViewInStack:(BBAlertView *)alertView{
    if (!gAlertViewStack) {
        gAlertViewStack = [[NSMutableArray alloc] init];
    }
    [gAlertViewStack addObject:alertView];
}


+ (void)popAlertViewFromStack{
    if (![gAlertViewStack count]) {
        return;
    }
    [gAlertViewStack removeLastObject];
    
    if ([gAlertViewStack count] == 0) {
        gAlertViewStack = nil;
    }
}


#pragma mark -
#pragma mark animation

- (void)bounce0Animation{
    self.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001f, 0.001f);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationDidStop)];
    self.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1f, 1.1f);
    [UIView commitAnimations];
}

- (void)bounce1AnimationDidStop{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationDidStop)];
    self.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9f, 0.9f);
    [UIView commitAnimations];
}

- (void)bounce2AnimationDidStop{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounceDidStop)];
    self.contentView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

- (void)bounceDidStop{
    
}

#pragma mark -
#pragma mark tools

+ (CGFloat)heightOfString:(NSString *)message
{
    if (message == nil || [message isEqualToString:@""]) {
        return 20.0f;
    }
    CGSize messageSize = [message sizeWithFont:[UIFont systemFontOfSize:16.0]
                                   limitedSize:CGSizeMake(kContentLabelWidth, 1000)
                                 lineBreakMode:NSLineBreakByCharWrapping];
    
    return messageSize.height+10.0;
}

@end
