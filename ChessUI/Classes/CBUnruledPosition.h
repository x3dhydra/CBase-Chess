//
//  CBUnruledPosition.h
//  CBase Chess
//
//  Created by Austen Green on 8/30/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKMutablePosition.h"

// Position class without chess rules - for taking notation in situations where it would be illegal to include move validation
@interface CBUnruledPosition : CKPosition

@end
