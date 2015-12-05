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

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface LoginViewController () <FBSDKLoginButtonDelegate> {
    BOOL _viewDidAppear;
    BOOL _viewIsVisible;
    BOOL _willGo;
    NSArray *mainArray;
    MBProgressHUD *HUD;
  
    NSArray *m_friends;
    NSArray *m_taggable_friends;
    
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
        [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
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
                 [self getFBResult];
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

  
  Settings *set = [Settings sharedInstance];
  
  dispatch_group_t group = dispatch_group_create();
  
    
//    [CrashlyticsKit setObjectValue:@"befre new group" forKey:@"debugData"];
  dispatch_group_enter(group);
  
//    [CrashlyticsKit setObjectValue:@"after new group" forKey:@"debugData"];

    
    
//    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id,name,picture,friends.limit(5000){name,id,picture},taggable_friends.limit(5000){name,id,picture}"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//        [CrashlyticsKit setObjectValue:@"request delivered" forKey:@"debugData"];
//        [CrashlyticsKit setObjectValue:error forKey:@"error"];
//        
//        CLS_LOG(@"/me results: %@", result);
//        
//        if (!error) {
//            NSDictionary *dic = @{
//                                  @"userId":result[@"id"],
//                                  @"name":result[@"name"],
//                                  @"imageUrl": result[@"picture"][@"data"][@"url"],
//                                  @"normal": @"1"
//                                  };
//            CLS_LOG(@"/me dic results: %@", dic);
//            CLS_LOG(@"The name: ");
//            CLS_LOG(@"%@", dic[@"userId"]);
//            [CrashlyticsKit setUserIdentifier:dic[@"userId"]];
//            [CrashlyticsKit setUserName:dic[@"name"]];
//            
//            CLS_LOG(@"The name: ");
//            CLS_LOG(@"%@", dic[@"name"]);
//            
//            [CrashlyticsKit setObjectValue:result forKey:@"result"];
//            
//            set.current_user = [[User alloc] initWithProperties:dic];
//            [CrashlyticsKit setObjectValue:@"set current user" forKey:@"debugData"];
//
//            CLS_LOG(@"set current user");
//            CLS_LOG(@"%@", set.current_user);
//            
//            m_friends = result[@"friends"][@"data"];
//            CLS_LOG(@"m_friends %@", m_friends);
//            [CrashlyticsKit setObjectValue:@"get friends data" forKey:@"debugData"];
//
//            NSMutableArray *allCloseFriends = [[NSMutableArray alloc]init];
//            
//            [CrashlyticsKit setObjectValue:m_friends forKey:@"m_friends"];
//
//            
//            for (NSDictionary *user in m_friends) {
//                NSDictionary *dic = @{
//                                      @"userId":user[@"id"],
//                                      @"name":user[@"name"],
//                                      @"imageUrl": user[@"picture"][@"data"][@"url"],
//                                      @"normal": @"1"
//                                      };
//                
//                User *user = [[User alloc] initWithProperties:dic];
//                [allCloseFriends addObject:user];
//            }
//            
//            CLS_LOG(@"all close friends: ");
//            CLS_LOG(@"%@", allCloseFriends);
//            
//            [CrashlyticsKit setObjectValue:@"m_friends ready" forKey:@"debugData"];
//
//            
//            [CrashlyticsKit setObjectValue:allCloseFriends forKey:@"allCloseFriends"];
//
//            set.closefriends = allCloseFriends;
//            [CrashlyticsKit setObjectValue:@"set all close friends" forKey:@"debugData"];
//            
//            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//            NSDictionary *parameters = @{@"facebook_id": dic[@"userId"],
//                                         @"name": dic[@"name"],
//                                         @"profile_image": dic[@"imageUrl"]};
//            
//            [CrashlyticsKit setObjectValue:@"request for create fb user" forKey:@"debugData"];
//            
//            CLS_LOG(@"parameters: ");
//            CLS_LOG(@"%@", parameters);
//            
//            [manager POST:@"http://alti.risunka.bg/backend_dev.php/create_facebook_user" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                NSLog(@"JSON: %@", responseObject);
//                CLS_LOG(@"JSON results: ");
//                CLS_LOG(@"%@", responseObject);
//                [CrashlyticsKit setObjectValue:@"fb user request delivered" forKey:@"debugData"];
//
//                [CrashlyticsKit setObjectValue:responseObject forKey:@"fbData"];
//
//                if([[NSString stringWithFormat:@"%@", responseObject[@"success"]]  isEqual: @"0"]) {
//                    set.current_user.newReg = false;
//                } else {
//                    set.current_user.newReg = true;
//                }
//                //TODO: Check For New Registration
//                //                 _newRegistration = NO;
//                
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"Error: %@", error);
//            }];
//            
//            [CrashlyticsKit setObjectValue:@"set taggable_friends" forKey:@"debugData"];
//
//            m_taggable_friends = result[@"taggable_friends"][@"data"];
//            
//            CLS_LOG(@"all m_taggable_friends: ");
//            CLS_LOG(@"%@", m_taggable_friends);
//            
//            [CrashlyticsKit setObjectValue:m_taggable_friends forKey:@"m_taggable_friends"];
//
//            HUD.labelText = @"Fetching Friends ...";
//            
//            [CrashlyticsKit setObjectValue:@"leaving the group" forKey:@"debugData"];
//
//            dispatch_group_leave(group);
//        } else {
//            dispatch_group_leave(group);
//        }
//        
//    }];
    
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id,name,picture,friends.limit(5000){name,id,picture}"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
      if (!error) {
        NSDictionary *dic = @{
                              @"userId":result[@"id"],
                              @"name":result[@"name"],
                              @"imageUrl": result[@"picture"][@"data"][@"url"],
                              @"normal": @"1"
                              };
        
        set.current_user = [[User alloc] initWithProperties:dic];
        m_friends = result[@"friends"][@"data"];
        
        NSMutableArray *allCloseFriends = [[NSMutableArray alloc]init];
        
        for (NSDictionary *user in m_friends) {
          NSDictionary *dic = @{
                                @"userId":user[@"id"],
                                @"name":user[@"name"],
                                @"imageUrl": user[@"picture"][@"data"][@"url"],
                                @"normal": @"1"
                                };
          
          User *user = [[User alloc] initWithProperties:dic];
          [allCloseFriends addObject:user];
        }

          CLS_LOG(@"/me dic results: %@", dic);
          CLS_LOG(@"The name: ");
          CLS_LOG(@"%@", dic[@"userId"]);
          [CrashlyticsKit setUserIdentifier:dic[@"userId"]];
          [CrashlyticsKit setUserName:dic[@"name"]];

          CLS_LOG(@"The name: ");
          CLS_LOG(@"%@", dic[@"name"]);
          
        set.closefriends = allCloseFriends;
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"facebook_id": dic[@"userId"],
                                     @"name": dic[@"name"],
                                     @"profile_image": dic[@"imageUrl"]};
        
        [manager POST:@"http://alti.xn----8sbarabrujldb2bdye.eu/backend_dev.php/create_facebook_user" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"JSON: %@", responseObject);
          
          if([[NSString stringWithFormat:@"%@", responseObject[@"success"]]  isEqual: @"0"]) {
            set.current_user.newReg = false;
          } else {
            set.current_user.newReg = true;
          }
          //TODO: Check For New Registration
          //                 _newRegistration = NO;
          
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"Error: %@", error);
        }];
        
        dispatch_group_leave(group);
      } else {
        dispatch_group_leave(group);
      }
      
    }];
  
