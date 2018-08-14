//
//  CMZWSFlowMenu.m
//

#import "CMZWSFlowMenu.h"

@interface CMZWSFlowMenu () {
    NSMutableArray *_items;
}
@end

@implementation CMZWSFlowMenu

- (NSInteger)indexOfItemContainsPoint:(CGPoint)p {
    CGPoint p1 = CMZWStructWith(p, x, p.x - _menuInsets.right),
            p2 = CMZWStructWith(p, x, p.x + _menuInsets.left);

    NSUInteger index = NSUIntegerMax;
    UIView *item = nil;
    for (NSUInteger i = 0; i < _items.count; ++i) {
        item = _items[i];
        if (CGRectContainsPoint(item.frame, p) || CGRectContainsPoint(item.frame, p1) ||
            CGRectContainsPoint(item.frame, p2)) {
            index = i;
            break;
        }
    }

    return index;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;

        _menuInsets = UIEdgeInsetsMake(.0, 12.0, .0, 15.0);
    }

    return self;
}

- (void)layoutItems {
    CGFloat w = .0, x = .0, gap = _menuInsets.right + _menuInsets.left,
            minW = CGRectGetWidth(self.frame) - self.contentInset.left - self.contentInset.right;
    for (UIView *v in _items) {
        w += CGRectGetWidth(v.frame) + gap;
    }

    if (w < minW) {
//        x = (CGRectGetWidth(self.frame) - w) / 2.0 + _menuInsets.left;
        x = _menuInsets.left;
        w = minW;
    } else {
        x = _menuInsets.left;
    }

    for (UIView *v in _items) {
        v.center = CGPointMake(x + CGRectGetWidth(v.frame) / 2.0, CGRectGetHeight(self.frame) / 2.0);
        
        [self addSubview:v];

        if ([_items indexOfObject:v] == _selectedIndex) {
            
            if ([v conformsToProtocol:@protocol(CMZWSMenuAppearance)]
                && [v respondsToSelector:@selector(transformToHighlight)]) {
                [(id<CMZWSMenuAppearance>)v transformToHighlight];
            }
            
            _indicatorView.center = v.center;
            _indicatorView.bounds = CGRectMake(.0, .0, CGRectGetWidth(v.frame), CGRectGetHeight(self.frame));
        } else {
            if ([v conformsToProtocol:@protocol(CMZWSMenuAppearance)]
                && [v respondsToSelector:@selector(transformToNormal)]) {
                [(id<CMZWSMenuAppearance>)v transformToNormal];
            }
        }

        x += CGRectGetWidth(v.frame) + gap;
    }

    self.contentSize = CGSizeMake(w, CGRectGetHeight(self.frame));
}

- (void)setItems:(NSArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    } else {
        [_items makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_items removeAllObjects];
    }

    [_items addObjectsFromArray:items];

    _selectedIndex = 0;
    
#pragma mark - 不超过4个充满一屏，不可滑动
    if ([items count] <= 4 && [items count] > 1) {
        CGFloat totalWei = 0;
        for (UIView *label in items) {
            totalWei += CGRectGetWidth(label.frame);
        }
        CGFloat screenWei = [UIScreen mainScreen].bounds.size.width;
        if (totalWei < screenWei) {
            //1个标题时特殊处理，两边相等
            NSInteger count = [items count];
            CGFloat margin = roundf((screenWei - totalWei) / count) - 1;
            _menuInsets.left = margin / 2;
            _menuInsets.right = margin / 2;
        }
    }

    [self layoutItems];
}

- (NSArray *)items {
    return [NSArray arrayWithArray:_items];
}

- (void)setIndicatorView:(UIView *)indicatorView {
    if (_indicatorView == indicatorView) {
        return;
    }

    if (_indicatorView) {
        [_indicatorView removeFromSuperview];
    }
    if (indicatorView) {
        UIView *v = _items[_selectedIndex];
        indicatorView.center = v.center;
        indicatorView.bounds = CGRectMake(.0, .0, CGRectGetWidth(v.frame), CGRectGetHeight(self.frame));

        [self insertSubview:indicatorView atIndex:0];
    }

    _indicatorView = indicatorView;
}

