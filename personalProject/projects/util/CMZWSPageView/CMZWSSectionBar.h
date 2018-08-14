//
//  JHSBrandSectionBar.h
//

#import <UIKit/UIKit.h>
#import "CMZWSFlowMenu.h"
#import "CMZWSMenuLabel.h"
#import "CMCommonHeader.h"

@protocol CMZWSSectionBarDelegate;

@interface CMZWSSectionBar : CMZWSFlowMenu {
    UITapGestureRecognizer *_tapGestureRecognizer;
    NSArray *_titles;
}

@property (nonatomic, strong) UIColor *textColor; // Default: grayColor
@property (nonatomic, strong) UIColor *highlightedTextColor; // Default: redColor
@property (nonatomic, assign) CGFloat indicatorHeight; // Default: 2px
/**
 @return `highlightedTextColor` if the value is nil
 */
@property (nonatomic, strong) UIColor *indicatorColor;

@property (nonatomic, strong) UIFont *nomarlTextFont; // Default: 14.0f
@property (nonatomic, strong) UIFont *selectedTextFont; // Default: 15.0f

@property(nonatomic, strong) NSArray *titles;
@property(nonatomic, assign) CGSize itemSize;

@property(nonatomic, weak) id<CMZWSSectionBarDelegate> barDelegate;

- (UIView *)itemForTitle:(NSString *)title;

@end

@protocol CMZWSSectionBarDelegate<NSObject>

@optional

- (void)sectionBar:(CMZWSSectionBar *)sectionBar didSelectAtInedx:(NSUInteger)index;

- (void)didCreateItemView:(UIView *)itemView;

- (UIView *)menuItemWithTitle:(NSString *)title;

@end
