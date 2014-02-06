//
//  Interview.m
//  Screen
//
//  Created by Eric Galluzzo on 8/17/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import "Interview.h"
#import "Candidate.h"
#import "Question.h"


@interface Interview ()

- (void)normalizeQuestionSortOrders;

@end


@implementation Interview

@dynamic creationDate;
@dynamic uuid;
@dynamic location;
@dynamic interviewDate;
@dynamic durationInMinutes;
@dynamic eventIdentifier;
@dynamic candidate;
@dynamic questions;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.creationDate = [NSDate date];
    self.location = @"";
    self.interviewDate = self.creationDate;
    // Create a new UUID.
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    // Convert to a CFStringRef, then an NSString *.
    self.uuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    // When we fetch, we make sure that the questions are sorted appropriately.
    // We have to do this asynchronously because relationship tracking is turned
    // off during awakeFromFetch.  See:
    // https://developer.apple.com/library/mac/documentation/cocoa/Conceptual/CoreData/Articles/cdManagedObjects.html#//apple_ref/doc/uid/TP40003397-SW1
    
    [self performSelector:@selector(normalizeQuestionSortOrders) withObject:self afterDelay:0];
}

- (NSArray *)sortedQuestions
{
    return [self.questions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:NO]]];
}

- (void)normalizeQuestionSortOrders
{
    NSInteger sortOrder = 1;
    for (Question *question in self.sortedQuestions) {
        question.sortOrder = [NSNumber numberWithInteger:sortOrder++];
    }
}

@end
