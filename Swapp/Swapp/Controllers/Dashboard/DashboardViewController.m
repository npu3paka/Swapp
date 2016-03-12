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
//#include <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"
#import "XHRealTimeBlur.h"
#import "TagViewController.h"
#import "AddTagViewController.h"
#import "CustomSheet.h"
//#import <Answers/Answers.h>
#import "Swapps-Swift.h"
@import Photos;

@interface DashboardViewController () <FBSDKLoginButtonDelegate, UIActionSheetDelegate, DashboardColDelegate> {
//    ALAssetsLibrary *library;
    Settings *settings;
    
    UIButton *add;
    
    NSMutableArray *fetchedImages;
    
    FBSDKLoginButton *loginButton;
    
    UIView *headerView;
    
    UIView *imagesView;
    
    UIScrollView *imagesScrollView;
    DashboardCollection *imagesColView;
    UIView *sideMenu;
    
    BOOL sideMenuIsOpen;
    
    UILabel *SentTags;
    
    UILabel *ResTags;
    
    UILabel *scrollHeader;
    
    int maxPerLine;
    
    UILongPressGestureRecognizer *longPress;
    
    UIView *oneBigView;
    
    UIView *backgrVi;
    
    BOOL taggedUsers;
    
    BOOL isUnclogking;
    NSString *unlockingId;
    
    BOOL isLoaded;
    BOOL loaded;
    
    NSString *swCount;
    NSString *swTags;
}

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    taggedUsers = false;
    isUnclogking = false;
    loaded = false;
    [self loadHeaderView];

//    imagesColView = [[DashboardCollection alloc] init];
//    
//    [self.view addSubview:imagesColView];
//    
//    [imagesColView fillSuperview];
//    
//    imagesColView.backgroundColor = [UIColor clearColor];
//    imagesColView.dashboardDelegate = self;
//    imagesColView.extensionUrl = @"get_user_tags";
//    imagesColView.chosenLink = 1;
    
//
//    oneBigView = [[UIView alloc] init];
//    imagesScrollView = [[UIScrollView alloc] init];
//    [self.view addSubview:imagesScrollView];
//    [imagesScrollView fillSuperview];
//    [imagesScrollView addSubview:oneBigView];
//    [oneBigView fillSuperview];
//    
//    maxPerLine = 3;
    settings = [Settings sharedInstance];
    
    CLS_LOG(@"The settings: ");
    CLS_LOG(@"%@", settings);
    
    [self drawSideMenu];
    
//    [self loadOptions];
    
    [self getUser];
    
//    [self.view bringSubviewToFront:imagesScrollView];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (settings.current_user.newReg) {
        [self openTagView];
    }
    
    if(settings.selectedImageId != nil) {
        TagViewController *vc = [TagViewController new];
        
        [vc.view setBackgroundColor:[UIColor blackColor]];
        
        vc.imageURL = [NSURL URLWithString:settings.selectedImageUrl];
        vc.imageId = settings.selectedImageId;
        
        settings.selectedImageId = nil;
        
        [self presentViewController:vc animated:NO completion:nil];
        
        [imagesColView updateHeader];
    } else {
        if(!loaded) {
            
            imagesColView = [[DashboardCollection alloc] init];
            
            [self.view addSubview:imagesColView];
            
            [imagesColView fillSuperview];
            
            imagesColView.dashboardDelegate = self;
            imagesColView.extensionUrl = @"get_user_tags";
            imagesColView.chosenLink = 1;
            [imagesColView setupView];
            [imagesColView updateUI];
            [self updateCollection];
            loaded = true;
        }
//        [self downloadImages];
    }
    
//    [self drawView];
}

