//
//  UINavigationBar+TintSettings.m
//  Screen
//
//  Created by Eric Galluzzo on 2/3/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import "UINavigationBar+TintSettings.h"

@implementation UINavigationBar (TintSettings)

- (UIColor *)crossPlatformTintColor
{
    if([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]){
        return self.barTintColor;
    } else {
        return self.tintColor;
    }
}

- (void)setCrossPlatformTintColor:(UIColor *)color
{
    // See http://stackoverflow.com/questions/18177010/how-to-change-navigation-bar-color-in-ios-7-or-6
    if([UINavigationBar instancesRespondToSelector:@selector(barTintColor)]){
        //self.barStyle = UIBarStyleBlack;
        self.barTintColor = color;
    } else {
        self.opaque = YES;
        self.tintColor = color;
    }
}

- (void)useScreenAppTintColor
{
    self.crossPlatformTintColor =
        [UIColor colorWithRed:(203.0/255.0) green:(238.0/255.0) blue:(255.0/255.0) alpha:1];
}

@end
