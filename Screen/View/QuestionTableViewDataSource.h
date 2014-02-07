//
//  QuestionTableViewDataSource.h
//  Screen
//
//  Created by Eric Galluzzo on 2/7/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Interview.h"
#import "Question.h"


@protocol QuestionTableViewDataSourceCellProvider <NSObject>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForQuestion:(Question *)question;

@end


@interface QuestionTableViewDataSource : NSObject <UITableViewDataSource>

// Note: This is a weak reference, since it is typically going to be implemented by
//       the controller that is referencing the data source (just like a delegate).
//       If it were a strong reference, it would cause a reference cycle.  This is
//       why most modern languages use garbage collection....
@property (nonatomic, weak) id <QuestionTableViewDataSourceCellProvider> cellProvider;
@property (nonatomic, strong) Interview *interview;

- (QuestionTableViewDataSource *)initWithCellProvider:(id <QuestionTableViewDataSourceCellProvider>) cellProvider;

- (Question *)addQuestion:(UITableView *)tableView;
- (void)reloadQuestions:(UITableView *)tableView;
- (Question *)questionAtIndexPath:(NSIndexPath *)indexPath;

@end
