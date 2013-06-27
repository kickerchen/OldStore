//
//  UrlImageView.h
//  OldStore
//
//  Created by KICKERCHEN on 13/6/23.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

@protocol UrlImageViewDelegate;


@interface UrlImageView : UIImageView {
    id <UrlImageViewDelegate> delegate;
    CGPoint tapLocation;
    UIActivityIndicatorView *activityIndicator;
    NSString *sourceUrl;
    NSMutableData *downloadData;
    NSURLConnection *connection;
    UIViewContentMode contentMode;
}

@property (nonatomic, strong) id<UrlImageViewDelegate> delegate;
@property (nonatomic) UIViewContentMode  contentMode;

- (void)loadImageFromURL: (NSString *) url;
- (UIImage *)getUIImage;

@end

/*
Protocol for the tap-detecting image view's delegate.
*/
@protocol UrlImageViewDelegate <NSObject>

@optional
- (void)urlImageView: (UrlImageView *)view singleTapAtPoint: (CGPoint)tapPoint;

@end