-(void) loadHeaderView {
    
    UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    [self.view addSubview:backImage];
    [backImage fillSuperview];
    
    [backImage showRealTimeBlurWithBlurStyle:XHBlurStyleBlackTranslucent];
//    
//    headerView = [[UIView alloc]init];
//    [oneBigView addSubview:headerView];
//    [headerView anchorTopCenterFillingWidthWithLeftAndRightPadding:0 topPadding:0 height:250];
//    
//    UIButton *menuButton = [[UIButton alloc] init];
//    //    [menuButton setTitle:@"Menu" forState:UIControlStateNormal];
//    
//    [menuButton setImage:[UIImage imageNamed:@"Settings-32"] forState:UIControlStateNormal];
//    
//    //    [headerView addSubview:menuButton];
//    
//    [menuButton anchorTopRightWithRightPadding:5 topPadding:20 width:32 height:32];
//    
//    [menuButton addTarget:self action:@selector(openSideMenu) forControlEvents:UIControlEventTouchUpInside];
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
    //    [menuButton setTitle:@"Menu" forState:UIControlStateNormal];
    [menuButton setImage:[UIImage imageNamed:@"Settings-32"] forState:UIControlStateNormal];
    
    [sideMenu addSubview:menuButton];
    
    [menuButton anchorTopRightWithRightPadding:5 topPadding:5 width:25 height:25];
    
    [menuButton addTarget:self action:@selector(openSideMenu) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void) loadOptions {
    CGFloat size = 50;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
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
    
    //    UILabel *Swapp1 = [[UILabel alloc] init];
    //    [Swapp1 setTextColor:[UIColor whiteColor]];
    //    Swapp1.textAlignment = NSTextAlignmentCenter;
    //    Swapp1.text = @"Received Swapps";
    //    Swapp1.font = [Swapp1.font fontWithSize:10];
    //    [headerView addSubview:Swapp1];
    //
    //  UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapptapped:)];
    //
    //  tapGesture1.numberOfTapsRequired=1;
    //    ResTags = [[UILabel alloc] init];
    //    [ResTags setTextColor:[UIColor whiteColor]];
    //    ResTags.textAlignment = NSTextAlignmentCenter;
    //    ResTags.text = @"0";
    //  ResTags.tag = 1;
    //  [ResTags setUserInteractionEnabled:YES];
    //  [ResTags addGestureRecognizer:tapGesture1];
    //
    //    [headerView addSubview:ResTags];
    
    //    UILabel *Swapp2 = [[UILabel alloc] init];
    //    [Swapp2 setTextColor:[UIColor whiteColor]];
    //    Swapp2.textAlignment = NSTextAlignmentCenter;
    //    Swapp2.text = @"Sent Swapps";
    //    Swapp2.font = [Swapp2.font fontWithSize:10];
    //
    //    [headerView addSubview:Swapp2];
    //
    //    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapptapped:)];
    //
    //  tapGesture.numberOfTapsRequired=1;
    //    SentTags = [[UILabel alloc] init];
    //    [SentTags setTextColor:[UIColor whiteColor]];
    //    SentTags.textAlignment = NSTextAlignmentCenter;
    //    SentTags.text = @"0";
    //  SentTags.tag = 2;
    //    [SentTags setUserInteractionEnabled:YES];
    //  [SentTags addGestureRecognizer:tapGesture];
    //
    //    [headerView addSubview:SentTags];
    
    CGFloat Width = (headerView.width - 4*10)/3;
    
    
    
    UIView *specialView = [UIView new];
    
    //  specialView.layer.borderWidth = 1;
    
    [headerView addSubview:specialView];
    
    [specialView anchorBottomCenterFillingWidthWithLeftAndRightPadding:-2 bottomPadding:0 height:60];
    
    UIView *leftBox = [UIView new];
    UIView *centerBox = [UIView new];
    UIView *rightBox = [UIView new];
    
    leftBox.layer.borderColor = [UIColor whiteColor].CGColor;
    centerBox.layer.borderColor = [UIColor whiteColor].CGColor;
    rightBox.layer.borderColor = [UIColor whiteColor].CGColor;
    
    leftBox.layer.borderWidth = 1;
    centerBox.layer.borderWidth = 1;
    rightBox.layer.borderWidth = 1;
    
    [specialView addSubview:leftBox];
    [specialView addSubview:centerBox];
    [specialView addSubview:rightBox];
    
    CGFloat boxWidth = specialView.width/3;
    
    leftBox.frame = CGRectMake(0, 0, boxWidth, specialView.height);
    centerBox.frame = CGRectMake(leftBox.xMax, 0, boxWidth, specialView.height);
    rightBox.frame = CGRectMake(centerBox.xMax, 0, boxWidth, specialView.height);
    
    add = [[UIButton alloc]init];
    [add setTitle:@"+" forState:UIControlStateNormal];
    [centerBox addSubview:add];
    [add setBackgroundColor:[UIColor orangeColor]];
    [add.layer setCornerRadius:40/2];
    [add anchorInCenterWithWidth:40 height:40];
    //  [add anchorBottomRightWithRightPadding:20 bottomPadding:20 width:size height:size];
    [add addTarget:self action:@selector(openTagView) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *Swapp1 = [[UILabel alloc] init];
    [Swapp1 setTextColor:[UIColor whiteColor]];
    Swapp1.textAlignment = NSTextAlignmentCenter;
    Swapp1.text = @"Received Swapps";
    Swapp1.font = [Swapp1.font fontWithSize:14];
    [leftBox addSubview:Swapp1];
    
    Swapp1.frame = CGRectMake(0, 0, leftBox.width, leftBox.height/2);
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapptapped:)];
    
    tapGesture1.numberOfTapsRequired=1;
    ResTags = [[UILabel alloc] init];
    [ResTags setTextColor:[UIColor whiteColor]];
    ResTags.textAlignment = NSTextAlignmentCenter;
    ResTags.text = @"0";
    ResTags.tag = 1;
    [ResTags setUserInteractionEnabled:YES];
    [ResTags addGestureRecognizer:tapGesture1];
    
    [leftBox addSubview:ResTags];
    
    ResTags.frame = CGRectMake(0, Swapp1.yMax, leftBox.width, leftBox.height/2);
    
    
    UILabel *Swapp2 = [[UILabel alloc] init];
    [Swapp2 setTextColor:[UIColor whiteColor]];
    Swapp2.textAlignment = NSTextAlignmentCenter;
    Swapp2.text = @"Sent Swapps";
    Swapp2.font = [Swapp2.font fontWithSize:14];
    
    [rightBox addSubview:Swapp2];
    
    Swapp2.frame = CGRectMake(0, 0, rightBox.width, rightBox.height/2);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapptapped:)];
    
    tapGesture.numberOfTapsRequired=1;
    SentTags = [[UILabel alloc] init];
    [SentTags setTextColor:[UIColor whiteColor]];
    SentTags.textAlignment = NSTextAlignmentCenter;
    SentTags.text = @"0";
    SentTags.tag = 2;
    [SentTags setUserInteractionEnabled:YES];
    [SentTags addGestureRecognizer:tapGesture];
    
    [rightBox addSubview:SentTags];
    
    SentTags.frame = CGRectMake(0, Swapp2.yMax, rightBox.width, rightBox.height/2);
    
    [self.view bringSubviewToFront:sideMenu];
    
    backgrVi = [UIView new];
    
    [backgrVi setBackgroundColor:[UIColor whiteColor]];
    backgrVi.alpha = 0.2;
    [oneBigView addSubview:backgrVi];
    [backgrVi alignUnder:headerView centeredFillingWidthAndHeightWithLeftAndRightPadding:0 topAndBottomPadding:0];
    
    scrollHeader = [UILabel new];
    
    [scrollHeader setText:@"Received Swapps"];
    [oneBigView addSubview:scrollHeader];
    scrollHeader.textAlignment = NSTextAlignmentCenter;
    [scrollHeader alignUnder:headerView centeredFillingWidthWithLeftAndRightPadding:0 topPadding:0 height:45];
    
}

