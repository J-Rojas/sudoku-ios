//
// Created by Jose Rojas on 2/1/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "Solution.h"
#import "Position.h"

@interface Solution ()

@property NSMutableArray * positions;
@property NSMutableArray * grid;
@property NSMutableArray * numbers;
@property int popIndex;
@property int valueIndex;

@end

@implementation Solution {
}

- (instancetype) init {
    [self generateStructs];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    Solution * newSelf = [Solution new];
    newSelf.grid = [[NSMutableArray alloc]initWithArray:_grid copyItems:YES];
    newSelf.numbers = [[NSMutableArray alloc]initWithArray:_numbers copyItems:YES];
    newSelf.positions = [NSMutableArray new];

    //resolve the positions from the new grid
    for (Position * p in _positions) {
        [newSelf.positions addObject:[newSelf getAtX:p.x Y:p.y]];
    }

    newSelf.popIndex = _popIndex;
    newSelf.valueIndex = _valueIndex;

    return newSelf;
}

- (void) generateStructs {
    int i = 0;

    _popIndex = 0;
    _valueIndex = 0;
    _grid = [NSMutableArray new];
    _positions = [NSMutableArray new];
    _numbers = [NSMutableArray new];

    while (i++ < 9) {
        [_numbers addObject:[NSMutableArray new]];
    }

    i = 0;
    while (i < 81) {
        Position * pos = [[Position alloc] initWithX: i % 9 Y: i / 9];
        [_positions addObject:pos];
        [_grid addObject:pos];
        for (int j = 0; j < 9; j++) {
            [(NSMutableArray*)_numbers[j] addObject:pos];
        }
        i++;
    }
}

NSComparator comparator = ^NSComparisonResult(Position *pos1, Position *pos2) {
    if (pos1.possibleValues.count < pos2.possibleValues.count)
        return NSOrderedAscending;
    else if (pos1.possibleValues.count == pos2.possibleValues.count) {
        return NSOrderedSame;
    } else
        return NSOrderedDescending;
};

- (void) nextSolution {
    if ([self getMostConstrained]) {
        _valueIndex++;
    };
}

- (SolutionState) converge {

    //[self printPossibleValues];
    //[self printGrid];

    //find the most constrained position

    Position * pos = nil;
    do {
        pos = [self getMostConstrained];

        if (pos != nil) {

            assert([_grid indexOfObject:pos] != NSNotFound);

            //get a random value from it's set
            pos.value = [self generateRandomValueFromPosition:pos];

            if (pos.value != nil) {

                [self reduce:pos value:pos.value];

                //NSLog(@"x: %d y: %d", pos.x, pos.y);
                assert(pos.value != 0);

                return _positions.count == 0 ? Solved : Progress;
            }

            //NSLog(@"Dead end encountered!");

            return Invalid;
        }

        //no more random possibilities, move on to next most constrained
        _valueIndex = 0;
        _popIndex++;

    } while (pos != nil);

    return Invalid;

    //[self printGrid];

}

- (int) getNumberConstraint: (int) number {
    return ((NSMutableArray *)_numbers[number - 1]).count;
}

- (void) checkAscending {
    int off = _positions.count - 1;
    off--;
    while (off > 0) {
        Position * pos0 = _positions[off];
        Position * pos1 = _positions[off+1];

        assert(pos0.possibleValues.count <= pos1.possibleValues.count);

        off--;

    }
}

- (void) printPossibleValues {
    int off = 0;

    NSLog(@"Undetermined count %d", _positions.count);
    while (off < _positions.count) {
        Position * pos0 = _positions[off];

        NSLog(@"Pos (%d, %d):  value: %@, %@", pos0.x, pos0.y, pos0.value, [pos0.possibleValues componentsJoinedByString:@","]);

        off ++;

    }
}

