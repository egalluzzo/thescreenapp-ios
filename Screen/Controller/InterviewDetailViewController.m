//
//  InterviewDetailViewController.m
//  Screen
//
//  Created by Eric Galluzzo on 1/31/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import <EventKit/EventKit.h>

#import "InterviewDetailViewController.h"

#import "Candidate.h"
#import "Question.h"
#import "TextFieldTableViewCell.h"
#import "UINavigationBar+TintSettings.h"


@interface InterviewDetailViewController ()

@property (nonatomic, weak) IBOutlet UILabel *candidateNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *interviewDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *startTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *endTimeLabel;
@property (nonatomic, weak) IBOutlet UITextField *locationField;
@property (nonatomic, weak) IBOutlet UIButton *addToCalendarButton;

@property (nonatomic, weak) IBOutlet UIButton *addQuestionButton;
@property (nonatomic, weak) IBOutlet UIButton *editQuestionsButton;
@property (nonatomic, weak) IBOutlet UITableView *questionTable;

@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIPopoverController *datePopoverController;
@property (nonatomic, strong) NSArray *sortedQuestions;

- (void)configureView;
- (void)configureQuestionCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)addToCalendar;
- (void)addQuestion;
- (void)editQuestions;

- (void)showAlertWithTitle:title message:message;

- (void)showInterviewDatePicker;
- (void)showStartTimePicker;
- (void)showEndTimePicker;
- (void)showDatePickerWithDate:(NSDate *)date mode:(UIDatePickerMode)mode action:(SEL)action fromView:(UIView *)view;
- (void)getInterviewDateFromPicker:(id)sender;
- (void)getEndTimeFromPicker:(id)sender;

- (void)saveInterviewWithoutSavingToCalendar;

@end


@implementation InterviewDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar useScreenAppTintColor];
    
    [self.addToCalendarButton addTarget:self
                                 action:@selector(addToCalendar)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [self.addQuestionButton addTarget:self
                               action:@selector(addQuestion)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.editQuestionsButton addTarget:self
                                 action:@selector(editQuestions)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [self.locationField addTarget:self
                           action:@selector(saveInterview)
                 forControlEvents:UIControlEventEditingChanged];
    
    // Pop up the date picker when tapping the interview date.
    UITapGestureRecognizer *interviewDateTapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInterviewDatePicker)];
    [self.interviewDateLabel addGestureRecognizer:interviewDateTapGestureRecognizer];
    
    // Pop up the time picker when tapping the start time.
    UITapGestureRecognizer *startTimeTapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showStartTimePicker)];
    [self.startTimeLabel addGestureRecognizer:startTimeTapGestureRecognizer];
    
    // Pop up the time picker when tapping the end time.
    UITapGestureRecognizer *endTimeTapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEndTimePicker)];
    [self.endTimeLabel addGestureRecognizer:endTimeTapGestureRecognizer];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setInterview:(Interview *)interview
{
    if (_interview != interview) {
        _interview = interview;
        [self configureView];
        [self.questionTable reloadData];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)saveInterviewWithoutSavingToCalendar
{
    if (self.interview != nil) {
        self.interview.location = self.locationField.text;
        
        NSError *error;
        if ([self.interview.managedObjectContext hasChanges] && ![self.interview.managedObjectContext save:&error]) {
            // FIXME: Need a better error handling mechanism...
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)saveInterview
{
    [self saveInterviewWithoutSavingToCalendar];
    if (self.interview.eventIdentifier != nil) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKEvent *event = [eventStore eventWithIdentifier:self.interview.eventIdentifier];
        if (event != nil) {
            [self saveEvent:event withEventStore:eventStore];
        }
    }
}

- (void)configureView
{
    if (self.interview != nil) {
        self.candidateNameLabel.text = self.interview.candidate.fullName;
        self.locationField.text = self.interview.location;
        [self reloadDateLabel];
        
        // Reload the interviews in case they have changed.
        self.sortedQuestions = self.interview.sortedQuestions;
        [self.questionTable reloadData];
    }
}

- (void)addToCalendar
{
    // See http://stackoverflow.com/questions/13082678/add-event-to-calendar-in-xcode-ios
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // the selector is available, so we must be on iOS 6 or newer
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    [self showAlertWithTitle:@"Interview Not Added" message:@"Could not add the event to your calendar."];
                }
                else if (!granted)
                {
                    [self showAlertWithTitle:@"Interview Not Added" message:@"Access to your calendar was denied."];
                }
                else
                {
                    // access granted
                    [self addEventToCalendarAfterAccessGranted];
                }
            });
        }];
    }
    else
    {
        // This code runs in iOS 4 or iOS 5
        [self addEventToCalendarAfterAccessGranted];
    }
}

