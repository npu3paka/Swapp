//
//  DashboardViewController.m
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "DashboardViewController.h"
#import "Settings.h"
#import "User.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "UIView+Ext.h"
#import "BoardTag.h"

#import <CoreImage/CoreImage.h>
#include <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"
#import "XHRealTimeBlur.h"
#import "TagViewController.h"

@interface DashboardViewController () <FBSDKLoginButtonDelegate> {
    ALAssetsLibrary *library;
    Settings *settings;
    
    UIButton *add;
    
    NSMutableArray *fetchedImages;
    
    FBSDKLoginButton *loginButton;
    
    UIView *headerView;
    
    UIView *imagesView;
    
    UIScrollView *imagesScrollView;
    
    UIView *sideMenu;
    
    BOOL sideMenuIsOpen;
}

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadHeaderView];

    [self drawSideMenu];
    
    [self loadOptions];
    
    [self downloadImages];
    
    // Do any additional setup after loading the view.
}

-(void) loadHeaderView {
    headerView = [[UIView alloc]init];
    [self.view addSubview:headerView];
    [headerView anchorTopCenterFillingWidthWithLeftAndRightPadding:0 topPadding:0 height:250];
    
    UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]]
    ;
    [headerView addSubview:backImage];
    [backImage fillSuperview];
    
    [backImage showRealTimeBlurWithBlurStyle:XHBlurStyleBlackTranslucent];
    
    UIButton *menuButton = [[UIButton alloc] init];
    [menuButton setTitle:@"Menu" forState:UIControlStateNormal];
    
    [headerView addSubview:menuButton];
    
    [menuButton anchorTopLeftWithLeftPadding:5 topPadding:5 width:50 height:25];
    
    [menuButton addTarget:self action:@selector(openSideMenu) forControlEvents:UIControlEventTouchUpInside];
}

- (void) drawSideMenu {
    sideMenu = [[UIView alloc] init];
    [sideMenu setFrame: CGRectMake(-self.view.width*0.7, 0, self.view.width*0.7, self.view.height)];
    loginButton = [[FBSDKLoginButton alloc] init];
    [sideMenu addSubview:loginButton];
    loginButton.delegate = self;
    
    
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    [self.view addSubview:sideMenu];
    [sideMenu setBackgroundColor:[UIColor grayColor]];
    
    [loginButton anchorInCenterWithWidth:sideMenu.width-40 height:40];
    sideMenuIsOpen = NO;
    
    UIButton *menuButton = [[UIButton alloc] init];
    [menuButton setTitle:@"Menu" forState:UIControlStateNormal];
    
    [sideMenu addSubview:menuButton];
    
    [menuButton anchorTopRightWithRightPadding:5 topPadding:5 width:25 height:25];
    
    [menuButton addTarget:self action:@selector(openSideMenu) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void) loadOptions {
    CGFloat size = 50;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    settings = [Settings sharedInstance];
    
    User *user = settings.current_user;
    
    UIImageView *profileImage = [[UIImageView alloc] init];
    
    [profileImage setImageWithURL:[NSURL URLWithString:user.imageUrl]];
    profileImage.layer.masksToBounds = YES;
    [profileImage.layer setCornerRadius:80/2];
    
    [headerView addSubview:profileImage];
    [profileImage anchorTopCenterWithTopPadding:50 width:80 height:80];
    //    [profileImage anchorInCenterWithWidth:100 height:100];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    [nameLabel setText:user.name];
    [nameLabel setTextColor:[UIColor whiteColor]];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:nameLabel];
    
    [nameLabel alignUnder:profileImage centeredFillingWidthWithLeftAndRightPadding:0 topPadding:10 height:20];
    
    UILabel *Swapp1 = [[UILabel alloc] init];
    [Swapp1 setTextColor:[UIColor whiteColor]];
    Swapp1.textAlignment = NSTextAlignmentCenter;
    Swapp1.text = @"Received Swapps";
    
    [headerView addSubview:Swapp1];
    
    UILabel *Num1 = [[UILabel alloc] init];
    [Num1 setTextColor:[UIColor whiteColor]];
    Num1.textAlignment = NSTextAlignmentCenter;
    Num1.text = @"100";
    
    [headerView addSubview:Num1];
    
    UILabel *Swapp2 = [[UILabel alloc] init];
    [Swapp2 setTextColor:[UIColor whiteColor]];
    Swapp2.textAlignment = NSTextAlignmentCenter;
    Swapp2.text = @"Sent Swapps";
    
    [headerView addSubview:Swapp2];
    
    UILabel *Num2 = [[UILabel alloc] init];
    [Num2 setTextColor:[UIColor whiteColor]];
    Num2.textAlignment = NSTextAlignmentCenter;
    Num2.text = @"15";
    
    [headerView addSubview:Num2];
    
    CGFloat Width = (headerView.width - 3*10)/2;
    [headerView groupHorizontally:@[Swapp1,Swapp2] centeredUnderView:nameLabel topPadding:10 spacing:10 width:Width height:40];
    
    [Num1 alignUnder:Swapp1 matchingCenterWithTopPadding:7 width:Width height:13];
    
    [Num2 alignUnder:Swapp2 matchingCenterWithTopPadding:7 width:Width height:13];
    
    add = [[UIButton alloc]init];
    [add setTitle:@"Add" forState:UIControlStateNormal];
    [self.view addSubview:add];
    [add setBackgroundColor:[UIColor greenColor]];
    [add.layer setCornerRadius:size/2];
    [add anchorBottomRightWithRightPadding:20 bottomPadding:20 width:size height:size];
    [add addTarget:self action:@selector(openTagView) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view bringSubviewToFront:sideMenu];
}

