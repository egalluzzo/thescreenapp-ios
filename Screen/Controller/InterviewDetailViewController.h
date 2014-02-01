//
//  InterviewDetailViewController.h
//  Screen
//
//  Created by Eric Galluzzo on 1/31/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Interview.h"

@interface InterviewDetailViewController : UIViewController <UISplitViewControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) Interview *interview;

-(void)saveInterview;

@end
