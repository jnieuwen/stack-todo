# stack-todo

A set of stack todoish shell functions based on
<https://medium.com/curious/why-most-productivity-techniques-dont-work-as-intended-667f1d994dcc>

## Configuration

In your shell config rc, source the stack.sh file from this repo.

## Usage

### st-show

Show the current todo item.

### st-push / st-top

Push a new todo on the stack. The first element of the todo
should be a time estimate in minutes.

### st-shift / st-bottom

Put a todo at the bottom of the stack. The first element of the todo
should be a time estimate in minutes.

### st-next

Put a todo directly below the todo at the top of the stack. The first element
of the todo should be a time estimate in minutes.

### st-pop

Mark the current todo as done and show the new current one.

### st-rev

Reverse the order of the stack. This is handy when you start with an empty list
and add the most important one first then the next etc. And than want to start
working with the most important one first.

### st-dump

Dump the complete stack of todo's.

### st-clear

Clear the complete stack of todo's.

### st-finish

Show the expected end time of all items on the stack.

### st-edit

Open the todo file in an editor

### st-bury

Bury the item at the top of the stack at the bottom. Added to help politicians
out.

### st-file

Put the items from "file" on top of the stack. Starting with adding the first
line, than the second etc. So the last line of the file ends up on top of the
stack.

### st-swap

Switch the order of the first 2 items on top of the stack.