- (BOOL)indexIsValid:(NSInteger)index {
    return index >= 0 && index < _items.count;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex == selectedIndex) {
        return;
    }
    
    NSAssert([self indexIsValid:selectedIndex], @"");
    NSAssert([self indexIsValid:_selectedIndex], @"");
    
    UIView *v = _items[selectedIndex];
    CGFloat offsetX = v.center.x - CGRectGetWidth(self.frame) / 2.0;

    if (offsetX < -self.contentInset.left) {
        offsetX = -self.contentInset.left;
    } else if (offsetX + CGRectGetWidth(self.frame) > self.contentSize.width + self.contentInset.right) {
        offsetX = self.contentSize.width + self.contentInset.right - CGRectGetWidth(self.frame);
    }

    self.contentOffset = CMZWStructWith(self.contentOffset, x, offsetX);

    _indicatorView.center = v.center;
    _indicatorView.bounds = CGRectMake(.0, .0, CGRectGetWidth(v.frame), CGRectGetHeight(self.frame));

    if ([_items[_selectedIndex] conformsToProtocol:@protocol(CMZWSMenuAppearance)]
        && [_items[_selectedIndex] respondsToSelector:@selector(transformToNormal)]) {
        [(id<CMZWSMenuAppearance>)_items[_selectedIndex] transformToNormal];
    }
    
    if ([v conformsToProtocol:@protocol(CMZWSMenuAppearance)]
        && [v respondsToSelector:@selector(transformToHighlight)]) {
        [(id<CMZWSMenuAppearance>)v transformToHighlight];
    }

    _selectedIndex = selectedIndex;
}
- (void)setMenuInsets:(UIEdgeInsets)menuInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(menuInsets, _menuInsets)) {
        return;
    }
    _menuInsets.left = menuInsets.left;
    _menuInsets.right = menuInsets.right;
    [self layoutItems];
}
- (void)moveToMenuAtIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    if (_selectedIndex == selectedIndex) {
        return;
    }

    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }

    [self setSelectedIndex:selectedIndex];

    if (animated) {
        [UIView commitAnimations];
    }
}

- (CGFloat)widthOfItem:(NSInteger)index {
    if (![self indexIsValid:index]) {
        return .0;
    }

    return CGRectGetWidth(((UIView *)_items[index]).frame);
}

- (CGFloat)centerOfItem:(NSInteger)index {
    if (!_items.count) {
        return .0;
    }

    if (index < 0) {
        return CGRectGetMinX(((UIView *)_items.firstObject).frame) - _menuInsets.left - _menuInsets.right;
    } else if (index >= _items.count) {
        return CGRectGetMaxX(((UIView *)_items.lastObject).frame) + _menuInsets.left + _menuInsets.right;
    }

    return ((UIView *)_items[index]).center.x;
}

- (CGRect)frameForIndicatorViewWithFloatIndex:(float)index {
    NSInteger ceil = ceilf(index), floor = ceil - 1;
    CGFloat w, wc, wf, left, middleX;

    wc = (index - floor) * [self widthOfItem:ceil];
    wf = (ceil - index) * [self widthOfItem:floor];

    w = wc + wf + 2.0 * (.5 - fabs(ceil - index - .5)) * (_menuInsets.left + _menuInsets.right);

    if (ceil - index >= .5) {
        middleX = [self centerOfItem:floor] +
                  2.0 * (index - floor) * ([self widthOfItem:floor] / 2.0 + _menuInsets.right);
    } else {
        middleX = [self centerOfItem:ceil] -
                  2.0 * (ceil - index) * ([self widthOfItem:ceil] / 2.0 + _menuInsets.left);
    }

    left = middleX - w / 2.0;

    CGRect r = CGRectMake(left, .0, w, CGRectGetHeight(self.frame));

    return r;
}

- (void)moveToMenuAtFloatIndex:(float)floatIndex animated:(BOOL)animated {
    __SetIfLessThan(floatIndex, -.999);
    __SetIfMoreThan(floatIndex, (_items.count - 1.0) + .999);

    float offset = floatIndex - _selectedIndex;

    while (offset >= 1.0) {
        [self moveToMenuAtIndex:_selectedIndex + 1 animated:animated];
        offset -= 1.0;
    }

    while (offset <= -1.0) {
        [self moveToMenuAtIndex:_selectedIndex - 1 animated:animated];
        offset += 1.0;
    }

    if (offset == .0) {
        return;
    }

    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    }

    NSInteger nextIndex = offset >= .0 ? _selectedIndex + 1 : _selectedIndex - 1;

    UIView *currItem = _items[_selectedIndex],
           *nextItem = [self indexIsValid:nextIndex] ? _items[nextIndex] : nil;

    CGRect f = [self frameForIndicatorViewWithFloatIndex:floatIndex];
    _indicatorView.frame = f;

    if ([currItem conformsToProtocol:@protocol(CMZWSMenuAppearance)]
        && [currItem respondsToSelector:@selector(transformPercent:)]) {
        [(id<CMZWSMenuAppearance>)currItem transformPercent:1 - fabsf(offset)];
    }
    
    if ([nextItem conformsToProtocol:@protocol(CMZWSMenuAppearance)]
        && [nextItem respondsToSelector:@selector(transformPercent:)]) {
        [(id<CMZWSMenuAppearance>)nextItem transformPercent:fabsf(offset)];
    }

    CGFloat offsetX = CGRectGetMidX(f) - CGRectGetWidth(self.frame) / 2;
    if (offsetX < -self.contentInset.left) {
        offsetX = -self.contentInset.left;
    } else if (offsetX + CGRectGetWidth(self.frame) > self.contentSize.width + self.contentInset.right) {
        offsetX = self.contentSize.width + self.contentInset.right - CGRectGetWidth(self.frame);
    }

    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }

    self.contentOffset = CMZWStructWith(self.contentOffset, x, offsetX);

    if (animated) {
        [UIView commitAnimations];

        [UIView commitAnimations];
    }
}

@end
