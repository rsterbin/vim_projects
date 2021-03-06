" vim: set foldlevel=0 foldmethod=marker:

" {{{ Function: FindDocblockVariable

" Look for a particular docblock variable in the file
"
" @param  string docvar the name of the variable (e.g., 'category')
" @return string the value, if found
"
fun! g:FindDocblockVariable(docvar)
    call cursor(1, 1)
    let [foundLine, foundCol] = searchpos("@" . a:docvar, "n")
    if foundLine == 0
        return ""
    else
        let full = getline(foundLine)
        let tmp = strpart(full, foundCol + strlen(a:docvar) + 1)
        let stripped = substitute(tmp, "^\\s\\+\\|\\s\\+$", "", "g") 
        return stripped
    endif
endfun

" }}}
" {{{ Function: DetectProject

" Detect the project of the current buffer
"
" @return string the current project
"
fun! g:DetectProject()

    " set up the info if we don't have it
    if !exists("g:project_info")
        let g:project_info = {}
    endif
    if !has_key(g:project_info, "default")
        let g:project_info['default'] = {}
    endif

    " do we already have it?
    if exists("b:current_project")
        return b:current_project
    endif

    " do we have a catetory/package/subpackage?
    let category = g:FindDocblockVariable("category")
    let package = g:FindDocblockVariable("package")
    for p in keys(g:project_info)
        if has_key(g:project_info[p], 'category') && g:project_info[p]['category'] == category
            call g:SetProject(p)
            return b:current_project
        elseif has_key(g:project_info[p], 'package') && g:project_info[p]['package'] == package
            call g:SetProject(p)
            return b:current_project
        endif
    endfor

    " check the environment variable, for single-project zones
    if exists("$VIM_PROJECT") && $VIM_PROJECT != ""
        call g:SetProject($VIM_PROJECT)
        return b:current_project
    endif

    " check the path, for multiple-project working copies
    let fullpath = expand("%:p")
    for p in keys(g:project_info)
        if has_key(g:project_info[p], 'directory')
            for dir in (g:project_info[p]['directory'])
                if match(fullpath, dir) != -1
                    call g:SetProject(p)
                    return b:current_project
                endif
            endfor
        endif
    endfor

    " give up
    call g:SetProject('default')
    return b:current_project

endfun

" }}}
" {{{ Function: SetProject

" Sets the project directly
"
" @param string project the project name
"
fun! g:SetProject(project)
    let b:current_project = a:project
    let filename = '~/.vim/projects/' . b:current_project . '.vim'
    if has_key(g:project_info[b:current_project], 'loaded')
    else
        exec "source " . filename
        let g:project_info[b:current_project]['loaded'] = 1
    endif
    if has_key(g:project_info[b:current_project], 'init_func')
        try
            exec "call " . g:project_info[b:current_project]['init_func'] . "()"
        catch
        endtry
    endif
endfun

" }}}
" {{{ Function: EnterProjectBuffer

" On entering a project buffer
"
fun! g:EnterProjectBuffer()
    if !exists("b:current_project")
        call g:DetectProject()
    endif
    if has_key(g:project_info, b:current_project)
        let pinfo = g:project_info[b:current_project]
    else
        if (has_key(g:project_info, 'default'))
            let pinfo = g:project_info['default']
        else
            return
        endif
    endif
    if has_key(pinfo, 'enter_func')
        try
            exec "call " . pinfo['enter_func'] . "()"
        catch
        endtry
    endif
endfun

" }}}
" {{{ Function: LeaveProjectBuffer

" On leaving a project buffer
"
fun! g:LeaveProjectBuffer()
    if !exists("b:current_project")
        call g:DetectProject()
    endif
    if has_key(g:project_info, b:current_project)
        let pinfo = g:project_info[b:current_project]
    else
        if (has_key(g:project_info, 'default'))
            let pinfo = g:project_info['default']
        else
            return
        endif
    endif
    if has_key(pinfo, 'leave_func')
        try
            exec "call " . pinfo['leave_func'] . "()"
        catch
        endtry
    endif
endfun

" }}}

" Call DetectProject() on read
autocmd BufReadPost *.* :call g:DetectProject()
autocmd BufEnter    *.* :call g:EnterProjectBuffer()
autocmd BufLeave    *.* :call g:LeaveProjectBuffer()