//  dispatch_group_enter(group);
//  
//    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/taggable_friends" parameters:@{@"fields":@"id, name, picture", @"limit": @"5000"}]
//     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//       if (!error) {
//         
//         m_taggable_friends = result[@"data"];
//         
//         //       NSArray *taggable_friends = result[@"data"];
//         
//         //       NSArray *friends = result[@"friends"][@"data"];
//         
//         
//         
//         
//         HUD.labelText = @"Fetching Friends ...";
//         
//         //       // Store the data
//         //       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//         //       //[defaults removeObjectForKey:@"images"];
//         //       NSMutableArray *users = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"users"]];
//         //       BOOL notFound = true;
//         //       for (NSDictionary *user in users) {
//         //
//         //         if([user[@"userId"] isEqualToString:dic[@"userId"]]) {
//         //           notFound = false;
//         //           break;
//         //         }
//         //       }
//         //
//         //       if(notFound) {
//         //         [users addObject:dic];
//         //       }
//         //
//         //       [defaults setObject:users forKey:@"users"];
//         
//         
//         //             [defaults setObject:firstName forKey:@"userInfo"];
//         //             [defaults setObject:lastName forKey:@"lastname"];
//         //             [defaults setInteger:age forKey:@"age"];
//         //             [defaults setObject:imageData forKey:@"image"];
//         
//         //       [defaults synchronize];
//         
//         NSLog(@"Data saved");
//         //             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//         //
//         //             [manager POST:@"http://localhost/swapp/index.php" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
//         //                 NSLog(@"JSON: %@", responseObject);
//         //             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         //                 NSLog(@"Error: %@", error);
//         //             }];
//         //       [MBProgressHUD hideHUDForView:self.view animated:YES];
//         //       _willGo = YES;
//         //       [self performSegueWithIdentifier:@"showDashboard" sender:nil];
//         
//         dispatch_group_leave(group);
//       } else {
//         NSLog(@"%@", error);
//         
//         //[self getFriends];
//           dispatch_group_leave(group);
//
//        // [MBProgressHUD hideHUDForView:self.view animated:YES];
//           
//         //[self tryAgain];
//         
//       }
//     }];
  
  
    
