//
//  ConductInterviewViewController.m
//  Screen
//
//  Created by Eric Galluzzo on 2/7/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import "ConductInterviewViewController.h"

#import "QuestionNotesTableViewCell.h"

@interface ConductInterviewViewController ()

@property (nonatomic, strong) IBOutlet UILabel *candidateNameLabel;
@property (nonatomic, strong) IBOutlet UIButton *addQuestionButton;
@property (nonatomic, strong) IBOutlet UIButton *editQuestionsButton;
@property (nonatomic, strong) IBOutlet UIButton *finishInterviewButton;

@end


@implementation ConductInterviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
