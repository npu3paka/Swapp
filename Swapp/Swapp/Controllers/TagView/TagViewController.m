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

@interface TagViewController () <UIActionSheetDelegate>

@end

@implementation TagViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    [self.view addSubview:imageView];
    
    [imageView setBackgroundColor:[UIColor darkGrayColor]];
    
    [imageView anchorCenterLeftWithLeftPadding:0 width:self.view.width height: (self.view.width / self.image.size.width) * self.image.size.height];
    
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
        
        [self goBack];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
