//
//  UrlImageView.h
//  OldStore
//
//  Created by KICKERCHEN on 13/6/23.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UrlImageView : UIView {
    UIActivityIndicatorView *activityIndicator;
    NSString *sourceUrl;
    NSMutableData *downloadData;
    NSURLConnection *connection;
    Boolean fitFrame;
}

@property (nonatomic) Boolean fitFrame;

- (void)loadImageFromURL: (NSString *) url;
- (UIImage *)getUIImage;

@end
