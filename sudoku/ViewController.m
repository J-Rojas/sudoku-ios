//
//  ViewController.m
//  sudoku
//
//  Created by Jose Rojas on 12/21/14.
//  Copyright (c) 2014 Jose Rojas. All rights reserved.
//

/*
 * The ViewController generates all of the UI for the application.  The Sudoku game board is programatically generated so that it
 * can be easily resized. Its dimensions are dynamically calculated so that the game board is one half the height of the screen
 * so that it is not obscured by the soft keyboard.
 *
 * This class relies on the SudokuGenerator, Puzzle, Solution, and Position classes to generate a new Sudoku puzzle,
 * display its contents, and validate the results.
 *
 * The #define are here for educational purposes. I've used them to demonstrate the different aspects of programmatic UI
 * development.
 *
 * The game board consists of 81 cells that each contain a UILabel or UITextView. When a new puzzle is generated, if the
 * value of the puzzle cell is 0, a UITextView is used, otherwise a UILabel is used. This allows cells that immutable
 * in the puzzle to not be edited, while those that are mutable can be selected and have their values changed by the
 * user.
 *
 * A UISegmentedControl is dynamically placed underneath the grid to act as a simple menu system. The user can create
 * a new puzzle, change the game difficulty, show the solution, or validate their current game state against the
 * solution.
 *
 */

#import "ViewController.h"
#import "Puzzle.h"
#import "Solution.h"
#import "Position.h"
#import "SudokuGenerator.h"

#define SHOW_GRIDVIEW
#define SHOW_PUZZLE
#define SHOW_NUMBERS
#define TEXT_COLOR
#define ENABLE_TEXT_FILTERING
#define SHOW_TOOLBAR
#define ENABLE_ANIMATIONS

@interface ViewController ()

@end

@implementation ViewController {
    UISegmentedControl *_toolbar;
    UIView* _gridview;
    bool _bShowSolution;
    PuzzleDifficulty _difficulty;
    SudokuGenerator * _generator;
}

/* The view controller loads all initial UI here */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _difficulty = PuzzleDifficultyEasy;
    _generator = [[SudokuGenerator alloc] init];

    // Do any additional setup after loading the view, typically from a nib.

    // grid view
#ifdef SHOW_GRIDVIEW
    [self createGridView];
#endif
    
#ifdef SHOW_PUZZLE
    [self newPuzzle];
#endif

#ifdef SHOW_TOOLBAR
    [self createToolbar];
#endif
}

- (void) createGridView {
    UIView* gridview = _gridview = [UIView new];
    
    CGRect rect = self.view.frame;
    rect.size.width -= 20;
    rect.size.width = rect.size.height / 2 < rect.size.width ? rect.size.height / 2 : rect.size.width;
    rect.size.width -= (int) rect.size.width % 9;
    rect.size.width += 2;
    rect.size.height = rect.size.width;
    rect.origin.x += (self.view.frame.size.width - rect.size.width) / 2;
    rect.origin.y += 20;
    
    gridview.frame = rect;
    gridview.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    gridview.layer.borderColor = [UIColor blackColor].CGColor;
    gridview.layer.borderWidth = 2;
    
    [self.view addSubview:gridview];

}

- (void) createToolbar {
    UISegmentedControl * toolbar = _toolbar = [UISegmentedControl new];
    
    [toolbar insertSegmentWithTitle:@"Check" atIndex:0 animated:NO];
    [toolbar insertSegmentWithTitle:@"Easy" atIndex:1 animated:NO];
    [toolbar insertSegmentWithTitle:@"Solve" atIndex:2 animated:NO];
    [toolbar insertSegmentWithTitle:@"New" atIndex:3 animated:NO];
    [toolbar addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventValueChanged];
    
    toolbar.frame = CGRectMake(10, _gridview.frame.origin.y + _gridview.frame.size.height + 10, self.view.bounds.size.width - 20, 30);
    [self.view addSubview:toolbar];

}

