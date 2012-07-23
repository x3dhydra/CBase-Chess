//
//  CKAccessibility.h
//  ChessUI
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreChess.h"
#import "ChessKit.h"


@interface CKAccessibility : NSObject



@end

extern NSString * CKAccessibilityNameForColoredPiece(CCColoredPiece piece);
extern NSString * CKAccessibilityNameForPiece(CCPiece piece);
extern NSString * CKAccessibilityNameForGameTree(CKGameTree *tree);