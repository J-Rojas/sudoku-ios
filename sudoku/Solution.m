//
// Created by Jose Rojas on 2/1/15.
// Copyright (c) 2015 Jose Rojas. All rights reserved.
//

/*
 * Solution is the main class for solving and storing the state of a Sudoku grid. It uses a constraint-propagation
 * algorithm for traversing the Sudoku decision-tree solution space and finding a final solution.
 *
 * A 9x9 solution consists of 81 Position cells that holds the possible values and the final value of that cell that will
 * be used for the solution.
 *
 * The Solution will generate values for all cells such that:
 *   for every group that is row, column and non-overlapping 3x3 subgrid of cells contains only values of 1 through 9
 *   with no duplicate values in each group.
 *
 * A grid can be partially solved if it contains any 0 values in any of the Position cells. The Solution is solved when
 * all the Position cells are filled with a value and the constraint rule above is not violated. A Solution can be
 * invalid if any Position cell is encountered that has no possible values and has no final value assigned. This would be
 * a solution that inevitably would violate the Sudoku constraint rule if any value of 1-9 is assigned to such a cell.
 *
 * Starting with a completely unassigned grid of cells, the algorithm sorts all Position cells by the number of possible
 * values for each cell. The most constrained cell is the one with the least possible values. This cell is chosen first
 * as the candidate cell for making progress towards a completely solved puzzle.
 *
 * Randomness in the generation of the Sudoku solution is achieved by randomizing the order of the numbers 1-9 in each
 * cell (see the Position class). The possible values are then assigned to the candidate cell in order. This forces every
 * value assigned to the final value for a given cell to be as random as possible.
 *
 * After a possible value is chosen for the candidate cell, this value is assigned to the final value and then a 'reduce'
 * step is performed. The reduce step propagates the choice made by constraining all the neighboring cells that are
 * subject to the Sudoku constraint rule (all cells in the same row, column, subgrid). The constraining process involves
 * removing the chosen value from the list of all possible values in these groups. The reduce step continues while there are
 * cells in those groups with only one possible value, since this is identified as a case where no choice is possible in
 * the decision tree of converging a solution and can thus be 'flattened'.
 *
 * The Solution can be further converged by continuing these steps. This technique forces cells that have not yet been
 * assigned a value to only hold possible choices for values that do not conflict with previous assigned values in the
 * rest of the Solution. Using the most constrained cell as the first choice optimizes the search as opposed to using a
 * random cell or the least constrained cell because this cell represents the cell that will have the least probability
 * for making a conflicting choice that would lead to an invalid solution.
 *
 * In certain cases, the candidate value cannot come from the most constrained cell or the first value of the possible values
 * in a particular candidate cell. This occurs when a Solution state that would yield an invalid state if this choice is made
 * is discovered. The nextSolution: method can be called to choose the next value in the most constrained cell in this
 * particular case to continue searching for a final Solution that would not lead to an invalid state.
 *
 */

#import "Solution.h"
#import "Position.h"

@interface Solution ()

@property NSMutableArray * positions;
@property NSMutableArray * grid;
@property NSMutableArray * numbers;
@property NSUInteger popIndex;
@property NSUInteger valueIndex;

@end

@implementation Solution {
}

- (instancetype) init {
    [self generateStructs];
    return self;
}

- (instancetype)initSolutionWithArray:(NSArray *)arrayOfValues {
    self = [self init];
    
    NSUInteger i = 0;
    for (NSNumber* num in arrayOfValues) {
        Position* pos = [self positionAtIndex:i];
        pos.value = num;
        i++;
    }
    
    self = [self initSolution];
    
    return self;
}