- (void)swappTapped:(int)tag {
    NSLog(@"chosen tag is: %d", tag);

    NSString *url = @"http://alti.xn----8sbarabrujldb2bdye.eu/get_author_images";
    
    NSString *url2 = @"get_author_images";
    int chosenLink = 2;
    scrollHeader.text = @"Sent Swapps";
    taggedUsers = true;
    if (tag == 1) {
        scrollHeader.text = @"Received Swapps";
        url = @"http://alti.xn----8sbarabrujldb2bdye.eu/get_user_tags";
        url2 = @"get_user_tags";
        chosenLink = 1;
        taggedUsers = false;
    }
    
    [imagesColView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver: imagesColView];
    imagesColView = nil;
    
    imagesColView = [[DashboardCollection alloc] init];
    
    [self.view addSubview:imagesColView];
    
    [imagesColView fillSuperview];
//    [imagesColView alignUnder:scrollHeader centeredFillingWidthAndHeightWithLeftAndRightPadding:0 topAndBottomPadding:0];
    
    imagesColView.dashboardDelegate = self;
    imagesColView.extensionUrl = url2;
    imagesColView.chosenLink = chosenLink;
    [imagesColView setupView];
    [imagesColView updateUI];
    
    [self updateCollection];
}

//-(void) swapptapped:(UITapGestureRecognizer *)sender {
//    UIView *theSuperview = imagesColView; // whatever view contains your image views
//    CGPoint touchPointInSuperview = [sender locationInView:theSuperview];
//    UIView *touchedView = [theSuperview hitTest:touchPointInSuperview withEvent:nil];
//    NSLog(@"%ld",(long)touchedView.tag);
//    
//    NSString *url = @"http://alti.xn----8sbarabrujldb2bdye.eu/get_author_images";
//    
//    NSString *url2 = @"get_author_images";
//    scrollHeader.text = @"Sent Swapps";
//    taggedUsers = true;
//    if (touchedView.tag == 1) {
//        scrollHeader.text = @"Received Swapps";
//        url = @"http://alti.xn----8sbarabrujldb2bdye.eu/get_user_tags";
//        url2 = @"get_user_tags";
//        taggedUsers = false;
//    }
//    
//    imagesColView = [[DashboardCollection alloc] init];
//    
//    [self.view addSubview:imagesColView];
//    
//    [imagesColView alignUnder:scrollHeader centeredFillingWidthAndHeightWithLeftAndRightPadding:0 topAndBottomPadding:0];
//    
//    imagesColView.dashboardDelegate = self;
//    imagesColView.extensionUrl = url2;
//    [imagesColView setupView];
//    [imagesColView updateUI];
//    
//    [self updateCollection];
////    imagesColView.extensionUrl = url2;
////    [imagesColView updateUI];
////    
//
//    
//    //    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
////    NSDictionary *parameters = @{@"fb_id": settings.current_user.userId};
////    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
////        NSLog(@"JSON: %@", responseObject);
////        //
////        if([[responseObject objectForKey:@"message"] isKindOfClass:[NSArray class]]) {
////            NSArray *arr = [responseObject objectForKey:@"message"];
////            
////            fetchedImages = [arr copy];
////            
////            settings.ownImages = arr;
////            if (touchedView.tag == 1) {
////                ResTags.text = [NSString stringWithFormat:@"%lu",(unsigned long)fetchedImages.count];
////            }
////            if (touchedView.tag == 2) {
////                SentTags.text = [NSString stringWithFormat:@"%lu",(unsigned long)fetchedImages.count];
////            }
////            BOOL author = YES;
////            if( touchedView.tag == 1) {
////                author = NO;
////            }
////            [self drawView: author];
////        }
////    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
////        NSLog(@"Error: %@", error);
////    }];
//    
//    //  if([touchedView isKindOfClass:[UIImageView class]])
//    //  {
//    //    // hooray, it's one of your image views! do something with it.
//    //  }
//}