- (void)addEventToCalendarAfterAccessGranted
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    [self saveEvent:event withEventStore:eventStore];
    
    self.interview.eventIdentifier = event.eventIdentifier;
    [self saveInterviewWithoutSavingToCalendar];
    
    [self showAlertWithTitle:@"Interview Added" message:@"The interview has been added to your calendar."];
}

- (void)saveEvent:(EKEvent *)event withEventStore:(EKEventStore *)eventStore
{
    event.title = [NSString stringWithFormat:@"Interview for %@", self.interview.candidate.fullName];
    
    event.startDate = self.interview.interviewDate;
    event.endDate = [self.interview.interviewDate dateByAddingTimeInterval:[self.interview.durationInMinutes intValue] * 60.0];
    event.location = self.interview.location;
    
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    NSError *error;
    if (![eventStore saveEvent:event span:EKSpanThisEvent error:&error]) {
        // FIXME: Need a better error handling mechanism...
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)showAlertWithTitle:title message:message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil];
    [alert show];
}

- (void)addQuestion
{
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question"
                                                       inManagedObjectContext:self.interview.managedObjectContext];
    question.interview = self.interview;
    [self.interview addQuestionsObject:question];
    [self saveInterview];
    
    self.sortedQuestions = self.interview.sortedQuestions;
    
    NSInteger row = [self.sortedQuestions indexOfObject:question];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.questionTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)editQuestions
{
    // Doesn't work yet
    //    self.editing = !self.editing;
    //    [self.editQuestionsButton setTitle:(self.editing ? @"Done" : @"Edit")
    //                              forState:UIControlStateNormal | UIControlStateSelected | UIControlStateHighlighted | UIControlStateDisabled];
}

- (void)reloadDateLabel
{
    // A date formatter for the time stamp.
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    
    static NSDateFormatter *timeFormatter = nil;
    if (timeFormatter == nil) {
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
        [timeFormatter setDateStyle:NSDateFormatterNoStyle];
    }
    
    NSDate *endDate = [self.interview.interviewDate dateByAddingTimeInterval:[self.interview.durationInMinutes intValue] * 60.0];
    self.interviewDateLabel.text = [dateFormatter stringFromDate:self.interview.interviewDate];
    self.startTimeLabel.text = [timeFormatter stringFromDate:self.interview.interviewDate];
    self.endTimeLabel.text = [timeFormatter stringFromDate:endDate];
}

- (void)showInterviewDatePicker
{
    [self showDatePickerWithDate:self.interview.interviewDate
                            mode:UIDatePickerModeDate
                          action:@selector(getInterviewDateFromPicker:)
                        fromView:self.interviewDateLabel];
}

- (void)getInterviewDateFromPicker:(id)sender
{
    UIDatePicker *picker = (UIDatePicker *)sender;
    self.interview.interviewDate = picker.date;
    [self reloadDateLabel];
    [self saveInterview];
}

- (void)showStartTimePicker
{
    [self showDatePickerWithDate:self.interview.interviewDate
                            mode:UIDatePickerModeTime
                          action:@selector(getInterviewDateFromPicker:)
                        fromView:self.startTimeLabel];
}

