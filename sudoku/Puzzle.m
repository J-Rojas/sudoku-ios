//
// Created by Jose Rojas on 2/7/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

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

    int numbersToRemove = _difficulty + arc4random_uniform(3);

    NSMutableArray *available = [NSMutableArray new];

    for (int i = 0; i < 81; i++) {
        [available addObject:@(i)];
    }

    while (numbersToRemove > 0) {
        int index = arc4random_uniform(available.count);
        NSNumber * gridpos = [available objectAtIndex:index];
        [available removeObjectAtIndex:index];

        Position* pos = [_grid positionAtIndex:gridpos.integerValue];
        [_grid erasePosition:pos];

        numbersToRemove--;
    }
}

@end