//
//  AddTagViewController.m
//  Swapp
//
//  Created by Altimir Antonov on 9/13/15.
//  Copyright (c) 2015 Altimir Antonov. All rights reserved.
//

#import "AddTagViewController.h"
#import "UIView+Ext.h"
#import "Settings.h"
#import "UIKit+AFNetworking.h"
#import "FriendRow.h"
#include <AssetsLibrary/AssetsLibrary.h>
#import "tagView.h"
#import "MBProgressHUD.h"
#import "NHMainHeader.h"
#import "AFURLSessionManager.h"
#import "AFHTTPRequestOperationManager.h"

@interface AddTagViewController () <tagDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, NHAutoCompleteTextFieldDataSourceDelegate, NHAutoCompleteTextFieldDataFilterDelegate> {
    
    NHAutoCompleteTextField *autoCompleteTextField;
    NSArray *inUseDataSource;
}
@end

static int imageWidth = 40;

@implementation AddTagViewController {
    
    UITapGestureRecognizer *singleTapViewRecognizer;
    
    NSArray *imageArray;
    NSMutableArray *mutableArray;
    
    Settings *settings;
    ALAssetsLibrary *library;
    
    UIImageView *imageView;
    UIButton *next;
    UIButton *back;
    
    int shownpic;
    
    tagView *lastTag;
    
    NSMutableArray *tags;
    NSURL *currentImageName;
    
    CGFloat friendSize;
    
    UIButton *add;
    UIButton *addT;
    
    BOOL showUsername;
    BOOL showSettings;
    BOOL showButtons;
    
    
    UIView *headerView;
    UIView *bottomView;
    
    UIView *loadingView;
    
    tagView *tagToBeDeleted;
    
    BOOL listisShown;
    
    int taggedImages;
}

#define kCellIdentifier @"cellIdentifier"

- (void)viewDidLoad {
    shownpic = 0;
    
    taggedImages = 0;
    showUsername = YES;
    showSettings = NO;
    listisShown = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadOptions];
    //    [self getAllPictures];
}

