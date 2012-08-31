//
//  CBUnruledPosition.m
//  CBase Chess
//
//  Created by Austen Green on 8/30/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CBUnruledPosition.h"
#import "CKPosition+Private.h"

@implementation CBUnruledPosition

- (BOOL)isMoveLegal:(CKMove *)move
{
	return YES;
}

- (BOOL)isMovePseudoLegal:(CKMove *)move
{
	return YES;
}

- (BOOL)shouldUnmakeMoveIfInCheck
{
	return NO;
}

@end
