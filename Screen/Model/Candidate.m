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
    return [NSString stringWithFormat:@"%@, %@", self.lastName, self.firstName];
}

@end
