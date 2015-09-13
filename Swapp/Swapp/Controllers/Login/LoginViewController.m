//
//  LoginViewController.m
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "LoginViewController.h"
#import "Settings.h"
#import "DashboardViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "PICollectionPageView.h"
#import "UIView+Ext.h"
#import "XHRealTimeBlur.h"
#import "FBShimmeringView.h"
#import "AFNetworking.h"

@interface LoginViewController () <FBSDKLoginButtonDelegate> {
    BOOL _viewDidAppear;
    BOOL _viewIsVisible;
    BOOL _willGo;
    NSArray *mainArray;
    MBProgressHUD *HUD;
    
    BOOL _newRegistration;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _newRegistration = YES;
    HUD = [[MBProgressHUD alloc] initWithView:self.view];

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIImageView *imagev = [[UIImageView alloc]init];
    [imagev setImage:[UIImage imageNamed:@"background.jpg"]];
    [self.view addSubview:imagev];
    [imagev fillSuperview];
    
    [imagev showRealTimeBlurWithBlurStyle:XHBlurStyleBlackTranslucent];
    
    FBShimmeringView *_shimmeringView = [[FBShimmeringView alloc] init];
    _shimmeringView.shimmering = YES;
    _shimmeringView.shimmeringBeginFadeDuration = 0.3;
    _shimmeringView.shimmeringOpacity = 0.5;
    [self.view addSubview:_shimmeringView];
    
    
    UILabel *Title = [[UILabel alloc] initWithFrame:_shimmeringView.bounds];
    Title.text = @"SWAPP";
    Title.textAlignment = NSTextAlignmentCenter;
    Title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:60.0];
    
    
    [self.view addSubview:Title];
    
    [_shimmeringView anchorTopCenterFillingWidthWithLeftAndRightPadding:20 topPadding:self.view.height/3-50 height:60];
    _shimmeringView.contentView = Title;
    //    _shimmeringView.layer.borderWidth = 2;
    
    UIImageView *singleLine = [[UIImageView alloc] init];
    [singleLine setBackgroundColor:[UIColor darkGrayColor]];
    
    [singleLine setFrame:CGRectMake(_shimmeringView.xMin, _shimmeringView.yMax+5, _shimmeringView.width, 2)];
    
    [self.view addSubview:singleLine];
    
    UILabel *littleTitle = [[UILabel alloc]init];
    
    littleTitle.text = @"This is little text";
    littleTitle.numberOfLines = 2;
    littleTitle.textAlignment = NSTextAlignmentCenter;
    littleTitle.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30.0];
    
    [self.view addSubview:littleTitle];
    
    [littleTitle alignUnder:singleLine matchingLeftWithTopPadding:5 width:_shimmeringView.width height:60];
    
    UILabel *copyright = [[UILabel alloc] init];
    
    copyright.text = @"This is simple copyright text";
    [copyright setTextColor:[UIColor whiteColor]];
    copyright.textAlignment = NSTextAlignmentCenter;
    
    copyright.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:10.0];
    [self.view addSubview:copyright];
    
    [copyright anchorBottomCenterFillingWidthWithLeftAndRightPadding:20 bottomPadding:5 height:15];
    
    
    UIButton *fbloginbutton = [[UIButton alloc]init];
    [fbloginbutton addTarget:self action:@selector(FBLoginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [fbloginbutton setBackgroundImage:[UIImage imageNamed:@"fblogin"] forState:UIControlStateNormal];
    [self.view addSubview:fbloginbutton];
    
    fbloginbutton.layer.borderWidth = 2;
    [fbloginbutton setFrame:CGRectMake(Title.xMin+20,littleTitle.yMax + (copyright.yMin-littleTitle.yMax)/2-20, Title.width, 50)];
    
    HUD.dimBackground = YES;
    [self.view addSubview:HUD];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [self getFBResult];
    }
}

-(void) FBLoginButtonPressed {
    HUD.labelText = @"Login ...";
    [HUD show:YES];
    if (![FBSDKAccessToken currentAccessToken]) {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
         {
             if (error)
             {
                 // Error
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
             }
             else if (result.isCancelled)
             {
                 // Cancelled
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
             }
             else
             {
                 if ([result.grantedPermissions containsObject:@"email"])
                 {
                     [self getFBResult];
                 }
             }
         }];
    } else {
        [self getFBResult];
    }
}


-(void)getFBResult
{
    HUD.labelText = @"Login ...";
    [HUD show:YES];
    
    if ([FBSDKAccessToken currentAccessToken])
    {
        HUD.labelText = @"Getting Friends ...";
        
        [self getFriends];
    }
}

