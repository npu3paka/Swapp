//
//  AppDelegate.m
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "AppDelegate.h"
#import "OnboardingViewController.h"
#import "OnboardingContentViewController.h"
#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate () <CrashlyticsDelegate>

@end

static NSString * const kUserHasOnboardedKey = @"user_has_onboarded";

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FBSDKLoginButton class];
    CrashlyticsKit.delegate = self;
    [Fabric with:@[[Crashlytics class]]];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // determine if the user has onboarded yet or not
    BOOL userHasOnboarded = [[NSUserDefaults standardUserDefaults] boolForKey:kUserHasOnboardedKey];
    
    // if the user has already onboarded, just set up the normal root view controller
    // for the application
    if (userHasOnboarded) {
        [self setupNormalRootViewController];
    }
    
    // otherwise set the root view controller to the onboarding view controller
    else {
        self.window.rootViewController = [self generateFirstDemoVC];
    }
    
    application.statusBarStyle = UIStatusBarStyleLightContent;
    
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                   didFinishLaunchingWithOptions:launchOptions];
}

- (void)crashlyticsDidDetectReportForLastExecution:(CLSReport *)report completionHandler:(void (^)(BOOL))completionHandler {
    // Use this opportinity to take synchronous action on a crash. See Crashlytics.h for
    // details and implications.
    
    // Maybe consult NSUserDefaults or show a UI prompt.
    
    // But, make ABSOLUTELY SURE you invoke completionHandler, as the SDK
    // will not submit the report until you do. You can do this from any
    // thread, but that's optional. If you want, you can just call the
    // completionHandler and return.
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        completionHandler(YES);
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)setupNormalRootViewController {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"1" forKey:kUserHasOnboardedKey];
        [defaults synchronize];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"loginView"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    self.window.rootViewController = vc;
}

- (void)handleOnboardingCompletion {
    // set that we have completed onboarding so we only do it once... for demo
    // purposes we don't want to have to set this every time so I'll just leave
    // this here...
    //    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserHasOnboardedKey];
    
    // transition to the main application
    [self setupNormalRootViewController];
}


- (OnboardingViewController *)generateFirstDemoVC {
    OnboardingContentViewController *firstPage = [OnboardingContentViewController contentWithTitle:@"Swapps" body:@"Collect your moments." image:[UIImage imageNamed:@"blue"] buttonText:@"" action:^{
        [[UIAlertView alloc] initWithTitle:nil message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }];
    
    OnboardingContentViewController *secondPage = [OnboardingContentViewController contentWithTitle:@"" body:@"Tag your friends to unlock pictures of you." image:[UIImage imageNamed:@"red"] buttonText:@"" action:^{
        [[[UIAlertView alloc] initWithTitle:nil message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
    secondPage.movesToNextViewController = YES;
//    secondPage.viewDidAppearBlock = ^{
//        [[[UIAlertView alloc] initWithTitle:@"Welcome!" message:@"You've arrived on the second page, and this alert was displayed from within the page's viewDidAppearBlock." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    };
    
    OnboardingContentViewController *thirdPage = [OnboardingContentViewController contentWithTitle:@"The more friends you tag,the more friends tag you!" body:@"" image:[UIImage imageNamed:@"yellow"] buttonText:@"Get Started" action:^{
        [self handleOnboardingCompletion];
    }];
    
    OnboardingViewController *onboardingVC = [OnboardingViewController onboardWithBackgroundImage:[UIImage imageNamed:@"street"] contents:@[firstPage, secondPage, thirdPage]];
    onboardingVC.shouldFadeTransitions = YES;
    onboardingVC.fadePageControlOnLastPage = YES;
    onboardingVC.fadeSkipButtonOnLastPage = YES;
    
    // If you want to allow skipping the onboarding process, enable skipping and set a block to be executed
    // when the user hits the skip button.
    onboardingVC.allowSkipping = NO;
    onboardingVC.skipHandler = ^{
        [self handleOnboardingCompletion];
    };
    
    return onboardingVC;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
