//
//  InterviewDetailViewController.h
//  Screen
//
//  Created by Eric Galluzzo on 1/31/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Interview.h"
#import "QuestionTableViewDataSource.h"

@interface InterviewDetailViewController : UIViewController <UISplitViewControllerDelegate, UITextFieldDelegate, UITableViewDelegate, QuestionTableViewDataSourceCellProvider>

@property(nonatomic, strong) Interview *interview;

-(void)saveInterview;
-(void)conductInterview;

@end
