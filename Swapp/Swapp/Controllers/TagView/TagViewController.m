//
//  TagViewController.m
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "TagViewController.h"
#import "UIView+Ext.h"
#include <AssetsLibrary/AssetsLibrary.h>
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "Settings.h"

@interface TagViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation TagViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _imageView = [[UIImageView alloc] init];
    //initWithImage:self.image];
    [self.view addSubview:_imageView];
    if(self.image) {
        [_imageView setImage:self.image];
        [_imageView setBackgroundColor:[UIColor darkGrayColor]];
        
        CGFloat height = (self.view.width / self.image.size.width) * self.image.size.height;
        if(height+140 > self.view.frame.size.height) {
            height = self.view.frame.size.height-140;
        }
        
        [_imageView anchorCenterLeftWithLeftPadding:0 width:self.view.width height: height];
        
        
    } else {
        [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:self.imageURL] placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
            [_imageView setImage:image];
            [_imageView setBackgroundColor:[UIColor darkGrayColor]];
            
            CGFloat height = (self.view.width / image.size.width) * image.size.height;
            if(height+140 > self.view.frame.size.height) {
                height = self.view.frame.size.height-140;
            }
            
            [_imageView anchorCenterLeftWithLeftPadding:0 width:self.view.width height: height];
            
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
            [self goBack];
        }];
    }
    
    [self drawView];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void) drawView {
    UIButton *backButton = [UIButton new];
    
//    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"Back-50"] forState:UIControlStateNormal];

    [self.view addSubview:backButton];
    
    [backButton anchorTopLeftWithLeftPadding:10 topPadding:20 width:50 height:40];
    
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *opButton = [UIButton new];
    
    [self.view addSubview:opButton];
  
  [opButton setImage:[UIImage imageNamed:@"Menu-50"] forState:UIControlStateNormal];
//    [opButton setTitle:@"Option" forState:UIControlStateNormal];
  
  [opButton anchorTopRightWithRightPadding:10 topPadding:20 width:50 height:50];
  
//    [opButton anchorBottomRightWithRightPadding:10 bottomPadding:10 width:50 height:40];
  
    
    [opButton addTarget:self action:@selector(opButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) opButtonPressed {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Save the swapp",
                            @"Delete the swapp",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self saveImage];
                    break;
                case 1:
                    [self deleteImage];
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void) goBack {
    Settings *settings = [Settings sharedInstance];
    settings.selectedIndexPath = - 1;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveImage {
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    documentsDirectory = [documentsDirectory stringByAppendingString:[self randomStringWithLength:12]];
    //    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@".png"];
    UIImage *image = self.image; // imageView is my image from camera
    //    NSData *imageData = UIImagePNGRepresentation(image);
    //    [imageData writeToFile:savedImagePath atomically:NO];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            // TODO: error handling
        } else {
            // TODO: success handling
        }
    }];}

-(NSString *) randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

- (void) deleteImage {
 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:@"http://alti.xn----8sbarabrujldb2bdye.eu/backend_dev.php/delete_swapp" parameters:@{ @"swapp_tag_id" :self.imageId } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        Settings *settings = [Settings sharedInstance];
        [settings.photos removeObjectAtIndex:self.selectedIndexPath];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
