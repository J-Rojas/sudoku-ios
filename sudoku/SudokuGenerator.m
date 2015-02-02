//
// Created by Jose Rojas on 12/21/14.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "SudokuGenerator.h"
#import "Solution.h"

@implementation SudokuGenerator {
    NSMutableArray * _solutionStack;
};

- (instancetype) init {
    _solutionStack = [NSMutableArray new];
    return self;
};

- (void) generateSolution {


    int i = 0;
    while (i < 1000) {

        int backTrackCount = 0;
        Solution* solution = [Solution new];
        SolutionState state = Invalid;
        [_solutionStack addObject:[solution copy]];

        do {
            state = [solution converge];
            switch (state) {
                case Solved:

                    NSLog(@"Puzzle solved!!! Backtrack count %d", backTrackCount);
                    //[solution printGrid];
                    [_solutionStack removeAllObjects];
                    break;
                case Progress:
                    [_solutionStack addObject:[solution copy]];
                    break;
                case Invalid:
                    backTrackCount++;
                    solution = [_solutionStack lastObject];
                    [_solutionStack removeLastObject];
                    [solution nextSolution];
                    break;
            }

        } while (state != Solved && _solutionStack.count > 0);

        i++;
    }

}




@end