- (void) loadOptions {
    
    tags = [[NSMutableArray alloc]init];
    
    CGFloat size = 50;
    friendSize = 400;
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    imageView = [[UIImageView alloc] init];
    [self.view addSubview:imageView];
    
    [imageView setBackgroundColor:[UIColor darkGrayColor]];
    [imageView anchorCenterLeftWithLeftPadding:0 width:self.view.width height:self.view.height/2];
    
    loadingView = [[UIView alloc] init];
    loadingView.backgroundColor = [UIColor clearColor];
    loadingView.clipsToBounds = YES;
    [MBProgressHUD showHUDAddedTo:loadingView animated:YES];
    
    [self.view addSubview:loadingView];
    [loadingView anchorCenterLeftWithLeftPadding:self.view.width width:self.view.width height:self.view.height/2];
    
    UIView *top = [[UIView alloc]init];
    [top setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:top];
    
    [top anchorTopCenterFillingWidthWithLeftAndRightPadding:0 topPadding:0 height:20];
    headerView = [[UIView alloc]init];
    [self.view addSubview:headerView];
    
    [headerView setBackgroundColor:[UIColor colorWithRed:64 green:64 blue:64 alpha:0.2]];
    
    [headerView anchorTopLeftWithLeftPadding:0 topPadding:20 width:self.view.width height:size];
    
    bottomView = [[UIView alloc]init];
    
    [bottomView setBackgroundColor:[UIColor colorWithRed:64 green:64 blue:64 alpha:0.2]];
    
    [bottomView anchorBottomLeftWithLeftPadding:0 bottomPadding:0 width:self.view.width height:size];
    
    back = [[UIButton alloc]init];
    [back setTitle:@"<-" forState:UIControlStateNormal];
    [headerView addSubview:back];
    //[back setBackgroundColor:[UIColor greenColor]];
    [back.layer setCornerRadius:size/2];
    
    [back anchorTopLeftWithLeftPadding:0 topPadding:0 width:size height:size];
    
    [back addTarget:self action:@selector(backToMain) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    next = [[UIButton alloc]init];
    [self.view addSubview:next];
    
    [next setTitle:@"" forState:UIControlStateNormal];
    [next setBackgroundColor:[UIColor clearColor]];
    [next addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    
    [next anchorCenterRightWithRightPadding:0 width:35 height:self.view.height/2];
    
    add = [[UIButton alloc]init];
    [add setTitle:@"Show" forState:UIControlStateNormal];
    [add.layer setCornerRadius:size/2];
    
    [add anchorBottomLeftWithLeftPadding:0 bottomPadding:0 width:size height:size];
    [add addTarget:self action:@selector(showNames) forControlEvents:UIControlEventTouchUpInside];
    
    settings = [Settings sharedInstance];
    
    [self getSpecificPicture];
    
    [self loadTagOptinos];
    
    showButtons = NO;
    
    [self showHideButtons];
}

- (void) backToMain {
    settings.selectedImageId = nil;
    settings.selectedIndexPath = -1;
    [self performSegueWithIdentifier:@"showDashboard" sender:nil];
}

- (void) showNames {
    for (tagView *t in tags) {
        [t showUsername: showUsername];
    }
}

- (void) showHideButtons {
    headerView.hidden = NO;
    //    headerView.hidden = !showButtons;
    //    bottomView.hidden = !showButtons;
}

- (void)didRecognizeSingleTap:(id)sender
{
    if (listisShown) {
        [self deleteLastTag];
        return;
    }
    
    UITapGestureRecognizer *tapGesture = sender;
    
    CGPoint touchPoint = [tapGesture locationInView:self.view];
    CGPoint normalizedTapLocation = [self normalizedPositionForPoint:touchPoint
                                                             inFrame:imageView.frame];
    
    CGPoint location = [tapGesture locationInView:self.view];
    
    if([[self.view hitTest:location withEvent:nil] isKindOfClass:[tagView class]]) {
        tagToBeDeleted = (tagView *)[self.view hitTest:location withEvent:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Are you sure you want to delete this tag?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        alert.tag = 1;
        [alert show];
        
        return;
    } else {
        //Do Something
    }
    
    if([self canTagPhotoAtNormalizedPoint:normalizedTapLocation])
    {
        CGPoint tagLocation =
        CGPointMake((imageView.frame.size.width * normalizedTapLocation.x),
                    (imageView.frame.size.height * normalizedTapLocation.y));
        
        CGRect rect = CGRectMake(tagLocation.x-imageWidth, tagLocation.y-imageWidth, imageWidth*2, imageWidth*2);
        
        tagView *tag = [[tagView alloc] initWithFrame:rect];
        tag.tagPosition = normalizedTapLocation;
        
        [tag draw];
        [tag showUsername:showUsername];
        tag.delegate = self;
        [imageView addSubview:tag];
        lastTag = tag;
        [tags addObject:tag];
        
        [self openFriendsList];
    }
    
    NSDictionary *tapInfo = @{@"touchGesture" : sender,
                              @"normalizedTapLocation" : [NSValue valueWithCGPoint:normalizedTapLocation]};
    NSLog(@"%@", tapInfo[@"normalizedTapLocation"]);
}

- (void)didRecognizeSingleViewTap:(id)sender
{
    if(!listisShown) {
        showButtons = !showButtons;
        [self showHideButtons];
    }
}

- (void) loadTagOptinos {
    
    singleTapViewRecognizer = [[UITapGestureRecognizer alloc]
                               initWithTarget:self action:@selector(didRecognizeSingleViewTap:)];
    [singleTapViewRecognizer setNumberOfTapsRequired:1];
    imageView.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:singleTapViewRecognizer];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(didRecognizeSingleTap:)];
    [singleTapRecognizer setNumberOfTapsRequired:1];
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:singleTapRecognizer];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognizer:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    recognizer.delegate = self;
    [imageView addGestureRecognizer:recognizer];
}

- (void)swipeRecognizer:(UISwipeGestureRecognizer *)sender {
    if (listisShown) {
        [self deleteLastTag];
        return;
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if(next.hidden) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"No More Images."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                CGPoint Position = CGPointMake(-imageView.width, imageView.yMin);
                imageView.frame = CGRectMake(Position.x , Position.y , imageView.width,imageView.height);
                
                CGPoint Position2 = CGPointMake(-self.view.width, loadingView.yMin);
                loadingView.frame = CGRectMake(0, Position2.y , loadingView.width, loadingView.height);
                
            } completion:^(BOOL finished) {
                imageView.hidden = YES;
                imageView.frame = CGRectMake(0 , imageView.yMin , loadingView.width, loadingView.height);
                [self showNext];
                
            }];
        }
    }
}

