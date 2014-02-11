//
//  ConductInterviewViewController.h
//  Screen
//
//  Created by Eric Galluzzo on 2/7/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QuestionTableViewDataSource.h"

@interface ConductInterviewViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate,UITableViewDelegate, QuestionTableViewDataSourceCellProvider>

@property (nonatomic, strong) Interview *interview;

@end