- (void) getFriends {
    //    [HUD showRealTimeBlurWithBlurStyle:XHBlurStyleTranslucent];
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, picture, friends.limit(5000){name,picture}, taggable_friends.limit(5000)"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSDictionary *dic = @{
                                   @"userId":result[@"id"],
                                   @"name":result[@"name"],
                                   @"imageUrl": result[@"picture"][@"data"][@"url"],
                                   @"normal": @"1"
                                   };
             
             Settings *set = [Settings sharedInstance];
             set.current_user = [[User alloc] initWithProperties:dic];
             
             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
             NSDictionary *parameters = @{@"facebook_id": dic[@"userId"],
                                          @"name": dic[@"name"],
                                          @"profile_image": dic[@"imageUrl"]};
             [manager POST:@"http://alti.risunka.bg/backend_dev.php/create_facebook_user" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"JSON: %@", responseObject);
                 
                 //TODO: Check For New Registration
//                 _newRegistration = NO;
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"Error: %@", error);
             }];
             
             
             
             NSArray *taggable_friends = result[@"taggable_friends"][@"data"];
             
             NSArray *friends = result[@"friends"][@"data"];
             
             NSMutableArray *ar = [[NSMutableArray alloc]init];
             
             for (NSDictionary *user in taggable_friends) {
                 BOOL found = false;
                 for (NSDictionary *closeFriend in friends) {
                     
                     if([user[@"name"] isEqualToString:closeFriend[@"name"]] && [user[@"picture"][@"data"][@"url"] isEqualToString:closeFriend[@"picture"][@"data"][@"url"] ]) {
                         NSMutableDictionary *mutClose = [[NSMutableDictionary alloc] initWithDictionary:closeFriend];
                         [mutClose setValue:@"1" forKey:@"normal"];
                         [ar addObject:mutClose];
                         found = true;
                     }
                 }
                 if(!found) {
                     NSMutableDictionary *mutFr = [[NSMutableDictionary alloc] initWithDictionary:user];
                     [mutFr setValue:@"0" forKey:@"normal"];
                     [ar addObject:mutFr];
                 }
             }
             
             NSMutableArray *allFriends = [[NSMutableArray alloc]init];
             for (NSDictionary *user in ar) {
                 NSDictionary *dic = @{
                                       @"userId":user[@"id"],
                                       @"name":user[@"name"],
                                       @"imageUrl": user[@"picture"][@"data"][@"url"],
                                       @"normal": user[@"normal"]
                                       };
                 
                 User *user = [[User alloc] initWithProperties:dic];
                 [allFriends addObject:user];
             }
             
             set.friends = allFriends;
             
             NSMutableArray *allCloseFriends = [[NSMutableArray alloc]init];
             
             HUD.labelText = @"Fetching Friends ...";
             
             for (NSDictionary *user in friends) {
                 NSDictionary *dic = @{
                                       @"userId":user[@"id"],
                                       @"name":user[@"name"],
                                       @"imageUrl": user[@"picture"][@"data"][@"url"],
                                       @"normal": @"1"
                                       };
                 
                 User *user = [[User alloc] initWithProperties:dic];
                 [allCloseFriends addObject:user];
             }
             
             set.closefriends = allCloseFriends;
             // Store the data
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             //[defaults removeObjectForKey:@"images"];
             NSMutableArray *users = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"users"]];
             BOOL notFound = true;
             for (NSDictionary *user in users) {
                 
                 if([user[@"userId"] isEqualToString:dic[@"userId"]]) {
                     notFound = false;
                     break;
                 }
             }
             
             if(notFound) {
                 [users addObject:dic];
             }
             
             [defaults setObject:users forKey:@"users"];
             
             
             //             [defaults setObject:firstName forKey:@"userInfo"];
             //             [defaults setObject:lastName forKey:@"lastname"];
             //             [defaults setInteger:age forKey:@"age"];
             //             [defaults setObject:imageData forKey:@"image"];
             
             [defaults synchronize];
             
             NSLog(@"Data saved");
             //             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
             //
             //             [manager POST:@"http://localhost/swapp/index.php" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
             //                 NSLog(@"JSON: %@", responseObject);
             //             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             //                 NSLog(@"Error: %@", error);
             //             }];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             _willGo = YES;
             [self performSegueWithIdentifier:@"showDashboard" sender:nil];
             
         } else {
             NSLog(@"%@", error);
             
             //[self getFriends];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             //[self tryAgain];
             
         }
     }];
    
}


#pragma mark - FBSDKLoginButtonDelegate


- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (error) {
        NSLog(@"Unexpected login error: %@", error);
        NSString *alertMessage = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?: @"There was a problem logging in. Please try again later.";
        NSString *alertTitle = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops";
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        if (![FBSDKAccessToken currentAccessToken]) {
            //[self tryAgain];
            //TODO Something
        } else {
            
            [self getFriends];
            //[self observeProfileChange:nil];
        }
        //[self observeProfileChange:nil];
        
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"Logged out of facebook");
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
    FBSDKLoginManager *fbMan = [[FBSDKLoginManager alloc] init];
    
    [fbMan logOut];
    
    [FBSDKAccessToken setCurrentAccessToken:nil];
    Settings *set = [Settings sharedInstance];
    set.current_user = nil;
    set.friends = nil;
    set.closefriends = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    //if(_willGo) {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
