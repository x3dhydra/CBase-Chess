//
//  CKMoveListView.h
//  CBase Chess
//
//  Created by Austen Green on 7/23/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKMoveListViewDelegate;

@interface CKMoveListView : UIView
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, assign) id<CKMoveListViewDelegate> delegate;

@end

@protocol CKMoveListViewDelegate <NSObject>

@optional
- (void)moveListView:(CKMoveListView *)moveListView didSelectOptionAtIndex:(NSInteger)index;

@end