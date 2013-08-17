//
//  StarRatingView.h
//  StarRatingDemo
//
//  Created by HengHong on 5/4/13.
//  Copyright (c) 2013 Fixel Labs Pte. Ltd. All rights reserved.
//  https://github.com/henghonglee/StarRatingView
//


#import <UIKit/UIKit.h>

@class StarRatingView;

@protocol StarRatingViewDelegate <NSObject>
@optional
- (void) starRatingViewDidChangeRating:(StarRatingView *)starRatingView withRating:(int)rating;
@end

@interface StarRatingView : UIView

@property (nonatomic, weak) IBOutlet id <StarRatingViewDelegate> delegate;
@property (nonatomic) int rating;
@property (nonatomic) int userRating;
@property (nonatomic) BOOL animated;

- (id)initWithFrame:(CGRect)frame andRating:(int)rating withLabel:(BOOL)label animated:(BOOL)animated;
@end
