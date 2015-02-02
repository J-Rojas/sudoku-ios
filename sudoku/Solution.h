//
// Created by Jose Rojas on 2/1/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    Invalid,
    Progress,
    Solved
} SolutionState;

@interface Solution : NSObject<NSCopying>

- (SolutionState) converge;
- (void) printGrid;
- (void) nextSolution;

@end