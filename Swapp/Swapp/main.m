//
//  main.m
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

// Remote Plugin patch start //

#ifdef DEBUG
#define REMOTEPLUGIN_SERVERIPS "192.168.1.108"
#include "/Users/npu3paka/Library/Application Support/Developer/Shared/Xcode/Plug-ins/Remote.xcplugin/Contents/Resources/RemoteCapture.h"
#endif

// Remote Plugin patch end //
