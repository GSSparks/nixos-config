{ pkgs, ... }:
{
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    ((vim-full.override {  }).customize{
      name = "vim";
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [ vim-nix vim-lastplace nerdtree vim-polyglot vim-gitgutter vim-fugitive YouCompleteMe supertab gruvbox-material vim-airline vim-airline-themes ];
        opt = [];
      };
      vimrcConfig.customRC = ''
        set nocompatible
        filetype on
        filetype plugin on
        filetype indent on
        syntax on
        set number
        set cursorline
        set shiftwidth=4
        set tabstop=4
        set expandtab
        set nobackup
        set scrolloff=10
        set nowrap
        set incsearch
        set ignorecase
        set smartcase
        set showcmd
        set showmode
        set showmatch
        set hlsearch
        set history=1000
        set mouse=a
        set clipboard=unnamedplus
        vmap <C-c> "+yi
        vmap <C-x> "+c
        vmap <C-v> c<ESC>"+p
        imap <C-v> <C-r><C-o>+
        nnoremap <F2> :NERDTreeToggle<CR>
        let NERDTreeShowHidden=1
        if has('termguicolors')
          set termguicolors
        endif
        set background=dark
        let g:gruvbox_material_background = 'hard'
        let g:gruvbox_material_better_performance = 1
        colorscheme gruvbox-material
        hi Normal ctermbg=NONE guibg=NONE
        hi NonText ctermbg=NONE guibg=NONE
        set spell spelllang=en_us
        hi clear SpellBad
        hi SpellBad cterm=underline
        augroup vimrc
          autocmd BufRead,BufWrite * if ! &bin && &filetype != "diff" | silent! %s/\s\+$//ge | endif
        augroup END
        let g:airline_theme='gruvbox_material'
        let g:airline_powerline_fonts = 1
        if !exists('g:airline_symbols')
            let g:airline_symbols = {}
        endif
        let g:airline_left_sep = '»'
        let g:airline_left_sep = '▶'
        let g:airline_right_sep = '«'
        let g:airline_right_sep = '◀'
        let g:airline_symbols.linenr = '␊'
        let g:airline_symbols.linenr = '␤'
        let g:airline_symbols.linenr = '¶'
        let g:airline_symbols.branch = '⎇'
        let g:airline_symbols.paste = 'ρ'
        let g:airline_symbols.paste = 'Þ'
        let g:airline_symbols.paste = '∥'
        let g:airline_symbols.whitespace = 'Ξ'
        let g:airline_left_sep = '''
        let g:airline_left_alt_sep = '''
        let g:airline_right_sep = '''
        let g:airline_right_alt_sep = '''
        let g:airline_symbols.branch = '''
        let g:airline_symbols.readonly = '''
        let g:airline_symbols.linenr = '''
      '';
    }
  )];
}
