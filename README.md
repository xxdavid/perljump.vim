# perljump.vim
Vim plugin for jumping to Perl subroutine definitions, even when not using fully qualified names.

When I started at my job, I was frustrated when I saw a function call from some other module and that call was not fully qualified. I always had to grep that function to find the module where it was defined, then open that module and then finally search for the function. This plugin does it all for you automatically. With *perljump*, you are always only two key presses away from seeing a function definition.

## Installation
Use your favourite Vim plugin manager. For example with [vim-plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'xxdavid/perljump.vim'
```

## Configuration
To get the plugin working, you have to set one variable in your `.vimrc` (or neovim's `init.vim`). The variable is called `g:perljump_inc` and it's an array of directories containing Perl modules. For example:
```vim
let g:perljump_inc = [
 \       '/Library/Perl/5.18/darwin-thread-multi-2level',
 \       '/Library/Perl/5.18 /Network/Library/Perl/5.18/darwin-thread-multi-2level',
 \       '/Network/Library/Perl/5.18',
 \       '/Library/Perl/Updates/5.18.4',
 \       '/System/Library/Perl/5.18',
 \       '/System/Library/Perl/Extras/5.18',
 \]
```

You can use `perl -e 'print join("\n", @INC);'` to determine your Perl include directories or `perldoc -l MyModule` to find path to a particular module. You can also create the variable dynamically based on project you are in (eg. to include your project modules).

## Usage
The plugin defines two public functions `JumpToDef` and `ShowPod`. The names are pretty self-descriptive, `JumpToDef` jumps to definition of a function your cursor is on, `ShowPod` creates a split window with Perl Pod for that function.

It is useful to create mappings in your `.vimrc` for these functions, like this:
```vim
autocmd FileType perl noremap gd :call JumpToDef()<CR>
autocmd FileType perl noremap gp :call ShowPod()<CR>
```

## How does it work?
There is very simple heuristics involved in searching for the definition of a function. If the function call uses fully qualified name, then module directories are search for this module (in order of the `g:perljump_inc` array). If the call isn't fully qualified, current file is searched and if the function isn't found there, all included modules (via `use MyModule`) in the current files are searched for this function. No robust parsing is performed, only simple regex search so it doesn't have to work in all cases. Also, it probably works only with Perl 5.

## Contribute
If the plugin doesn't work in your case or you have any other improvement, feel free to submit a pull request!
