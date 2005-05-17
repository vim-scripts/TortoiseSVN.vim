" TortoiseSVN.vim - Support for TortoiseSVN (a subversion client for Windows)
" @Author:      Thomas Link (mailto:samul@web.de?subject=vim-TortoiseSVN)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     13-Mai-2005.
" @Last Change: 16-Mai-2005.
" @Revision:    0.1.56

if &cp || exists("loaded_tortoisesvn")
    finish
endif
let loaded_tortoisesvn = 1

if !exists('g:tortoiseSvnCmd')
    if &shell =~ 'sh'
        let g:tortoiseSvnCmd = '/cygdrive/c/Programme/TortoiseSVN/bin/TortoiseProc.exe'
    " elseif &shell =~ '\(cmd\|command|)'
    else
        let g:tortoiseSvnCmd = 'C:\Programme\TortoiseSVN\bin\TortoiseProc.exe'
    endif
    " let g:tortoiseSvnCmd = 'TortoiseProc.exe'
endif

if !exists('g:tortoiseSvnInstallAutoCmd')
    let g:tortoiseSvnInstallAutoCmd = 1
endif

if !exists('g:tortoiseSvnDebug')
    let g:tortoiseSvnDebug = 0
endif

if !exists('g:tortoiseSvnCommitOnce')
    let g:tortoiseSvnCommitOnce = 0
endif

if !exists('g:tortoiseSvnMenuPrefix')
    let g:tortoiseSvnMenuPrefix = 'Plugin.&TortoiseSVN.'
endif

if !exists('g:tortoiseSvnStartCmd')
    if &shell =~ 'sh'
        let g:tortoiseSvnStartCmd = 'cygstart'
    " elseif &shell =~ '\(cmd\|command|)'
    else
        let g:tortoiseSvnStartCmd = 'start'
    endif
endif

fun! <SID>GetCmdLine(command)
    if isdirectory('.svn') && bufname('%') != ''
        let fn  = substitute(expand('%:p'), '[/\\]', '\\\\', 'g')
        " let fn  = expand('%')
        let cmd = g:tortoiseSvnCmd ." /command:". a:command ." /path:'". fn ."' /notempfile /closeonend"
        return cmd
    else
        return ''
    endif
endf

fun! <SID>ExecCommand(cmd)
    if g:tortoiseSvnDebug
        exec '! '. a:cmd
    else
        silent exec '! '. g:tortoiseSvnStartCmd .' '. a:cmd
    endif
endf

" TortoiseExec(command, ?extra_arguments)
fun! TortoiseExec(command, ...)
    let cmd = <SID>GetCmdLine(a:command)
    if cmd != ''
        if a:0 >= 1
            let extra = a:1
            let cmd   = cmd .' '. extra
        endif
        call <SID>ExecCommand(cmd)
    endif
endf

fun! TortoiseSvnMaybeCommitCurrentBuffer()
    if !exists('b:tortoiseSvnCommittedOnce')
        " " Adding a log message make TortoiseSVN crash here on my computer
        " if exists('*TortoiseSvnLogMsg')
        "     let msg = substitute(TortoiseSvnLogMsg(), '[@"\\]', '_', 'g')
        "     let cmd = cmd ." /logmsg:'". msg. "'"
        " endif
        call TortoiseExec('commit')
        if g:tortoiseSvnCommitOnce || 
                    \ (exists('b:tortoiseSvnCommitOnce') && b:tortoiseSvnCommitOnce)
            let b:tortoiseSvnCommittedOnce = 1
        endif
    endif
endf

command! TortoiseSvnRevisionGraph :call TortoiseExec('revisiongraph')
command! TortoiseSvnBrowser       :call TortoiseExec('repobrowser')
command! TortoiseSvnLog           :call TortoiseExec('log')
command! TortoiseSvnCheckout      :call TortoiseExec('checkout')
command! TortoiseSvnUpdate        :call TortoiseExec('update', '/rev')
command! TortoiseSvnCommit        :call TortoiseSvnMaybeCommitCurrentBuffer()

if g:tortoiseSvnMenuPrefix != ''
    exec 'amenu '. g:tortoiseSvnMenuPrefix .'&Browser         :TortoiseSvnBrowser<cr>'
    exec 'amenu '. g:tortoiseSvnMenuPrefix .'Check&out        :TortoiseSvnCheckout<cr>'
    exec 'amenu '. g:tortoiseSvnMenuPrefix .'&Commit          :TortoiseSvnUpdate<cr>'
    exec 'amenu '. g:tortoiseSvnMenuPrefix .'&Log             :TortoiseSvnLog<cr>'
    exec 'amenu '. g:tortoiseSvnMenuPrefix .'Revision\ &Graph :TortoiseSvnRevisionGraph<cr>'
    exec 'amenu '. g:tortoiseSvnMenuPrefix .'&Update          :TortoiseSvnUpdate<cr>'
endif

if g:tortoiseSvnInstallAutoCmd
    autocmd BufWritePost * TortoiseSvnCommit
    let g:tortoiseSvnInstallAutoCmd = 0
endif

