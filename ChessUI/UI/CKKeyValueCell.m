//
//  CKKeyValueCell.m
//  ChessUI
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKKeyValueCell.h"

@implementation CKKeyValueCell
@synthesize textField = _textField;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.textLabel.frame;
    CGFloat maxX = CGRectGetMaxX(frame);
    frame.origin.x = self.indentationWidth;
    frame.size.width = maxX - CGRectGetMinX(frame);
    
    self.textLabel.frame = frame;
    
    if (_textField)
    {
        CGRect frame = self.detailTextLabel.frame;
        frame.size.width = (CGRectGetMaxX(self.contentView.bounds) - 10.0f) - CGRectGetMinX(frame);
        _textField.frame = frame;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    self.textField.hidden = !editing;
    
    
    if (editing)
    {
        [self.textField becomeFirstResponder];
        self.textField.font = self.detailTextLabel.font;
        self.textField.text = self.detailTextLabel.text;
        self.detailTextLabel.hidden = YES;
    }
    else
    {
        [self.textField resignFirstResponder];
        self.detailTextLabel.hidden = NO;
    }
}

- (UITextField *)textField
{
    if (!_textField)
    {
        _textField = [[UITextField alloc] initWithFrame:self.detailTextLabel.frame];
        [self.contentView addSubview:_textField];
    }
    return _textField;
}

@end