- (instancetype) initSolution {

    //initialize the solution internal state with a given partial solution already applied in the grid

    //construct the numbers that are possible in each row
    NSMutableArray *rowValues = [NSMutableArray array];

    for (NSUInteger row = 0; row < 9; row++) {
        NSMutableSet *set = [NSMutableSet setWithArray:_numbers];

        NSArray* arrayOfPos = [self getRow:row];
        for (Position * pos in arrayOfPos) {
            if (pos.value.integerValue != 0)
                [set removeObject:pos.value];
        }

        [rowValues addObject:set];
    }

    //construct the numbers that are possible in each column
    NSMutableArray *colValues = [NSMutableArray array];

    for (NSUInteger col = 0; col < 9; col++) {
        NSMutableSet *set = [NSMutableSet setWithArray:_numbers];

        NSArray* arrayOfPos = [self getCol:col];
        for (Position * pos in arrayOfPos) {
            if (pos.value.integerValue != 0)
                [set removeObject:pos.value];
        }

        [colValues addObject:set];
    }


    //construct the numbers that are possible in each grid
    NSMutableArray *gridValues = [NSMutableArray array];

    for (NSUInteger grid = 0; grid < 9; grid++) {
        NSMutableSet *set = [NSMutableSet setWithArray:_numbers];

        NSArray* arrayOfPos = [self getGrid:(grid / 3) * 3 col: (grid % 3) * 3];
        for (Position * pos in arrayOfPos) {
            if (pos.value.integerValue != 0)
                [set removeObject:pos.value];
        }

        [gridValues addObject:set];
    }

    //gather all of the incomplete position cells and initialize the possible values
    [_positions removeAllObjects];

    for (NSUInteger i = 0; i < 81; i++) {
        Position * pos = [self positionAtIndex:i];

        [pos.possibleValues removeAllObjects];
        
        if (pos.value.integerValue == 0) {
            [_positions addObject: pos];

            NSMutableSet * set = [NSMutableSet setWithArray:_numbers];
            NSSet* rowSet = rowValues[pos.y];
            NSSet* colSet = colValues[pos.x];
            NSSet* gridSet = gridValues[(pos.y / 3) * 3 + (pos.x / 3)];

            [set intersectSet:rowSet];
            [set intersectSet:colSet];
            [set intersectSet:gridSet];

            [pos.possibleValues addObjectsFromArray:set.allObjects];

        }
    }

    //sort positions by most constrained
    [_positions sortUsingComparator:[Position comparator]];

    self.popIndex = 0;
    self.valueIndex = 0;

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
    NSUInteger i = 0;

    _popIndex = 0;
    _valueIndex = 0;
    _grid = [NSMutableArray new];
    _positions = [NSMutableArray new];
    _numbers = [NSMutableArray new];

    while (i++ < 9) {
        [_numbers addObject:@(i)];
    }

    i = 0;

    //generate the Position cells, a horizontal row at a time.
    while (i < 81) {
        Position * pos = [[Position alloc] initWithX: i % 9 Y: i / 9];
        [_positions addObject:pos];
        [_grid addObject:pos];
        i++;
    }
}

- (BOOL) nextSolution {
    //this method is called when the next most constrained cell most be chosen. The _valueIndex is incremented to choose
    // the next possible value.
    _valueIndex++;
    Position* pos = [self getMostConstrained];
    return pos != nil && pos.possibleValues.count > _valueIndex;
}

- (SolutionState) converge {

    //[self printPossibleValues];
    //[self printGrid];

    //find the most constrained position

    Position * pos = nil;
    pos = [self getMostConstrained];

    if (pos != nil) {

        assert([_grid indexOfObject:pos] != NSNotFound);

        //get a random value from it's set
        pos.value = [self generateRandomValueFromPosition:pos];

        if (pos.value.integerValue != 0) {

            [self reduce:pos];

            //NSLog(@"x: %u y: %u", pos.x, pos.y);
            assert(pos.value.integerValue != 0);

            if ([self isValid]) {
                _valueIndex = 0;
                _popIndex = 0;
                return _positions.count == 0 ? Solved : Progress;
            }
        }
    }

    return Invalid;
}

- (BOOL) isValid {
    return _positions.count == 0 || [self getMostConstrained].possibleValues.count > 0;
}

- (void) checkAscending {
    int off = (int) _positions.count - 1;
    off--;
    while (off > 0) {
        Position * pos0 = _positions[(NSUInteger) off];
        Position * pos1 = _positions[(NSUInteger) off+1];

        assert(pos0.possibleValues.count <= pos1.possibleValues.count);

        off--;

    }
}

