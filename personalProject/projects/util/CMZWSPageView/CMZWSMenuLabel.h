//
//  CMZWSMenuLabel.h
//

#import <Foundation/Foundation.h>
#import "CMZWSFlowMenu.h"

@interface CMZWSMenuLabel : UILabel <CMZWSMenuAppearance>

@property (nonatomic, strong) UIFont *highlightedFont;

- (void)transformColor:(float)progress;

- (void)transformFont:(float)progress;

@end
