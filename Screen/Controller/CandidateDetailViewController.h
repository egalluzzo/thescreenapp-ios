//
//  CandidateDetailViewController.h
//  Screen
//
//  Created by Eric Galluzzo on 8/14/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Candidate.h"
#import "StarRatingView.h"

@interface CandidateDetailViewController : UITableViewController <UITextFieldDelegate, StarRatingViewDelegate>

@property(nonatomic, strong) Candidate *candidate;

@property(nonatomic, weak) IBOutlet UITextField *nameField;
@property(nonatomic, weak) IBOutlet UITextField *phoneField;
@property(nonatomic, weak) IBOutlet StarRatingView *ratingField;
@property(nonatomic, weak) IBOutlet UIButton *addInterviewButton;

- (void)saveCandidate;

@end