- (void)getSpecificPicture
{
    for (UIView *v in [imageView subviews]) {
        [v removeFromSuperview];
    }
    NSURL *aURL;
    if(settings.images.count!=0) {
        PHAsset *assert = settings.images[shownpic];
        
        [[PHImageManager defaultManager] requestImageForAsset:assert targetSize:self.view.frame.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            float minDimension = MIN(result.size.width, result.size.height);
            float screenWidth = self.view.bounds.size.width;
            
            UIImage *newImage;
            
            if(minDimension > screenWidth) {
                CGFloat scaleFactor = minDimension / screenWidth;
                
                UIGraphicsBeginImageContext(CGSizeMake(result.size.width/scaleFactor, result.size.height/scaleFactor));
                [result drawInRect:CGRectMake(0, 0, result.size.width/scaleFactor, result.size.height/scaleFactor)];
                newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
            } else {
                newImage = result;
            }
            
            CGFloat specialHeight =  newImage.size.height;
            if(specialHeight > self.view.height-140) {
                specialHeight = self.view.height-140;
            }
            [imageView setImage:result];
            [imageView anchorCenterLeftWithLeftPadding:0 width:self.view.frame.size.width height:specialHeight];
            
        }];
        //        NSURL *aURL = [[NSURL alloc] initWithString: settings.dicImages[settings.images[shownpic]]];
        
        currentImageName = aURL;
        //    library = [[ALAssetsLibrary alloc] init];
        //    [library assetForURL:aURL resultBlock:^(ALAsset *asset)
        //     {
        //         UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:1 orientation:UIImageOrientationUp];
        //
        //
        //         float minDimension = MIN(copyOfOriginalImage.size.width, copyOfOriginalImage.size.height);
        //         float screenWidth = self.view.bounds.size.width;
        //
        //         UIImage *newImage;
        //
        //         if(minDimension > screenWidth) {
        //             CGFloat scaleFactor = minDimension / screenWidth;
        //
        //             UIGraphicsBeginImageContext(CGSizeMake(copyOfOriginalImage.size.width/scaleFactor, copyOfOriginalImage.size.height/scaleFactor));
        //             [copyOfOriginalImage drawInRect:CGRectMake(0, 0, copyOfOriginalImage.size.width/scaleFactor, copyOfOriginalImage.size.height/scaleFactor)];
        //             newImage = UIGraphicsGetImageFromCurrentImageContext();
        //             UIGraphicsEndImageContext();
        //
        //
        ////             CGContextRef ctx = UIGraphicsGetCurrentContext();
        ////
        ////             //fill your custom view with a blue rect
        ////             CGContextFillRect(ctx, CGRectMake(0, 0, copyOfOriginalImage.size.width/scaleFactor, copyOfOriginalImage.size.height/scaleFactor));
        //
        //         } else {
        //             newImage = copyOfOriginalImage;
        //         }
        //
        //         CGFloat specialHeight =  newImage.size.height;
        //         if(specialHeight > self.view.height-140) {
        //             specialHeight = self.view.height-140;
        //         }
        //         [imageView anchorCenterLeftWithLeftPadding:0 width:newImage.size.width height:specialHeight];
        //         [imageView setImage:newImage];
        //
        //     }
        //            failureBlock:^(NSError *error)
        //     {
        //         // error handling
        //         NSLog(@"failure-----");
        //     }];
    } else {
        
    }
}

