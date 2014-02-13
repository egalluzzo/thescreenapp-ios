//
//  Candidate.m
//  Screen
//
//  Created by Eric Galluzzo on 7/20/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import "Candidate.h"


@implementation Candidate

@dynamic firstName;
@dynamic lastName;
@dynamic phone;
@dynamic email;
@dynamic rating;
@dynamic interviews;

- (NSString *)fullName
{
    if (self.lastName == nil) {
        if (self.firstName == nil) {
            return @"";
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
