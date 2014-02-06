//
//  Interview.h
//  Screen
//
//  Created by Eric Galluzzo on 8/17/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Candidate, Question;

@interface Interview : NSManagedObject

@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSDate *interviewDate;
@property (nonatomic, retain) NSNumber *durationInMinutes;
@property (nonatomic, retain) NSString *eventIdentifier;
@property (nonatomic, retain) Candidate *candidate;
@property (nonatomic, retain) NSSet *questions;

@property (nonatomic, readonly) NSArray *sortedQuestions;

@end

@interface Interview (CoreDataGeneratedAccessors)

- (void)addQuestionsObject:(Question *)value;
- (void)removeQuestionsObject:(Question *)value;
- (void)addQuestions:(NSSet *)values;
- (void)removeQuestions:(NSSet *)values;

@end
