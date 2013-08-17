//
//  Candidate.m
//  Screen
//
//  Created by Eric Galluzzo on 7/20/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import "Candidate.h"


@implementation Candidate

@dynamic creationDate;
@dynamic firstName;
@dynamic lastName;
@dynamic rating;
@dynamic uuid;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.creationDate = [NSDate date];
    
    // Create a new UUID.
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    // Convert to a CFStringRef, then an NSString *.
    self.uuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
}

- (NSString *)fullName
{
    if (self.lastName == nil) {
        if (self.firstName == nil) {
            return @"(no name)";
        } else {
            return self.firstName;
        }
    } else {
        if (self.firstName == nil) {
            return self.lastName;
        } else {
            return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
        }
    }
}

@end