- (void) printPossibleValues {
    NSUInteger off = 0;

    NSLog(@"Undetermined count %d", (int)_positions.count);
    while (off < _positions.count) {
        Position * pos0 = _positions[off];

        NSLog(@"Pos (%lu, %lu):  value: %@, %@", pos0.x, pos0.y, pos0.value, [pos0.possibleValues componentsJoinedByString:@","]);

        off ++;

    }
}

- (void) printGrid {
    NSUInteger off = 0;
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

        NSLog(@"%@ %@ %@ | %@ %@ %@ | %@ %@ %@",
            pos0.printableValue,
            pos1.printableValue,
            pos2.printableValue,
            pos3.printableValue,
            pos4.printableValue,
            pos5.printableValue,
            pos6.printableValue,
            pos7.printableValue,
            pos8.printableValue);

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

- (Position *) positionAtIndex: (NSUInteger) index {
    return _grid[index];
}

- (void) removePosition: (Position *) pos {
    //remove the last constrained position to make progress
    [_positions removeObject:pos];

    NSUInteger col = pos.x;
    NSUInteger row = pos.y;
    NSUInteger i = 0;

    NSArray *rowArr = [self getRow:row];
    NSArray *colArr = [self getCol:col];
    NSArray *gridArr = [self getGrid:row col:col];

    //update the constrained positions
    while (i < 9) {
        [(Position *) rowArr[i] remove:pos.value];
        [(Position *) colArr[i] remove:pos.value];
        [(Position *) gridArr[i] remove:pos.value];
        i++;
    }

    //sort positions by most constrained
    [_positions sortUsingComparator:[Position comparator]];
}

- (BOOL) isValue: (NSNumber*) value inSet: (NSArray*) arrayOfPositions {
    for (NSUInteger i = 0; i < arrayOfPositions.count; i++) {
        Position * posToTest = arrayOfPositions[i];
        if ([posToTest.value isEqualToNumber:value])
            return true;
    }

    return false;
}

- (void) reduce: (Position *) pos {

    bool bCanReduceFurther;

    do {
        if (pos != nil)
            [self removePosition:pos];

        [self checkAscending];

        bCanReduceFurther = _positions.count > 0 && ((Position *)_positions[0]).possibleValues.count == 1;

        if (bCanReduceFurther) {
            pos = _positions[0];
            pos.value = pos.possibleValues.lastObject;
        }
        
    } while (bCanReduceFurther);
}

- (NSNumber *) generateRandomValueFromPosition: (Position *) pos {

    NSMutableArray* set = pos.possibleValues;
    NSNumber *value;

    if (_valueIndex < set.count) {
        value = set[_valueIndex];
    }

    return value;
}

- (Position *) getAtX: (NSUInteger) col Y: (NSUInteger) row {
    return _grid[row * 9 + col];
}

- (NSArray*) getRow: (NSUInteger) row {
    NSMutableArray * array = [NSMutableArray new];

    NSUInteger i = 0;
    while (i < 9){
        Position * pos = _grid[row * 9 + i];
        [array addObject: pos];
        assert(pos.y == row);
        i++;
    }

    return array;
}

- (NSArray*) getCol: (NSUInteger) col {
    NSMutableArray * array = [NSMutableArray new];

    NSUInteger i = 0;
    while (i < 9){
        Position * pos = _grid[i * 9 + col];
        [array addObject: pos];
        assert(pos.x == col);
        i++;
    }

    return array;
}

- (NSArray*) getGrid: (NSUInteger) row col: (NSUInteger) col {
    NSMutableArray * array = [NSMutableArray new];

    NSUInteger i = 0, j = 0;
    NSUInteger gridOffset = ((row / 3) * 3) * 9 + ((col / 3) * 3);

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

- (BOOL)isEqual:(id)object {

    //tests if two Solutions are equal by checking if all the values of the Position cells in the Solutions are the same.
    if ([object isKindOfClass:Solution.class]) {
        Solution* solution = object;
        for (NSUInteger i = 0; i < 81; i++) {
            if (((Position*)_grid[i]).value != [solution positionAtIndex:i].value)
                return false;
        }
        return true;
    }
    return false;
}

@end