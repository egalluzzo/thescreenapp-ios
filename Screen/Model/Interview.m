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


@implementation Interview

@dynamic creationDate;
@dynamic uuid;
@dynamic location;
@dynamic interviewDate;
@dynamic candidate;
@dynamic questions;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.creationDate = [NSDate date];
    self.location = @"glendale";
    self.interviewDate = self.creationDate;
    self.candidate = @"hitanshu";
    self.questions = @"1.test?";
    // Create a new UUID.
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    // Convert to a CFStringRef, then an NSString *.
    self.uuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
}

@end
