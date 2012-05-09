//
//  CKGameCell.h
//  ChessUI
//
//  Created by Austen Green on 5/3/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKGameCell : UITableViewCell
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *alternateSubtitleLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