- (void)showEndTimePicker
{
    NSDate *endDate = [self.interview.interviewDate dateByAddingTimeInterval:[self.interview.durationInMinutes intValue] * 60.0];
    [self showDatePickerWithDate:endDate
                            mode:UIDatePickerModeTime
                          action:@selector(getEndTimeFromPicker:)
                        fromView:self.endTimeLabel];
}

- (void)getEndTimeFromPicker:(id)sender
{
    UIDatePicker *picker = (UIDatePicker *)sender;
    // FIXME: This will probably return a negative number if the interview spans
    //        a date boundary, although I think that should be rare.
    self.interview.durationInMinutes = [NSNumber numberWithInteger:(NSInteger)([picker.date timeIntervalSinceDate:self.interview.interviewDate] / 60.0)];
    [self reloadDateLabel];
    [self saveInterview];
}

- (void)showDatePickerWithDate:(NSDate *)date mode:(UIDatePickerMode)mode action:(SEL)action fromView:(UIView *)view
{
    // Code adapted from http://stackoverflow.com/questions/7341835/uidatepicker-in-uipopover?rq=1
    UIViewController* popoverContent = [[UIViewController alloc] init]; //ViewController
    
    UIView *popoverView = [[UIView alloc] init];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.date = date;
    datePicker.datePickerMode = mode;
    [datePicker setMinuteInterval:5];
    [datePicker addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [popoverView addSubview:datePicker];
    
    popoverContent.view = popoverView;
    self.datePopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    //popoverController.delegate=self;
    
    [self.datePopoverController setPopoverContentSize:datePicker.frame.size animated:NO];
    [self.datePopoverController presentPopoverFromRect:view.frame
                                                inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionAny
                                              animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // If we have no candidate, there are no sections.
    if (self.interview == nil) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.interview) {
        return self.sortedQuestions.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldTableViewCell"];
    if (cell == nil) {
        // Find the table cell out of the NIB.
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TextFieldTableViewCell" owner:nil options:nil];
        for (UIView *view in views) {
            if([view isKindOfClass:[UITableViewCell class]]) {
                cell = (TextFieldTableViewCell *)view;
            }
        }
        cell.textField.placeholder = @"Question";
        cell.textField.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [self configureQuestionCell:cell cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureQuestionCell:(TextFieldTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Question *question = [self.sortedQuestions objectAtIndex:indexPath.row];
    cell.textField.text = question.question;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Question *question = nil;
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            question = [self.sortedQuestions objectAtIndex:indexPath.row];
            [self.interview removeQuestionsObject:question];
            [self saveInterview];
            [self.questionTable deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Interviews", @"Interviews");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Text field delegate

// See http://stackoverflow.com/questions/4375442/accessing-uitextfield-in-a-custom-uitableviewcell
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    // this should return you your current indexPath
    NSIndexPath *indexPath = [self indexPathForQuestionTextField:textField];
    Question *question = [self.sortedQuestions objectAtIndex:indexPath.row];
    question.question = textField.text;
    
    NSError *error;
    if ([question.managedObjectContext hasChanges] && ![question.managedObjectContext save:&error]) {
        // FIXME: Need a better error handling mechanism...
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    NSIndexPath *cellIndexPath = [self indexPathForQuestionTextField:textField];
    [self.questionTable scrollToRowAtIndexPath:cellIndexPath
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
}

- (NSIndexPath *)indexPathForQuestionTextField:(UITextField *)textField
{
    UIView *view = [textField superview];
    while (view != nil && ![view isKindOfClass:[TextFieldTableViewCell class]]) {
        view = [view superview];
    }
    if (view == nil) {
        return nil;
    } else {
        return [self.questionTable indexPathForCell:(TextFieldTableViewCell *)view];
    }
}

@end