- (void) drawView {
    
    int x=0;
    int y = 0;
    int br = 1;
    
    imagesScrollView = [[UIScrollView alloc] init];
    
    [self.view addSubview:imagesScrollView];
    
    [imagesScrollView alignUnder:headerView centeredFillingWidthAndHeightWithLeftAndRightPadding:0 topAndBottomPadding:0];
    //    imagesView = [[UIView alloc] init];
    //    [imagesScrollView addSubview:imagesView];
    
    double lastY = 0;
    for(NSDictionary *imag in fetchedImages) {
        //[imageV setImage:image];
        
        int imWidth = (self.view.width - 2*20 - 3*5)/4;
        lastY = 20+imWidth*y+ 5*y+imWidth;
        
        BoardTag *tagViewButton = [[BoardTag alloc]init];
        [imagesScrollView addSubview:tagViewButton];
        tagViewButton.layer.borderWidth = 1;
        tagViewButton.clipsToBounds = YES;
        [tagViewButton setFrame:CGRectMake(20+imWidth*x + 5*x, 10+imWidth*y+ 5*y, imWidth, imWidth)];
        tagViewButton.full = NO;
        tagViewButton.layer.cornerRadius = imWidth/6;
        tagViewButton.radius = tagViewButton.layer.cornerRadius;
        tagViewButton.fr = tagViewButton.frame;
        
        [tagViewButton addTarget:self action:@selector(tagPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        x++;
        br++;
        if(br == 5) {
            br = 1;
            y++;
            x = 0;
        }
        
        //ALAsset* asset = settings.images[shownpic];
        NSURL *aURL =  [NSURL URLWithString:imag[@"s_image_source"]];
        
        [tagViewButton setImageForState:UIControlStateNormal withURL:aURL];
        
//        //NSURL* aURL = [NSURL URLWithString:settings.images[shownpic]];
//        library = [[ALAssetsLibrary alloc] init];
//        [library assetForURL:aURL resultBlock:^(ALAsset *asset)
//         {
//             UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:1 orientation:UIImageOrientationUp];
//             //         UIImageView *image = [[UIImageView alloc] initWithImage:copyOfOriginalImage];
//             //
//             [tagViewButton setImage:copyOfOriginalImage forState:UIControlStateNormal];
//             //[imageView addSubview:image];
//             //[image fillSuperview];
//         }
//                failureBlock:^(NSError *error)
//         {
//             // error handling
//             NSLog(@"failure-----");
//         }];
        
    }
    
    //    [imagesView anchorTopLeftWithLeftPadding:0 topPadding:0 width:self.view.width height:lastY];
    
    imagesScrollView.contentSize = CGSizeMake(self.view.width, lastY);
    //    imagesScrollView.contentSize = imagesView.frame.size;
    
    [self.view bringSubviewToFront:add];
    
    [self.view bringSubviewToFront:sideMenu];
}

- (void) downloadImages {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"fb_id": settings.current_user.userId};
    [manager POST:@"http://alti.risunka.bg/get_author_images" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSArray *arr = [responseObject objectForKey:@"message"];
        
        fetchedImages = [arr copy];
        
        settings.ownImages = arr;
        
        [self drawView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)getAllPictures
{
    NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
    
    library = [[ALAssetsLibrary alloc] init];
    
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [assetURLDictionaries addObject:result];
            }
        }
    };
    
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [settings setImages:assetURLDictionaries];
            
            [self performSegueWithIdentifier:@"addTag" sender:nil];
            
        }
    };
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
    Settings *set = [Settings sharedInstance];
    set.current_user = nil;
    set.friends = nil;
    set.closefriends = nil;

    [self performSegueWithIdentifier:@"showLogin" sender:nil];
}

- (void) openTagView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getAllPictures];
}

- (void) tagPressed:(BoardTag *)sender {
    
    TagViewController *vc = [TagViewController new];
    
    [vc.view setBackgroundColor:[UIColor blackColor]];
    
    vc.image = sender.imageView.image;
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) openSideMenu {
    sideMenuIsOpen = !sideMenuIsOpen;
    CGFloat x = 0;
    if(!sideMenuIsOpen) {
        x = -sideMenu.width;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [sideMenu setFrame: CGRectMake(x, 0, self.view.width*0.7, self.view.height)];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


@end
