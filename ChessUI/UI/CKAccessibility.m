//
//  CKAccessibility.m
//  ChessUI
//
//  Created by Austen Green on 7/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKAccessibility.h"

@implementation CKAccessibility

@end

NSString * CKAccessibilityNameForColoredPiece(CCColoredPiece pieceType)
{
    NSString *piece = nil;
    
    switch (pieceType) {
        case WP:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_WP", @"Accessible name for White Pawn");
            break;
        case BP:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_BP", @"Accessible name for Black Pawn");
            break;
        case WN:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_WN", @"Accessible name for White Knight");
            break;
        case BN:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_BN", @"Accessible name for Black Knight");
            break;
        case WB:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_WB", @"Accessible name for White Bishop");
            break;
        case BB:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_BB", @"Accessible name for Black Bishop");
            break;
        case WR:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_WR", @"Accessible name for White Rook");
            break;
        case BR:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_BR", @"Accessible name for Black Rook");
            break;
        case WQ:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_WQ", @"Accessible name for White Queen");
            break;
        case BQ:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_BQ", @"Accessible name for Black Queen");
            break;
        case WK:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_WK", @"Accessible name for White King");
            break;
        case BK:
            piece = NSLocalizedString(@"CK_ACCESSIBILITY_BK", @"Accessible name for Black King");
            break;
        default:
            break;
    }
    
    return piece;
}

extern NSString * CKAccessibilityNameForPiece(CCPiece piece)
{
    NSString * name = nil;
    switch (piece) {
        case PawnPiece:
            name = NSLocalizedString(@"CK_ACCESSIBILITY_PAWN", @"Accessible name for Pawn");
            break;
        case BishopPiece:
            name = NSLocalizedString(@"CK_ACCESSIBILITY_BISHOP", @"Accessible name for Bishop");
            break;
        case KnightPiece:
            name = NSLocalizedString(@"CK_ACCESSIBILITY_KNIGHT", @"Accessible name for Knight");
            break;
        case RookPiece:
            name = NSLocalizedString(@"CK_ACCESSIBILITY_ROOK", @"Accessible name for Rook");
            break;
        case QueenPiece:
            name = NSLocalizedString(@"CK_ACCESSIBILITY_QUEEN", @"Accessible name for Queen");
            break;
        case KingPiece:
            name = NSLocalizedString(@"CK_ACCESSIBILITY_KING", @"Accessible name for King");
            break;
        default:
            break;
    }
    return name;
}

extern NSString * CKAccessibilityNameForGameTree(CKGameTree *tree)
{
    if ([tree.moveString isEqualToString:@"O-O"])
        return NSLocalizedString(@"CK_ACCESSIBILITY_KINGSIDE_CASTLE", @"Accessible title for Kingside Castling");
    else if ([tree.moveString isEqualToString:@"O-O-O"])
        return NSLocalizedString(@"CK_ACCESSIBILITY_QUEENSIDE_CASTLE", @"Accessible title for Queenside Castling");
    
    NSMutableString *text = [tree.moveString mutableCopy];
    if (!text.length)
        return nil;
    
    NSString *padding = @" %@ ";
    
    // Replace the lowercase 'a' with capital 'A' since VoiceOver reads it incorrectly otherwise
    [text replaceOccurrencesOfString:@"a" withString:@"A" options:0 range:NSMakeRange(0, text.length)];
    
    [text replaceOccurrencesOfString:@"x" withString:[NSString stringWithFormat:padding, NSLocalizedString(@"CK_ACCESSIBILITY_MOVE_TAKES", @"Accessible string for \"takes\" in a move")] options:0 range:NSMakeRange(0, text.length)];
    [text replaceOccurrencesOfString:@"+" withString:[NSString stringWithFormat:padding, NSLocalizedString(@"CK_ACCESSIBILITY_MOVE_CHECK", @"Accessible string for \"check\" in a move")] options:0 range:NSMakeRange(0, text.length)];
    [text replaceOccurrencesOfString:@"x" withString:[NSString stringWithFormat:padding, NSLocalizedString(@"CK_ACCESSIBILITY_MOVE_CHECKMATE", @"Accessible string for \"checkmate\" in a move")] options:0 range:NSMakeRange(0, text.length)];
        
    unichar pieceChar = [text characterAtIndex:0];
    CCPiece piece = CCPieceMake(pieceChar);
    
    if (piece != NoPiece)
        [text replaceCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:padding, CKAccessibilityNameForPiece(piece)]];
   
    return text;
}