//  dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
  
    [CrashlyticsKit setObjectValue:@"waiting for group notify" forKey:@"debugData"];

  dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      [CrashlyticsKit setObjectValue:@"in the notify" forKey:@"debugData"];

    [self connectFriends];
  });
//  dispatch_release(group);
  
}

- (void) connectFriends {
  
  Settings *set = [Settings sharedInstance];
    CLS_LOG(@"connect Friends start for ");
  NSMutableArray *ar = [[NSMutableArray alloc]init];
    [CrashlyticsKit setObjectValue:@"start merging" forKey:@"debugData"];
    if(m_taggable_friends) {
        for (NSDictionary *user in m_taggable_friends) {
            BOOL found = false;
            for (NSDictionary *closeFriend in m_friends) {
                
                [CrashlyticsKit setObjectValue:@{
                                                 @"taggableUser": user,
                                                 @"mUser": closeFriend
                                                 } forKey:@"mergingData"];
                
                CLS_LOG(@"in for mergin data: ");
                CLS_LOG(@"%@", @{
                                 @"taggableUser": user,
                                 @"mUser": closeFriend
                                 } );
                
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
    } else {
        for (NSDictionary *closeFriend in m_friends) {
            NSMutableDictionary *mutClose = [[NSMutableDictionary alloc] initWithDictionary:closeFriend];
            [mutClose setValue:@"1" forKey:@"normal"];
            [ar addObject:mutClose];
        }
    }
              
    [CrashlyticsKit setObjectValue:ar forKey:@"mergedFriendsTemp"];
    
    
    CLS_LOG(@"The merged data: ");
    CLS_LOG(@"%@", ar);
    
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
    
    CLS_LOG(@"The allFriends: ");
    CLS_LOG(@"%@", allFriends);
  
    [CrashlyticsKit setObjectValue:allFriends forKey:@"finalFriends"];

  set.friends = allFriends;
  dispatch_async(dispatch_get_main_queue(), ^{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _willGo = YES;
    [self performSegueWithIdentifier:@"showDashboard" sender:nil];
  });
  

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
