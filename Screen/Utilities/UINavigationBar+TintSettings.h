//
//  UINavigationBar+TintSettings.h
//  Screen
//
//  Created by Eric Galluzzo on 2/3/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (TintSettings)

@property(nonatomic) UIColor *crossPlatformTintColor;

- (void)useScreenAppTintColor;

@end