- (void) drawView:(BOOL) author {
    int y = 0;
    int br = 0;
    
    [imagesColView removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver: imagesColView];
    imagesColView = nil;
    
    imagesColView = [[DashboardCollection alloc] init];
    imagesColView.dashboardDelegate = self;
    [self.view addSubview:imagesColView];
//    imagesColView.extensionUrl = @"get_user_tags";
//    [oneBigView addSubview:imagesColView];
    [imagesColView fillSuperview];
//    [imagesColView alignUnder:scrollHeader centeredFillingWidthAndHeightWithLeftAndRightPadding:0 topAndBottomPadding:0];
    [imagesColView setupView];
    [imagesColView updateUI];
    
    [self updateCollection];
    //    imagesView = [[UIView alloc] init];
    //    [imagesScrollView addSubview:imagesView];
    
//    
//    double lastY = 0;
//    int imWidth = (self.view.width - (maxPerLine+1)*2)/maxPerLine;
//    
//    for(NSDictionary *imag in fetchedImages) {
//        //[imageV setImage:image];
//        
//        lastY = 5+imWidth*y+ maxPerLine*y+imWidth;
//        
//        BoardTag *tagViewButton = [[BoardTag alloc]init];
//        tagViewButton.swappId = imag[@"s_swapp_tag_id"];
//        if ([imag[@"s_can_see"]  isEqual: @"1"] || author) {
//            
//            tagViewButton.canSee = true;
//        } else {
//            tagViewButton.canSee = false;
//        }
//        [imagesColView addSubview:tagViewButton];
//        tagViewButton.layer.borderWidth = 1;
//        tagViewButton.clipsToBounds = YES;
//        [tagViewButton setFrame:CGRectMake(2 + 2*br + imWidth*br, 10+imWidth*y+ maxPerLine*y, imWidth, imWidth)];
//        tagViewButton.full = NO;
//        tagViewButton.fr = tagViewButton.frame;
//        
//        longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressTap:)];
//        [tagViewButton addGestureRecognizer:longPress];
//        
//        [tagViewButton addTarget:self action:@selector(tagPressed:) forControlEvents:UIControlEventTouchUpInside];
//        
//        br++;
//        if(br == maxPerLine) {
//            br = 0;
//            y++;
//        }
//        
//        //ALAsset* asset = settings.images[shownpic];
//        NSURL *aURL =  [NSURL URLWithString:[NSString stringWithFormat:@"http://alti.xn----8sbarabrujldb2bdye.eu/uploads/%@",imag[@"s_image_source"]]];
//        
//        tagViewButton.swappUrl = aURL;
//        
//        if(tagViewButton.canSee || taggedUsers) {
//            [tagViewButton setImageForState:UIControlStateNormal withURL:aURL];
//        } else {
//            [tagViewButton setImage:[UIImage imageNamed:@"Lock Filled-500"] forState:UIControlStateNormal];
//        }
//        [tagViewButton.imageView setContentMode:UIViewContentModeScaleToFill];
//        
//        //        //NSURL* aURL = [NSURL URLWithString:settings.images[shownpic]];
//        //        library = [[ALAssetsLibrary alloc] init];
//        //        [library assetForURL:aURL resultBlock:^(ALAsset *asset)
//        //         {
//        //             UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:1 orientation:UIImageOrientationUp];
//        //             //         UIImageView *image = [[UIImageView alloc] initWithImage:copyOfOriginalImage];
//        //             //
//        //             [tagViewButton setImage:copyOfOriginalImage forState:UIControlStateNormal];
//        //             //[imageView addSubview:image];
//        //             //[image fillSuperview];
//        //         }
//        //                failureBlock:^(NSError *error)
//        //         {
//        //             // error handling
//        //             NSLog(@"failure-----");
//        //         }];
//        
//    }
//    
//    //    [imagesView anchorTopLeftWithLeftPadding:0 topPadding:0 width:self.view.width height:lastY];
//    imagesColView.frame = CGRectMake(imagesColView.xMin, imagesColView.yMin, self.view.width, lastY);
//    oneBigView.frame = CGRectMake(0, 0, self.view.width, imagesColView.yMax);
//    imagesScrollView.contentSize = CGSizeMake(self.view.width, oneBigView.yMax);
//    [backgrVi alignUnder:headerView centeredFillingWidthAndHeightWithLeftAndRightPadding:0 topAndBottomPadding:0];
//
//    //    imagesScrollView.contentSize = imagesView.frame.size;
//    
//    [self.view bringSubviewToFront:add];
//    
//    [self.view bringSubviewToFront:sideMenu];
}

