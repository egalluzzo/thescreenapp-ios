//
//  CandidateDetailViewController.h
//  Screen
//
//  Created by Eric Galluzzo on 1/28/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Candidate.h"
#import "StarRatingView.h"

@interface CandidateDetailViewController : UIViewController <UISplitViewControllerDelegate, StarRatingViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) Candidate *candidate;

@end
