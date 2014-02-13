//
//  ScreenModelObject.m
//  Screen
//
//  Created by Eric Galluzzo on 2/13/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import "ScreenModelObject.h"

@implementation ScreenModelObject

@dynamic uuid, creationDate, updateDate, deleted;

// Automatically set the creation date and UUID when the object is first saved.
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.creationDate = [NSDate date];
    
    // Create a new UUID.
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    // Convert to a CFStringRef, then an NSString *.
    self.uuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
}

// Automatically set the update date when the object is saved.  This is preferable to using
// willSave: since the latter tracks property changes and so could loop infinitely if we
// set the updateDate property to something slightly different each time.
// See http://stackoverflow.com/questions/4874193/core-data-willsave-method
+ (void) load {
    [super load];
    @autoreleasepool {
        [[NSNotificationCenter defaultCenter] addObserver: (id)[self class]
                                                 selector: @selector(objectContextWillSave:)
                                                     name: NSManagedObjectContextWillSaveNotification
                                                   object: nil];
    }
}

+ (void) objectContextWillSave: (NSNotification *) notification {
    NSManagedObjectContext *context = [notification object];
    NSSet *allModified = [context.insertedObjects setByAddingObjectsFromSet: context.updatedObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"self isKindOfClass: %@", [self class]];
    NSSet *modifiable = [allModified filteredSetUsingPredicate: predicate];
    [modifiable makeObjectsPerformSelector: @selector(setUpdateDate:) withObject: [NSDate date]];
}

@end