-(void)longPressTap:(id)sender
{
    UIGestureRecognizer *recognizer = (UIGestureRecognizer*) sender;
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        BoardTag *vi = recognizer.view;
        NSLog(@"%f, %f", vi.fr.origin.x, vi.fr.origin.y);
//        CustomSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
//                                @"Save the swapp",
//                                @"Delete the swapp",
//                                nil];
//        popup.swappId = vi.swappId;
//        popup.tag = vi.swappId;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Option:"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleActionSheet]; // 1
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Save the swapp"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

//                                                                  NSLog(@"You pressed button one");
                                                              }]; // 2
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Delete the swapp"
                                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                   [self deleteImage: vi.swappId];

//                                                                   NSLog(@"You pressed button two");
                                                               }]; // 3
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                   
                                                                   //                                                                   NSLog(@"You pressed button two");
                                                               }]; // 3
        
        [alert addAction:firstAction]; // 4
        [alert addAction:secondAction]; // 5
        [alert addAction:cancelAction]; // 5
        
        
        [self presentViewController:alert animated:YES completion:nil]; // 6
        
//        [popup showInView:[UIApplication sharedApplication].keyWindow];
        
    }
}

//- (void)actionSheet:(CustomSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
//    
//    switch (popup.tag) {
//        case 1: {
//            switch (buttonIndex) {
//                case 0:
//                    //          [self saveImage];
//                    break;
//                case 1:
//                    [self deleteImage: popup.swappId];
//                    break;
//            }
//            break;
//        }
//        default:
//            break;
//    }
//}

