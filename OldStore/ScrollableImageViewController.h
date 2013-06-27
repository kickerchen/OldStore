//
//  ScrollableImageViewController.h
//  OldStore
//
//  Created by KICKERCHEN on 13/6/25.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollableImageViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *urlList;
@property (nonatomic) NSInteger currentPage;

@end
