//
//  QuestionTableViewDataSource.m
//  Screen
//
//  Created by Eric Galluzzo on 2/7/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import "QuestionTableViewDataSource.h"


@interface QuestionTableViewDataSource()

@property(nonatomic, strong) NSArray *sortedQuestions;

- (void)saveInterview;

@end


@implementation QuestionTableViewDataSource

- (QuestionTableViewDataSource *)initWithCellProvider:(id <QuestionTableViewDataSourceCellProvider>) cellProvider
{
    self = [super init];
    if (self) {
        self.cellProvider = cellProvider;
    }
    return self;
}

- (void)setInterview:(Interview *)interview
{
    if (_interview != interview) {
        self.sortedQuestions = interview.sortedQuestions;
        _interview = interview;
    }
}

- (void)saveInterview
{
    NSError *error;
    if ([self.interview.managedObjectContext hasChanges] && ![self.interview.managedObjectContext save:&error]) {
        // FIXME: Need a better error handling mechanism...
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (Question *)addQuestion:(UITableView *)tableView
{
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question"
                                                       inManagedObjectContext:self.interview.managedObjectContext];
    question.interview = self.interview;
    question.sortOrder = [NSNumber numberWithInteger:[((Question *)self.sortedQuestions.lastObject).sortOrder integerValue] + 1];
    [self.interview addQuestionsObject:question];
    [self saveInterview];
    
    self.sortedQuestions = self.interview.sortedQuestions;
    
    NSInteger row = [self.sortedQuestions indexOfObject:question];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    return question;
}

- (void)reloadQuestions:(UITableView *)tableView
{
    self.sortedQuestions = self.interview.sortedQuestions;
    [tableView reloadData];
}

- (Question *)questionAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.sortedQuestions objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // If we have no interview, there are no sections.
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
    Question *question = [self.sortedQuestions objectAtIndex:indexPath.row];
    return [self.cellProvider tableView:tableView cellForQuestion:question];
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
            [self.interview.managedObjectContext deleteObject:question];
            [self saveInterview];
            self.sortedQuestions = self.interview.sortedQuestions;
            
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            NSLog(@"Unable to handle editing style %d in question table", editingStyle);
            break;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // Swap the sort orders of the "from" and "to" questions.
    Question *fromQuestion = [self.sortedQuestions objectAtIndex:fromIndexPath.row];
    Question *toQuestion = [self.sortedQuestions objectAtIndex:toIndexPath.row];
    NSNumber *oldFromSortOrder = fromQuestion.sortOrder;
    fromQuestion.sortOrder = toQuestion.sortOrder;
    toQuestion.sortOrder = oldFromSortOrder;
    [self saveInterview];
    
    self.sortedQuestions = self.interview.sortedQuestions;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