- (void) getUser {
    CLS_LOG(@"The settings: ");
    CLS_LOG(@"%@", settings);
    
    CLS_LOG(@"The settings.user: ");
    CLS_LOG(@"%@", settings.current_user);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"fb_id": settings.current_user.userId};
    [manager POST:@"http://alti.xn----8sbarabrujldb2bdye.eu/get_user" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        if(responseObject[@"message"] != nil) {
        
            NSDictionary *dic = responseObject[@"message"];
            
            swCount = [NSString stringWithFormat:@"%@",dic[@"u_tags_made"]];
            swTags = [NSString stringWithFormat:@"%@", dic[@"tagged_in_count"]];
            settings.recSwCount = swCount;
            settings.sentSwCount = swTags;
            [self updateCollection];
            
            SentTags.text = swCount;
            ResTags.text =  swTags;
            
        } else {
//            NSDictionary *dic = responseObject[@"message"];
            
            swCount = @"0";
            swTags = @"0";
            [self updateCollection];
            
            SentTags.text = swCount;
            ResTags.text =  swTags;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void) updateCollection {
    imagesColView.swCount = swCount;
    imagesColView.swTag = swTags;
    [imagesColView updateHeader];
}

- (void) downloadImages {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"fb_id": settings.current_user.userId};
    [manager POST:@"http://alti.xn----8sbarabrujldb2bdye.eu/get_user_tags" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        if([[responseObject objectForKey:@"message"] isKindOfClass:[NSArray class]]) {
            NSArray *arr = [responseObject objectForKey:@"message"];
            
            fetchedImages = [arr copy];
            
            settings.ownImages = arr;
            
            [self drawView:NO];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)getAllPictures
{
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    
    [settings addNewImages:allPhotos];
    if(settings.images.count>0) {
        [self performSegueWithIdentifier:@"addTag" sender:nil];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Something went wrong. Please try again later!"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    }
    
//    NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
//    
//    library = [[ALAssetsLibrary alloc] init];
//    
//    
////    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
//   
//    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
//        if(result != nil) {
//            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
//                [assetURLDictionaries addObject:result];
//            }
//        }
//    };
//    
//    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
//        if(group != nil) {
//            [group enumerateAssetsUsingBlock:assetEnumerator];
//            [settings addNewImages:assetURLDictionaries];
//            
//            [self performSegueWithIdentifier:@"addTag" sender:nil];
//            
//        }
//    };
//    
//    [library enumerateGroupsWithTypes:ALAssetsGroupAll
//                           usingBlock:assetGroupEnumerator
//                         failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
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
    
    if(!sender.canSee) {
        isUnclogking = true;
        unlockingId = sender.swappId;
        settings.selectedImageUrl = sender.swappUrl;
        settings.selectedImageId = sender.swappId;
        [self getAllPictures];

    } else {
            TagViewController *vc = [TagViewController new];
            
            [vc.view setBackgroundColor:[UIColor blackColor]];
            
            vc.image = sender.imageView.image;
            vc.imageURL = sender.swappUrl;
            vc.imageId = sender.swappId;
            
            [self presentViewController:vc animated:YES completion:nil];
        
    }
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

- (void) deleteImage: (NSString *) imageId {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:@"http://alti.xn----8sbarabrujldb2bdye.eu/backend_dev.php/delete_swapp" parameters:@{ @"swapp_tag_id" :imageId } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"addTag"]) {
        AddTagViewController *vc = [segue destinationViewController];
        vc.isNew = YES;
        vc.isUnlocking = isUnclogking;
        vc.tagId = unlockingId;
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

- (void)chosenTag:(SwappInfo *)info image:(UIImage *)image {
    if(!info.canSee) {
        isUnclogking = true;
        unlockingId = [NSString stringWithFormat:@"%ld",(long)info.id];
        settings.selectedImageUrl = info.url;
        settings.selectedImageId = [NSString stringWithFormat:@"%ld",(long)info.id];
        [self getAllPictures];
        
    } else {
        TagViewController *vc = [TagViewController new];
        
        [vc.view setBackgroundColor:[UIColor blackColor]];
        
        vc.image = image;
        vc.imageURL = [NSURL URLWithString:info.url];
        vc.imageId = [NSString stringWithFormat:@"%ld",(long)info.id];
        
        [self presentViewController:vc animated:YES completion:nil];
        
    }
}


@end