- (void) openFriendsList {
    
    [self.view removeGestureRecognizer:singleTapViewRecognizer];
    listisShown = YES;
    CGFloat controlWidth = 300;
    
    autoCompleteTextField = [[NHAutoCompleteTextField alloc] initWithFrame:CGRectMake((kScreenSize.width - controlWidth) / 2, 120, controlWidth, 22)];
    [autoCompleteTextField setDropDownDirection:NHDropDownDirectionDown];
    [autoCompleteTextField setDataSourceDelegate:self];
    [autoCompleteTextField setDataFilterDelegate:self];
    [self.view addSubview:autoCompleteTextField];
    [autoCompleteTextField.suggestionTextField becomeFirstResponder];
    
    NSMutableArray *fetched = [[NSMutableArray alloc] init];
    for (User *us in settings.friends) {
        BOOL found = false;
        
        for (tagView *tagUs in tags) {
            if([us.userId isEqualToString:tagUs.user.userId]) {
                found = YES;
            }
        }
        
        if(!found) {
            [fetched addObject:us];
        }
    }
    
    inUseDataSource = fetched;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showFriendList {
    
}

- (void) hideFriendList {
    
}

-(void)tagSelected:(FriendRow *)info {
    NSLog(@"name: %@", info.user.name);
    lastTag.user = info.user;
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


- (NSString *)dictionaryToJSON:(NSDictionary *)dictionary
{
    NSString *json = nil;
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    if(!jsonData)
    {
        return @"{}";
    }
    else if(!error)
    {
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    else
    {
        return error.localizedDescription;
    }
}

- (NSString*)base64forData:(NSData*) theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void)showNext {
    [UIView animateWithDuration:0.3 animations:^{
    } completion:^(BOOL finished) {
        imageView.hidden = NO;
        
        loadingView.frame = CGRectMake(imageView.width , imageView.yMin , imageView.width,imageView.height);
    }];
    
    
    for (tagView *t in tags) {
        NSLog(@"%@",[t description]);
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    NSMutableArray *tagsForSaving = [[NSMutableArray alloc] init];
    
    //    NSMutableArray *arrayOfTags = [NSMutableArray new];
    
    NSString *tagNames = @"";
    
    for( tagView *tag in tags) {
        NSString *normal = @"0";
        if(tag.user.normal) {
            normal = @"1";
        }
        
        NSArray *coord = @[[NSNumber numberWithFloat:tag.tagPosition.x] ,[NSNumber numberWithFloat:tag.tagPosition.y]];
        if(tag.user.userId) {
            [tagsForSaving addObject:@{
                                       @"fb_id": tag.user.userId,
                                       @"name": tag.user.name,
                                       @"profile_image": tag.user.imageUrl,
                                       @"tag_position": coord,
                                       @"normal": normal,
                                       }];
            tagNames = [tagNames stringByAppendingString:[NSString stringWithFormat:@"%@,", tag.user.userId]];
        }
        //        [arrayOfTags addObject:tagsForSaving];
    }
    
    //    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager new];
    
    NSData *imageData = UIImageJPEGRepresentation(imageView.image, 0.7);
    
    NSString *imageString = [self base64forData:imageData];
    //  NSString *data = [self dictionaryToJSON:tagsForSaving];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tagsForSaving options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary: @{
                                                                                         @"author": settings.current_user.userId,
                                                                                         @"tag_users":  jsonString,
                                                                                         @"image_source": imageString
                                                                                         
                                                                                         }];
    if (self.isUnlocking) {
        dictionary[@"tag_to_see"] = self.tagId;
    }
    if(tags.count==0) {
        
        [settings setImageAsUsed:settings.images[shownpic]];
        shownpic++;
        if(shownpic+1 >= [settings.images count]) {
            next.hidden = YES;
        } else {
            [self getSpecificPicture];
        }
        
        [tags removeAllObjects];
        
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        //    manager.requestSerializer =  [AFJSONRequestSerializer serializer];
        
        NSLog(@"dictionary: %@", dictionary);
        
        
        [manager POST:@"http://alti.xn----8sbarabrujldb2bdye.eu/backend_dev.php/tag" parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON from sent image: %@", responseObject);
            
            //        [fetchedImages addObject:dic];
            ;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        //
        //    [manager POST:@"http://alti.risunka.bg/backend_dev.php/tag" parameters:dictionary constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //        [formData appendPartWithFileURL:currentImageName name:@"image" error:nil];
        //    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"Success: %@", responseObject);
        //    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        NSLog(@"Error: %@", error);
        //    }];
        
        
        //
        //    NSURL *URL = [NSURL URLWithString:@"http://alti.risunka.bg/tag"];
        //    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        //
        //
        //    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:currentImageName progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        //        if (error) {
        //            NSLog(@"Error: %@", error);
        //        } else {
        //            NSLog(@"Success: %@ %@", response, responseObject);
        //        }
        //    }];
        //    [uploadTask resume];
        
        [defaults setObject:tagsForSaving forKey:@"images"];
        [defaults synchronize];
        
        if(self.isUnlocking  && tags.count>0) {
            //Show the new image
            [self performSegueWithIdentifier:@"showDashboard" sender:nil];
        } else {
            if (settings.current_user.newReg && tags.count > 0) {
                taggedImages++;
            }
            
            if(taggedImages == 2) {
                settings.current_user.newReg = NO;
                [self performSegueWithIdentifier:@"showDashboard" sender:nil];
            }
            
            [settings setImageAsUsed:settings.images[shownpic]];
            shownpic++;
            
            if(shownpic+1 >= [settings.images count]) {
                next.hidden = YES;
            } else {
                [self getSpecificPicture];
            }
            
            [tags removeAllObjects];
        }
    }
}

- (CGPoint)normalizedPositionForPoint:(CGPoint)point inFrame:(CGRect)frame
{
    point.x -= (frame.origin.x - self.view.frame.origin.x);
    point.y -= (frame.origin.y - self.view.frame.origin.y);
    
    CGPoint normalizedPoint = CGPointMake(point.x / frame.size.width,
                                          point.y / frame.size.height);
    
    return normalizedPoint;
}

- (BOOL)canTagPhotoAtNormalizedPoint:(CGPoint)normalizedPoint
{
    if((normalizedPoint.x >= 0.0 && normalizedPoint.x <= 1.0) &&
       (normalizedPoint.y >= 0.0 && normalizedPoint.y <= 1.0)){
        return YES;
    }
    return NO;
}

//Delegates

-(void)deleteTag:(tagView *)tag {
    [tags removeObject:tag];
    [tag removeFromSuperview];
    [autoCompleteTextField removeFromSuperview];
    autoCompleteTextField = nil;
    [self.view addGestureRecognizer:singleTapViewRecognizer];
}

- (void)deleteLastTag {
    [self deleteTag:lastTag];
    listisShown = NO;
}

-(void)delTag:(id)info {
    [self deleteTag:info];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if ( buttonIndex == 1) {
            [self deleteTag:tagToBeDeleted];
            tagToBeDeleted = nil;
        }
    }
}

#pragma mark - NHAutoComplete DataSource delegate functions

- (NSInteger)autoCompleteTextBox:(NHAutoCompleteTextField *)autoCompleteTextBox numberOfRowsInSection:(NSInteger)section
{
    return [inUseDataSource count];
}

- (UITableViewCell *)autoCompleteTextBox:(NHAutoCompleteTextField *)autoCompleteTextBox cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *imageV = [[UIImageView alloc] init];
    UILabel *name = [[UILabel alloc] init];
    name.tag = 100;
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    [name setFont:[UIFont fontWithName:cell.textLabel.font.fontName size:13.5f]];
    [name setTextColor:[UIColor brownColor]];
    
    [cell addSubview:imageV];
    [cell addSubview:name];
    
    [imageV anchorCenterLeftWithLeftPadding:10 width:30 height:30];
    [name alignToTheRightOf:imageV matchingCenterAndFillingWidthWithLeftAndRightPadding:10 height:30];
    
    [cell setBackgroundColor:[UIColor textBoxColor]];
    
    
    // Set text
    User *us = inUseDataSource[indexPath.row];
    
    [name setText:us.name];
    [name normalizeSubstring:name.text];
    
    
    
    //    imageV.layer.borderWidth = 1;
    //    name.layer.borderWidth = 1;
    [imageV setImageWithURL:[NSURL URLWithString:us.imageUrl]];
    
    imageV.layer.cornerRadius = 30/2;
    imageV.clipsToBounds = YES;
    
    // Highlight the selection
    if(autoCompleteTextBox.filterString)
    {
        [name boldSubstring:autoCompleteTextBox.filterString];
    }
    
    return cell;
}

