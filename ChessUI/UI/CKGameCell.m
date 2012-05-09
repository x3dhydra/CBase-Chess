//
//  CKGameCell.m
//  ChessUI
//
//  Created by Austen Green on 5/3/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKGameCell.h"

static const CGFloat kLeftInset = 32.0f;

@implementation CKGameCell
@synthesize resultLabel = _resultLabel;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize alternateSubtitleLabel = _alternateSubtitleLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIColor *highlightedColor = [UIColor whiteColor];
        
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _resultLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _resultLabel.textColor = [UIColor colorWithRed:86.0f/255.0f green:147.0f/255.0f blue:214.0f/255.0f alpha:1.0f];
        _resultLabel.textAlignment = UITextAlignmentRight;
        _resultLabel.highlightedTextColor = highlightedColor;
        [self.contentView addSubview:_resultLabel];
        
        UIColor *lightGray = [UIColor colorWithRed:133.0f/255.0f green:133.0f/255.0f blue:133.0f/255.0f alpha:1.0f];
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _subtitleLabel.textColor = lightGray;
        _subtitleLabel.highlightedTextColor = highlightedColor;
        [self.contentView addSubview:_subtitleLabel];
        
        _alternateSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _alternateSubtitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _alternateSubtitleLabel.textColor = lightGray;
        _alternateSubtitleLabel.highlightedTextColor = highlightedColor;
        [self.contentView addSubview:_alternateSubtitleLabel];
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
        self.detailTextLabel.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.resultLabel sizeToFit];
    self.resultLabel.frame = CGRectOffset(self.resultLabel.bounds, CGRectGetMaxX(self.contentView.bounds) - CGRectGetWidth(self.resultLabel.bounds) - 5.0f, self.textLabel.font.lineHeight - self.resultLabel.font.lineHeight);
    
    self.textLabel.frame = CGRectMake(kLeftInset, 0.0f, CGRectGetMinX(self.resultLabel.frame) - 10.0f - kLeftInset, self.textLabel.font.lineHeight);
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0.0f, kLeftInset, 0.0f, 10.0f);
    self.detailTextLabel.frame = UIEdgeInsetsInsetRect(CGRectMake(0.0f, CGRectGetMaxY(self.textLabel.frame), CGRectGetWidth(self.contentView.bounds), self.detailTextLabel.font.lineHeight), inset);
    self.subtitleLabel.frame = UIEdgeInsetsInsetRect(CGRectMake(0.0f, CGRectGetMaxY(self.detailTextLabel.frame), CGRectGetWidth(self.contentView.bounds), self.subtitleLabel.font.lineHeight), inset);
    self.alternateSubtitleLabel.frame = UIEdgeInsetsInsetRect(CGRectMake(0.0f, CGRectGetMaxY(self.subtitleLabel.frame), CGRectGetWidth(self.contentView.bounds), self.alternateSubtitleLabel.font.lineHeight), inset);
}

@end