- (void) newPuzzle {
    [self newPuzzleWithSolution:nil];
}

- (void) newPuzzleWithSolution: (Solution *) solution {
    Puzzle* puzzle = nil;

    if (solution == nil)
        puzzle = [_generator generate: _difficulty];
    else
        puzzle = [_generator generatePuzzleWithSolution:solution difficulty:_difficulty];

    [puzzle.solution printGrid];
    [puzzle.grid printGrid];

    self.puzzle = puzzle;

    for (UIView* view in _gridview.subviews)
        [view removeFromSuperview];

    [self layoutGrid:_bShowSolution ? self.puzzle.solution : self.puzzle.grid];

    // Do animations
#ifdef ENABLE_ANIMATIONS
    _gridview.alpha = 0.0;

    [UIView animateWithDuration:0.5 animations:^() {
        _gridview.alpha = 1.0f;
    }];
#endif
}

- (void) validateGrid {
    for (UIView* view in _gridview.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField * textField = (UITextField *) view;
            int tag = (int) view.tag;

            UIColor * color = [_puzzle.grid positionAtIndex:tag].value.integerValue ==
                              [_puzzle.solution positionAtIndex:tag].value.integerValue ?
                [UIColor blackColor] :
                [UIColor redColor]
            ;

            textField.textColor = color;
        }
    }
}

- (void) layoutGrid: (Solution*) solutionToShow {

    UIView* gridview = _gridview;
    CGRect rect = _gridview.frame;

    //determine the width/height of the grid items
    CGFloat sizeOfSquares = (rect.size.width - 2) / 9;
    
    //rows
    for (int i = 0; i < 9; i++) {
        //cols
        for (int j = 0; j < 9; j++) {

            UILabel * label = nil;

#ifndef SHOW_NUMBERS
            label = [self generateLabel: [Position new]];
#else
            //generate a grid item based on the data in the grid
            Position * pos = [solutionToShow getAtX:j Y:i];
            
            if (pos.value.integerValue != 0 && !pos.temporary) {
                label = [self generateLabel: pos];
            } else {
                label = [self generateTextField: pos];
            }
#endif
            
            //mark the grid item with a number for tracking purposes
            label.tag = i * 9 + j;
            
            //center align all the text in the grid item
            label.textAlignment = NSTextAlignmentCenter;

            //Set up the position and boundary for each grid item
            rect = CGRectMake(j * sizeOfSquares, i * sizeOfSquares,
                              sizeOfSquares + 2, sizeOfSquares + 2);
            label.frame = rect;
            
            //set up the colors for the grid item
            label.layer.borderColor = [UIColor lightGrayColor].CGColor;
            label.layer.borderWidth = 2;

            //add the grid item to the parent gridview
            [gridview addSubview:label];
        }
    }

    //draw 4 views to represent grid lines
    [self drawGridLines: rect sizeOfSquares:(int) sizeOfSquares];
}

