//
//  StarRatingView.m
//  StarRatingDemo
//
//  Created by HengHong on 5/4/13.
//  Copyright (c) 2013 Fixel Labs Pte. Ltd. All rights reserved.
//  https://github.com/henghonglee/StarRatingView
//

#import "StarRatingView.h"

#define kLeftPadding 0.0f

@interface StarRatingView ()
@property (nonatomic) int maxrating;
@property (nonatomic) float kLabelAllowance;
@property (nonatomic,strong) NSTimer* timer;
@property (nonatomic,strong) UILabel* label;
@end

@implementation StarRatingView

@synthesize delegate;
@synthesize timer;
@synthesize kLabelAllowance;

- (void)setRating:(int)rating
{
    _rating = rating;
    [self setNeedsDisplay];
}

- (void)setUserRating:(int)userRating
{
    _userRating = userRating;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame andRating:(int)rating withLabel:(BOOL)label animated:(BOOL)animated
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor orangeColor];
        _maxrating = rating;
        //*(self.bounds.size.width-frame.size.height-kLabelAllowance);
        self.animated = animated;
        if (self.animated) {
            _rating = 0;
            timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(increaseRating) userInfo:nil repeats:YES];
        }else{
            _rating = _maxrating;
            NSLog(@"setting rating");
        }
        if (label) {
            self.kLabelAllowance = 30.0f;
            self.label = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width-kLabelAllowance , 0,kLabelAllowance, frame.size.height)];
            self.label.font = [UIFont systemFontOfSize:11.0f];
            self.label.text = [NSString stringWithFormat:@"%d%%",rating];
            self.label.textAlignment = NSTextAlignmentRight;
            self.label.textColor = [UIColor whiteColor];
            self.label.backgroundColor = [UIColor clearColor];
            [self addSubview:self.label];
        }else{
            self.kLabelAllowance = 0.0f;
        }
        
    }
    return self;
}


-(void)increaseRating
{
    
    if (_rating<_maxrating) {
        _rating = _rating + 1;
        if (self.label) {
            self.label.text = [NSString stringWithFormat:@"%d%%",self.rating];
        }
        [self setNeedsDisplay];
    }else{
        [timer invalidate];
    }
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIImage* image = [UIImage imageNamed:@"5starsgray.png"];
    CGRect newrect = CGRectMake(kLeftPadding, 0, self.bounds.size.width-kLabelAllowance-kLeftPadding, self.bounds.size.height);
    [image drawInRect:newrect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, newrect, [UIImage imageNamed:@"5starflip.png"].CGImage);
    float barWitdhPercentage = (_rating/100.0f) *  (self.bounds.size.width-kLabelAllowance-kLeftPadding);
    
    CGContextClipToRect(context, CGRectMake(kLeftPadding, 0, MIN(self.bounds.size.width,barWitdhPercentage), self.bounds.size.height));
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    if (self.userRating < 0.2f) {
        [[UIColor yellowColor] setFill];
    }else{
        [[UIColor greenColor] setFill];
    }
    CGContextFillRect(context, newrect);
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (CGRectContainsPoint(self.bounds, [[[touches allObjects]lastObject] locationInView:self])) {
        
        float xpos = [[[touches allObjects]lastObject] locationInView:self].x - kLeftPadding;
        if (xpos < kLeftPadding) {
            if (self.userRating == 20.0f) {
                self.userRating = 0.0f;
                if (self.animated) {
                    self.rating = 0;
                    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(increaseRating) userInfo:nil repeats:YES];
                }else{
                    self.rating = self.maxrating;
                    if (self.label) {
                        self.label.text = [NSString stringWithFormat:@"%d%%",self.rating];
                    }
                }
            }
        }else{
            float star = MIN(5.0,xpos/((self.bounds.size.width-kLabelAllowance-kLeftPadding)/5.0f));
            // Round to the nearest half star.
            star = roundf(star * 2.0f) / 2.0f;
            self.userRating = star * 20.0f;
            self.rating = self.userRating;
            if (self.label) {
                self.label.text = [NSString stringWithFormat:@"%d%%",self.rating];
            }
        }
        [self setNeedsDisplay];
        
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (CGRectContainsPoint(self.bounds, [[[touches allObjects]lastObject] locationInView:self])) {
        
        float xpos = [[[touches allObjects]lastObject] locationInView:self].x - kLeftPadding;
        float star = MIN(5.0,xpos/((self.bounds.size.width-kLabelAllowance-kLeftPadding)/5.0f));
        // Round to the nearest half star.
        star = roundf(star * 2.0f) / 2.0f;
        self.userRating = star * 20.0f;
        self.rating = self.userRating;
        
        if (self.label) {
            self.label.text = [NSString stringWithFormat:@"%d%%",self.rating];
        }
        
        if (delegate != nil && [delegate respondsToSelector:@selector(starRatingViewDidChangeRating:withRating:)]) {
            [[self delegate] starRatingViewDidChangeRating:self withRating:self.rating];
        }
        
        [self setNeedsDisplay];
    }
}


@end