//
//  ConductInterviewViewController.m
//  Screen
//
//  Created by Eric Galluzzo on 2/7/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import "ConductInterviewViewController.h"

#import "Candidate.h"
#import "QuestionNotesTableViewCell.h"

@interface ConductInterviewViewController ()

@property (nonatomic, weak) IBOutlet UILabel *candidateNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *addQuestionButton;
@property (nonatomic, weak) IBOutlet UIButton *editQuestionsButton;
@property (nonatomic, weak) IBOutlet UIButton *finishInterviewButton;

@property (nonatomic, weak) IBOutlet UITableView *questionTable;

@property (nonatomic, strong) QuestionTableViewDataSource *dataSource;

- (void)configureView;
- (void)finishInterview;

- (void)addQuestion;
- (void)editQuestions;

- (void)saveQuestion:(Question *)question;

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
    
    self.questionTable.dataSource = self.dataSource;
    self.questionTable.delegate = self;
    self.questionTable.rowHeight = 160;
    
    [self.addQuestionButton addTarget:self
                               action:@selector(addQuestion)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.editQuestionsButton addTarget:self
                                 action:@selector(editQuestions)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [self.finishInterviewButton addTarget:self
                                   action:@selector(finishInterview)
                         forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This doesn't seem to get initialized if I put it in init or initWithNibName.  If I put
// it in viewDidLoad, setInterview gets called before it.  So I lazy-load it instead.
- (QuestionTableViewDataSource *)dataSource
{
    if (_dataSource == nil) {
        self.dataSource = [[QuestionTableViewDataSource alloc] initWithCellProvider:self];
    }
    return _dataSource;
}

- (void)setInterview:(Interview *)interview
{
    if (_interview != interview) {
        _interview = interview;
        self.dataSource.interview = interview;
        [self configureView];
    }
}

- (void)configureView
{
    self.candidateNameLabel.text = self.interview.candidate.fullName;
    [self.questionTable reloadData];
}

- (void)finishInterview
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        self.interview = nil;
    }];
}

- (void)addQuestion
{
    [self.dataSource addQuestion:self.questionTable];
}

- (void)editQuestions
{
    //    [self.editQuestionsButton setTitle:(self.questionTable.editing ? @"Edit Questions" : @"Done Editing")
    //                              forState:UIControlStateNormal | UIControlStateSelected | UIControlStateHighlighted | UIControlStateDisabled];
    [self.questionTable setEditing:!self.questionTable.editing animated:YES];
}

- (void)saveQuestion:(Question *)question
{
    NSError *error;
    if ([question.managedObjectContext hasChanges] && ![question.managedObjectContext save:&error]) {
        // FIXME: Need a better error handling mechanism...
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table view data source cell provider

- (UITableViewCell *)tableView:(UITableView *)tableView cellForQuestion:(Question *)question
{
    QuestionNotesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionNotesTableViewCell"];
    if (cell == nil) {
        // Find the table cell out of the NIB.
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"QuestionNotesTableViewCell" owner:nil options:nil];
        for (UIView *view in views) {
            if([view isKindOfClass:[UITableViewCell class]]) {
                cell = (QuestionNotesTableViewCell *)view;
            }
        }
        cell.questionField.delegate = self;
        cell.notesField.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.questionField.text = question.question;
    cell.notesField.text = question.notes;
    return cell;
}

#pragma mark - Text field delegate

// FIXME: A lot of this is copied from InterviewDetailViewController.  We should consolidate it.
// The trouble is that it uses private variables like questionTable -- this isn't a
// UITableViewController.  Perhaps it could be a special UIViewController subclass or something.

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    NSIndexPath *cellIndexPath = [self indexPathForCellSubview:textField];
    [self.questionTable scrollToRowAtIndexPath:cellIndexPath
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:YES];
}

// See http://stackoverflow.com/questions/4375442/accessing-uitextfield-in-a-custom-uitableviewcell
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self indexPathForCellSubview:textField];
    Question *question = [self.dataSource questionAtIndexPath:indexPath];
    question.question = textField.text;
    [self saveQuestion:question];
}

- (NSIndexPath *)indexPathForCellSubview:(UIView *)subview
{
    UIView *view = subview;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    if (view == nil) {
        return nil;
    } else {
        return [self.questionTable indexPathForCell:(UITableViewCell *)view];
    }
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSIndexPath *cellIndexPath = [self indexPathForCellSubview:textView];
    [self.questionTable scrollToRowAtIndexPath:cellIndexPath
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSIndexPath *indexPath = [self indexPathForCellSubview:textView];
    Question *question = [self.dataSource questionAtIndexPath:indexPath];
    question.notes = textView.text;
    [self saveQuestion:question];
}

@end
