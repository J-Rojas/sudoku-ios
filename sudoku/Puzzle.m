//
// Created by Jose Rojas on 2/7/15.
// Copyright (c) 2015 Jose Rojas. All rights reserved.
//

/*
 *  Puzzle contains a fully complete Sudoku Solution and also a partial Solution that is based on the complete Solution.
 *  This allows a client class to quickly validate a partial solution against the computed complete solution.
 *
 *  Puzzle can generate a partially filled Solution from a complete Solution using a PuzzleDifficulty setting.
 *  The algorithm for generating the partially complete Solution is simple: it unassigns a certain number of
 *  randomly chosen cells of the complete Sudoku
 */

#import "Puzzle.h"
#import "Solution.h"
#import "Position.h"


@implementation Puzzle {

}

- (instancetype)initWithSolution:(Solution *)solution difficulty: (PuzzleDifficulty) difficulty {
    self = [super init];

    _solution = solution;
    _grid = [solution copy];
    _difficulty = difficulty;

    [self generate];

    return self;
}

- (void) generate {

    //generate a partial solution based on the complete solution

    //number of cells to unassign based on the difficult setting, the more difficult, the more cells removed
    int numbersToRemove = _difficulty + arc4random_uniform(3);

    NSMutableArray *available = [NSMutableArray new];

    for (int i = 0; i < 81; i++) {
        [available addObject:@(i)];
    }

    //unassign Position cells by randomly choosing cells and calling erasePosition:
    while (numbersToRemove > 0) {
        NSUInteger index = arc4random_uniform((uint32_t)available.count);
        NSNumber * gridpos = available[index];
        [available removeObjectAtIndex:index];

        Position* pos = [_grid positionAtIndex:gridpos.unsignedIntegerValue];
        [self erasePosition:pos];

        numbersToRemove--;
    }

    //initialize the partial solution
    [_grid initSolution];
}

- (void) erasePosition: (Position *) pos {

    pos.value = @(0);

}


@end