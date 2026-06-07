" Author: suoto <andre820@gmail.com>
" Description: Handling of window/* LSP methods, although right now only
" handles window/showMessage

" Constants for message type codes
let s:LSP_MESSAGE_TYPE_DISABLED = 0
let s:LSP_MESSAGE_TYPE_ERROR = 1
let s:LSP_MESSAGE_TYPE_WARNING = 2
let s:LSP_MESSAGE_TYPE_INFORMATION = 3
let s:LSP_MESSAGE_TYPE_LOG = 4

" Translate strings from the user config to a number so we can check
" severities
let s:CFG_TO_LSP_SEVERITY = {
\   'disabled': s:LSP_MESSAGE_TYPE_DISABLED,
\   'error': s:LSP_MESSAGE_TYPE_ERROR,
\   'warning': s:LSP_MESSAGE_TYPE_WARNING,
\   'information': s:LSP_MESSAGE_TYPE_INFORMATION,
\   'info': s:LSP_MESSAGE_TYPE_INFORMATION,
\   'log': s:LSP_MESSAGE_TYPE_LOG
\}

function! s:formatMessage(linter_name, message, type)
    " Get the configured severity level threshold and check if the message
    " should be displayed or not
    let l:configured_severity = tolower(get(g:, 'ale_lsp_show_message_severity', 'error'))
    " If the user has configured with a value we can't find on the conversion
    " dict, fall back to warning
    let l:cfg_severity_threshold = get(s:CFG_TO_LSP_SEVERITY, l:configured_severity, s:LSP_MESSAGE_TYPE_WARNING)

    if a:type > l:cfg_severity_threshold
        return v:null
    endif

    " Severity will depend on the message type
    if a:type is# s:LSP_MESSAGE_TYPE_ERROR
        let l:severity = g:ale_echo_msg_error_str
    elseif a:type is# s:LSP_MESSAGE_TYPE_INFORMATION
        let l:severity = g:ale_echo_msg_info_str
    elseif a:type is# s:LSP_MESSAGE_TYPE_LOG
        let l:severity = g:ale_echo_msg_log_str
    else
        " Default to warning just in case
        let l:severity = g:ale_echo_msg_warning_str
    endif

    let l:string = g:ale_lsp_show_message_format
    let l:string = substitute(l:string, '\V%severity%', l:severity, 'g')
    let l:string = substitute(l:string, '\V%linter%', a:linter_name, 'g')
    let l:string = substitute(l:string, '\V%s\>', a:message, 'g')

    return l:string
endfunction

" Handle window/showMessage response.
" - params: dict with the params for the call in the form of {type: number, message: string}
function! ale#lsp_window#HandleLogMessage(linter_name, params) abort
    let l:string = s:formatMessage(a:linter_name,a:params.message, a:params.type)
    if l:string isnot# v:null
        echomsg l:string
    endif
endfunction

" Handle window/showMessage response.
" - params: dict with the params for the call in the form of {type: number, message: string}
function! ale#lsp_window#HandleShowMessage(linter_name, params) abort
    let l:string = s:formatMessage(a:linter_name, a:params.message, a:params.type)
    if l:string isnot# v:null
        call ale#util#ShowMessage(l:string)
    endif
endfunction