#pragma mark - NHAutoComplete Filter data source delegate functions

-(BOOL)shouldFilterDataSource:(NHAutoCompleteTextField *)autoCompleteTextBox
{
    return YES;
}

-(void)autoCompleteTextBox:(NHAutoCompleteTextField *)autoCompleteTextBox didFilterSourceUsingText:(NSString *)text
{
    if ([text length] == 0)
    {
        inUseDataSource = [settings.friends mutableCopy];
        return;
    }
    
    //    NSPredicate *predCountry = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"CountryName", text];
    //    NSPredicate *predCapital = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"Capital", text];
    //
    //
    
    NSPredicate *aToZPredicate =
    [NSPredicate predicateWithFormat:@"self.name CONTAINS[c] %@", text];
    
    // Want to look the matches in both country name and capital
    NSCompoundPredicate *compoundPred = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:[NSArray arrayWithObjects:aToZPredicate, nil]];
    
    NSMutableArray *fetched = [[NSMutableArray alloc] init];
    for (User *us in settings.friends) {
        BOOL found = false;
        
        for (tagView *tagUs in tags) {
            if([us.userId isEqualToString:tagUs.user.userId]) {
                found = YES;
            }
        }
        
        if(!found) {
            [fetched addObject:us];
        }
    }
    
    NSArray *filteredArr = [fetched filteredArrayUsingPredicate:compoundPred];
    
    inUseDataSource = filteredArr;
}

- (void)AutoCompleteTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *us = inUseDataSource[indexPath.row];
    NSLog(@"selected UserName: %@", us.name);
    lastTag.user = us;
    listisShown = NO;
    [autoCompleteTextField removeFromSuperview];
    autoCompleteTextField = nil;
    [self.view addGestureRecognizer:singleTapViewRecognizer];
    
}

@end