- (UILabel*) generateLabel: (Position*) pos {
    UILabel* label = [UILabel new];
    label.text = pos.value.stringValue;
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

- (UITextField*) generateTextField: (Position*) pos {
    pos.temporary = YES;
    UITextField* label = [UITextField new];
    if (pos.value.integerValue != 0)
        label.text = pos.value.stringValue;
    
#ifndef TEXT_COLOR
    label.textColor = [UIColor darkGrayColor];
#else
    //Change font size for editable text
    label.textColor = [UIColor blackColor];
    UIFontDescriptor * fontD = [label.font.fontDescriptor
                            fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold
                            | UIFontDescriptorTraitItalic];
    label.font = [UIFont fontWithDescriptor: fontD size:label.font.pointSize + 2];
#endif
    
    label.keyboardType = UIKeyboardTypeNumberPad;
    label.clearsOnBeginEditing = true;
    label.delegate = self;

    [label addTarget:self
              action:@selector(textFieldDidChange:)
    forControlEvents:UIControlEventEditingChanged];
     
    
    return label;
}

- (void) drawGridLines: (CGRect) rect sizeOfSquares: (int) sizeOfSquares {
    UIView* line = [UILabel new];
    
    rect = CGRectMake(0, sizeOfSquares * 3, sizeOfSquares * 9 + 2, 2);
    line.frame = rect;
    line.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    [_gridview addSubview:line];
    
    line = [UILabel new];
    rect = CGRectMake(0, sizeOfSquares * 6, sizeOfSquares * 9 + 2, 2);
    line.frame = rect;
    line.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    [_gridview addSubview:line];
    
    line = [UILabel new];
    rect = CGRectMake(sizeOfSquares * 3, 0, 2, sizeOfSquares * 9 + 2);
    line.frame = rect;
    line.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    [_gridview addSubview:line];
    
    line = [UILabel new];
    rect = CGRectMake(sizeOfSquares * 6, 0, 2, sizeOfSquares * 9 + 2);
    line.frame = rect;
    line.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    [_gridview addSubview:line];

}

- (void) textFieldDidChange: (UITextField*) field {
    //update the user grid
    NSInteger index = field.tag;

    [_puzzle.grid positionAtIndex: index].value = @(field.text.integerValue);
    
#ifndef TEXT_COLOR
    field.textColor = [UIColor darkGrayColor];
#else
    field.textColor = [UIColor blackColor];
#endif
}

- (void) buttonTouch: (UISegmentedControl*) control {

    UIActionSheet * menu = nil;
    switch (control.selectedSegmentIndex) {
        case 0:
            [self validateGrid];
            break;
        case 1:
            //show level action sheet
            menu = [UIActionSheet new];

            menu.title = @"Select Difficulty";
            menu.delegate = self;
            [menu addButtonWithTitle:@"Easy"];
            [menu addButtonWithTitle:@"Medium"];
            [menu addButtonWithTitle:@"Hard"];

            [menu showInView:self.view];

            break;
        case 2:
            _bShowSolution = !_bShowSolution;
            [_toolbar setTitle: _bShowSolution ? @"Hide" : @"Solve" forSegmentAtIndex:2];

            for (UIView* view in _gridview.subviews)
                [view removeFromSuperview];

            [self layoutGrid:_bShowSolution ? self.puzzle.solution : self.puzzle.grid];
            break;
        case 3:
            //new puzzle with the same solution
            _bShowSolution = false;
            [self newPuzzle];

            break;

    }
    control.selectedSegmentIndex = -1;

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //difficulty level was chosen
    PuzzleDifficulty difficulty = _difficulty;

    switch (buttonIndex) {
        case 0:
            _difficulty = PuzzleDifficultyEasy;
            [_toolbar setTitle:@"Easy" forSegmentAtIndex:1];
            break;
        case 1:
            _difficulty = PuzzleDifficultyMedium;
            [_toolbar setTitle:@"Medium" forSegmentAtIndex:1];
            break;
        case 2:
            _difficulty = PuzzleDifficultyHard;
            [_toolbar setTitle:@"Hard" forSegmentAtIndex:1];
            break;
    }

    if (difficulty != _difficulty)
        [self newPuzzleWithSolution:_puzzle.solution];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#ifdef ENABLE_TEXT_FILTERING
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"0"]) {
        textField.text = nil;
        return NO;
    }
    
    [textField deleteBackward];
    return YES;
}
#endif

@end

void drawLine(int x1, int y1, int x2, int y2) {
    /* Get the current graphics context */
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(currentContext, [UIColor blackColor].CGColor);
    
    /* Set the width for the line */
    CGContextSetLineWidth(currentContext, 2.0f);
    /* Start the line at this point */
    CGContextMoveToPoint(currentContext, x1, y1);
    /* And end it at this point */
    CGContextAddLineToPoint(currentContext, x2, y2);
    /* Use the context's current color to draw the line */
    CGContextStrokePath(currentContext);
}
