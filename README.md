# stack-todo

A set of stack todoish shell functions based on
<https://medium.com/curious/why-most-productivity-techniques-dont-work-as-intended-667f1d994dcc>

## Configuration

In your shell config rc, source the stack.sh file from this repo.

## Usage

### st-show

Show the current todo item.

### st-push

Push a new todo on the stack. The first element of the todo
should be a time estimate in minutes.

### st-shift

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
