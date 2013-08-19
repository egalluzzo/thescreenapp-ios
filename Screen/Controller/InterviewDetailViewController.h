//
//  InterviewDetailViewController.h
//  Screen
//
//  Created by Hitanshu Pande on 8/18/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Candidate.h"
#import "Interview.h"
#import "Question.h"


@interface InterviewDetailViewController : UITableViewController<UITextFieldDelegate>

//@property(nonatomic, strong) Candidate *candidate;
@property(nonatomic, strong) Interview *interview;
//@property(nonatomic, strong) Question *question;

@property(nonatomic, weak) IBOutlet UITextField *date;
//@property(nonatomic, weak) IBOutlet UITextField *location;
@property(nonatomic, weak) IBOutlet UIButton *addInterviewButton;
@property(nonatomic, weak) IBOutlet UIButton *conductInterviewButton;

-(void)saveInterview;

@end
