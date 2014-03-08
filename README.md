vim\_projects
=============

Vim plugin to allow you to switch out settings based on what project you're
working on.

Not every project needs the same vim setup.  Sometimes you'll need to use tab
intents; other times you'll need spaces.  You may want to have a mapping that
inserts a php `var_dump` for one project and a `custom_dump_function` for
another.  This plugin allows you to do that without making any changes to your
vimrc when you switch projects.

Detecting the current project
=============================

Whenever you open a new buffer, the plugin will attempt to detect what project
you're working on.  First it looks for a doc block with a `@category` or
`@package` tag.  If it doesn't find a match to any project config, it checks to
see if you've set the `VIM_PROJECT` environment variable.  Finally, it looks in
the file's full path for a directory listed in any project config.

You can also set the current project yourself with `SetProject()`

Defining your projects
======================

In your vimrc, you'll need to set up a directory variable `project_info` to
tell vim what projects you have and how to detect them, e.g.:

```
let g:project_info = {
    \ 'Foo' : {
    \   'directory' : [ 'foo1', 'foo2' ],
    \   'package'   : 'Foo',
    \},
    \ 'Bar' : {
    \   'directory' : [ 'bar' ],
    \   'category'  : 'Bar',
    \},
\}
```

Create a subdirectory called `projects` in your `~/.vim/`, and for each
project, create a file named after the project.  This file will be loaded only
once, when the project is first detected or set manually.

Event functions
===============

You can set up vim functions to be called upon load, entering a buffer, and
exiting a buffer.  Just indicate the function to be called, e.g. in `~/.vim/projects/Foo.vim`:

```
let g:project_info['Foo']['enter_func'] = 'g:Project_Enter_Foo'
fun! g:Project_Enter_Foo()
    set noexpandtab
    set shiftwidth=4
    set tabstop=4
    set softtabstop=0
endfun
```

Here are the available hooks:

| Key          | Description                                                  |
|:------------ |:------------------------------------------------------------ |
| `init_func`  | Called once, immediately after the file is loaded            |
| `enter_func` | Called whenever you enter a buffer belonging to that project |
| `leave_func` | Called whenever you leave a buffer belonging to that project |