- (void) printGrid {
    int off = 0;
    while (off < 81) {
        Position * pos0 = _grid[off+0];
        Position * pos1 = _grid[off+1];
        Position * pos2 = _grid[off+2];
        Position * pos3 = _grid[off+3];
        Position * pos4 = _grid[off+4];
        Position * pos5 = _grid[off+5];
        Position * pos6 = _grid[off+6];
        Position * pos7 = _grid[off+7];
        Position * pos8 = _grid[off+8];

        NSLog(@"%@ %@ %@ | %@ %@ %@ | %@ %@ %@", pos0.value, pos1.value, pos2.value, pos3.value, pos4.value, pos5.value, pos6.value, pos7.value, pos8.value);

        off += 9;
        if (off == 27 || off == 54)
            NSLog(@"---------------------");
    }
    NSLog(@"\n");
}

- (Position *) getMostConstrained {
    Position * retval = nil;
    if (_popIndex < _positions.count) {
        retval = _positions[_popIndex];
    }
    return retval;
}

- (void) reduce: (Position *) pos value: (NSNumber *) value {

    bool bCanReduceFurther = false;

    do {
        //remove the last constrained position to make progress
        [_positions removeObject:pos];

        int col = pos.x;
        int row = pos.y;
        int i = 0;

        NSArray *rowArr = [self getRow:row];
        NSArray *colArr = [self getCol:col];
        NSArray *gridArr = [self getGrid:row col:col];

        //update the constrained positions
        while (i < 9) {
            [(Position *) rowArr[i] remove:value];
            [(Position *) colArr[i] remove:value];
            [(Position *) gridArr[i] remove:value];
            i++;
        }

        //sort positions by most constrained
        [_positions sortUsingComparator:comparator];

        [self checkAscending];

        bCanReduceFurther = _positions.count > 0 && ((Position *)_positions[0]).possibleValues.count == 1;

        if (bCanReduceFurther) {
            pos = _positions[0];
            value = pos.value = pos.possibleValues.lastObject;
        }

    } while (bCanReduceFurther);
}

- (NSNumber *) generateRandomValueFromPosition: (Position *) pos {

    NSMutableArray* set = pos.possibleValues;
    NSNumber *value;

    /*
    //choose the most constrained number. This is equivalent to ensuring the other numbers in the set can be placed
    // somewhere else safely without violating constraints.
    int i = 0;
    int mostConstrainedCount = 82;
    NSNumber *value;
    for (NSNumber * item in set) {
        if (((NSMutableArray *)_numbers[item.integerValue - 1]).count < mostConstrainedCount) {
            mostConstrainedCount = ((NSMutableArray *)_numbers[item.integerValue - 1]).count;
            value = item;
        }
    }

    if (value != nil) {
    */
    if (_valueIndex < set.count) {
        value = [set objectAtIndex:_valueIndex];
    }
    /*} else {
        i = i;
    }

    NSMutableArray * numberPositions = _numbers[value.integerValue - 1];
    */


    return value;
}

- (Position *) getAtX: (int) col Y: (int) row {
    return _grid[row * 9 + col];
}

- (NSArray*) getRow: (int) row {
    NSMutableArray * array = [NSMutableArray new];

    int i = 0;
    while (i < 9){
        Position * pos = _grid[row * 9 + i];
        [array addObject: pos];
        assert(pos.y == row);
        i++;
    }

    return array;
}

- (NSArray*) getCol: (int) col {
    NSMutableArray * array = [NSMutableArray new];

    int i = 0;
    while (i < 9){
        Position * pos = _grid[i * 9 + col];
        [array addObject: pos];
        assert(pos.x == col);
        i++;
    }

    return array;
}

- (NSArray*) getGrid: (int) row col: (int) col {
    NSMutableArray * array = [NSMutableArray new];

    int i = 0, j = 0;
    int gridOffset = ((row / 3) * 3) * 9 + ((col / 3) * 3);

    while (i < 3){
        j = 0;
        while (j < 3) {
            Position * pos = _grid[gridOffset + (i * 9) + j];

            [array addObject:pos];
            j++;
        }
        i++;
    }

    return array;
}

@end