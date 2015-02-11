//
//  ViewController.m
//  sudoku
//
//  Created by Jose Rojas on 12/21/14.
//  Copyright (c) 2014 Jose Rojas. All rights reserved.
//


#import "ViewController.h"
#import "Puzzle.h"
#import "Solution.h"
#import "Position.h"
#import "SudokuGenerator.h"

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

@interface ViewController ()

@end

@implementation ViewController {
    UISegmentedControl *_toolbar;
    UIView* _gridview;
    bool _bShowSolution;
    PuzzleDifficulty _difficulty;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _difficulty = PuzzleDifficultyEasy;


    // Do any additional setup after loading the view, typically from a nib.

    // grid view
    UIView* gridview = _gridview = [UIView new];

    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect rect = self.view.frame;
    rect.size.width -= 20;
    rect.size.width = rect.size.height / 2 < rect.size.width ? rect.size.height / 2 : rect.size.width;
    rect.size.width -= (int) rect.size.width % 9;
    rect.size.width += 2;
    rect.size.height = rect.size.width;
    rect.origin.x += (self.view.frame.size.width - rect.size.width) / 2;
    rect.origin.y += 20;

    gridview.frame = rect;

    [self.view addSubview:gridview];
    gridview.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    gridview.layer.borderColor = [UIColor blackColor].CGColor;
    gridview.layer.borderWidth = 2;

    [self newPuzzle];

    UISegmentedControl * toolbar = _toolbar = [UISegmentedControl new];

    [toolbar insertSegmentWithTitle:@"Check" atIndex:0 animated:NO];
    [toolbar insertSegmentWithTitle:@"Easy" atIndex:1 animated:NO];
    [toolbar insertSegmentWithTitle:@"Solve" atIndex:2 animated:NO];
    [toolbar insertSegmentWithTitle:@"New" atIndex:3 animated:NO];
    [toolbar addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventValueChanged];

    toolbar.frame = CGRectMake(10, gridview.frame.origin.y + gridview.frame.size.height + 10, self.view.bounds.size.width - 20, 30);
    [self.view addSubview:toolbar];

}

- (void) newPuzzle {
    SudokuGenerator * generator = [[SudokuGenerator alloc] init];
    Puzzle* puzzle = [generator generate: _difficulty];

    [puzzle.solution printGrid];
    [puzzle.grid printGrid];

    self.puzzle = puzzle;

    for (UIView* view in _gridview.subviews)
        [view removeFromSuperview];

    [self layoutGrid:_bShowSolution ? self.puzzle.solution : self.puzzle.grid];
    
    _gridview.alpha = 0.0;

    [UIView animateWithDuration:0.5 animations:^() {
        _gridview.alpha = 1.0f;
    }];

}

- (void) validateGrid {
    for (UIView* view in _gridview.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField * textField = (UITextField *) view;
            int tag = view.tag;

            UIColor * color = [_puzzle.grid positionAtIndex:tag].value == [_puzzle.solution positionAtIndex:tag].value ?
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

    int sizeOfSquares = (rect.size.width - 2) / 9;
    //rows
    for (int i = 0; i < 9; i++) {
        //cols
        for (int j = 0; j < 9; j++) {

            UITextField * label = nil;
            
            Position * pos = [solutionToShow getAtX:j Y:i];
            
            NSString* num = pos.value.stringValue;
            
            if (pos.value.integerValue != 0 && !pos.temporary) {
                label = [UILabel new];
                label.text = pos.value.stringValue;
                label.textColor = [UIColor darkGrayColor];

            } else {
                pos.temporary = YES;
                label = [UITextField new];
                if (pos.value.integerValue != 0)
                    label.text = pos.value.stringValue;
                label.textColor = [UIColor blackColor];
                UIFontDescriptor * fontD = [label.font.fontDescriptor
                    fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold
                        | UIFontDescriptorTraitItalic];
                label.font = [UIFont fontWithDescriptor: fontD size:label.font.pointSize + 2];
                label.keyboardType = UIKeyboardTypeNumberPad;
                label.clearsOnBeginEditing = true;
                label.delegate = self;

                [label addTarget:self
                          action:@selector(textFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
            }
            label.tag = i * 9 + j;
            label.textAlignment = NSTextAlignmentCenter;

            rect = CGRectMake(j * sizeOfSquares, i * sizeOfSquares, sizeOfSquares + 2, sizeOfSquares + 2);
            label.frame = rect;

            label.layer.borderColor = [UIColor lightGrayColor].CGColor;
            label.layer.borderWidth = 2;

            [gridview addSubview:label];
        }
    }

    //draw 4 views to represent grid lines
    UIView* line = [UILabel new];

    rect = CGRectMake(0, sizeOfSquares * 3, sizeOfSquares * 9 + 2, 2);
    line.frame = rect;
    line.layer.backgroundColor = [UIColor blackColor].CGColor;

    [gridview addSubview:line];

    line = [UILabel new];
    rect = CGRectMake(0, sizeOfSquares * 6, sizeOfSquares * 9 + 2, 2);
    line.frame = rect;
    line.layer.backgroundColor = [UIColor blackColor].CGColor;

    [gridview addSubview:line];

    line = [UILabel new];
    rect = CGRectMake(sizeOfSquares * 3, 0, 2, sizeOfSquares * 9 + 2);
    line.frame = rect;
    line.layer.backgroundColor = [UIColor blackColor].CGColor;

    [gridview addSubview:line];

    line = [UILabel new];
    rect = CGRectMake(sizeOfSquares * 6, 0, 2, sizeOfSquares * 9 + 2);
    line.frame = rect;
    line.layer.backgroundColor = [UIColor blackColor].CGColor;

    [gridview addSubview:line];

}

- (void) textFieldDidChange: (UITextField*) field {
    //update the user grid
    int index = field.tag;

    [_puzzle.grid positionAtIndex:index].value = [NSNumber numberWithInt:field.text.integerValue];
    field.textColor = [UIColor blackColor];
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
            //new puzzle
            [self newPuzzle];

            break;

    }
    control.selectedSegmentIndex = -1;

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //difficulty level was chosen
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

    [self newPuzzle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([textField.text length] >= 0)
    {
        [textField deleteBackward];
    }

    return YES;
}

@end