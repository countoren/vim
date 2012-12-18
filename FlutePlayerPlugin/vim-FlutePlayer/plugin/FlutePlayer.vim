" SECTION: Dependcies"{{{
" JSON Parser"{{{
let $JSONParserPath = getcwd().'/parsejson.vim'
source $JSONParserPath"}}}"}}}

" SECTION: Model "{{{
"CLASS: KeyMap "{{{
"============================================================
let s:KeyMap = {}
"FUNCTION: KeyMap.All() {{{3"{{{
function! s:KeyMap.All()
    if !exists("s:keyMaps")
        let s:keyMaps = []
    endif
    return s:keyMaps
endfunction"}}}
"FUNCTION: KeyMap.FindFor(key, scope) {{{3
function! s:KeyMap.FindFor(key, scope)
    for i in s:KeyMap.All()
         if i.key ==# a:key && i.scope ==# a:scope
            return i
        endif
    endfor
    return {}
endfunction

"FUNCTION: KeyMap.BindAll() {{{3
function! s:KeyMap.BindAll()
    for i in s:KeyMap.All()
        call i.bind()
    endfor
endfunction

"FUNCTION: KeyMap.bind() {{{3
function! s:KeyMap.bind()
    let mapkey = self.key
    if mapkey =~? '^\([CM]-\|middlerelease\|2-leftmouse\|leftrelease\)'
        let mapkey = '<' . mapkey . '>'
    endif

    let premap = self.key == "leftrelease" ? " <leftrelease>" : " "

    exec 'nnoremap <buffer> <silent> '. mapkey . premap . ':call <SID>KeyMap_Invoke("'. self.key .'")<cr>'
endfunction



"FUNCTION: KeyMap.invoke() {{{3
"Call the KeyMaps callback function
function! s:KeyMap.invoke(...)

    let Callback = function(self.callback)
    if a:0
        call Callback(a:1)
    else
        call Callback()
    endif
endfunction


"FUNCTION: KeyMap.Invoke() {{{3
"Find a keymapping for a:key and the current scope invoke it.
"
"Scope is determined as follows:
"   * if the cursor is on a operation node then "operationNode"
"
"If a keymap has the scope of "all" then it will be called if no other keymap
"is found for a:key and the scope.
function! s:KeyMap.Invoke(key)
	
    if !empty(matchstr(getline('.'), '^[0-9]\+ .\+'))
            let km = s:KeyMap.FindFor(a:key, "OperationNode")
            if !empty(km)
                return km.invoke()
            endif
    endif

    "try all
    let km = s:KeyMap.FindFor(a:key, "all")
    if !empty(km)
        return km.invoke()
    endif
endfunction

"this is needed since I cant figure out how to invoke dict functions from a
"key map
function! s:KeyMap_Invoke(key)
    call s:KeyMap.Invoke(a:key)
endfunction

"FUNCTION: KeyMap.Create(options) {{{3
function! s:KeyMap.Create(options)
    let newKeyMap = copy(self)
    let opts = extend({'scope': 'all', 'quickhelpText': ''}, copy(a:options))
    let newKeyMap.key = opts['key']
    let newKeyMap.quickhelpText = opts['quickhelpText']
    let newKeyMap.callback = opts['callback']
    let newKeyMap.scope = opts['scope']

    call s:KeyMap.Add(newKeyMap)
endfunction

"FUNCTION: KeyMap.Add(keymap) 
function! s:KeyMap.Add(keymap)
    let oldmap = s:KeyMap.FindFor(a:keymap.key, a:keymap.scope)
    if !empty(oldmap)
        call remove(s:KeyMap.All(), index(s:KeyMap.All(), oldmap))
    endif

    call add(s:KeyMap.All(), a:keymap)
endfunction

"}}}"}}}
"}}}
" SECTION: Controllers"{{{
" OperationController"{{{
let s:OperationController = {}

" Constractor"{{{
function! s:OperationController.New()
	let newOperationController = copy(self)
	let newOperationController.OperationSummaryDTO = {}
	return newOperationController
endf

"}}}
" METHOD: s:OperationController.GetOperationSummary()"{{{
" use curl request to get OperationSummaryDTO
function! s:OperationController.GetOperationSummary()
	let self.OperationSummaryDTO = ParseJSON(CurlGetOperationSummary(g:FlutePlayerIp , g:FlutePlayerPort))
endf
"}}}
" METHOD: PrintOperationsToBuffer()"{{{
" prints out from currentline OperationSummaryDTO Dictonary to buffer
function! s:OperationController.PrintOperationsToBuffer()
	let s:i = line('.')
	for item in self.OperationSummaryDTO.OperationSummary
		call setline( s:i,matchstr(item.Id,'[0-9]\+')."  ".item.Name )
		let s:i+=1
	endfor
endfunction
"}}}
" METHOD: GetOperationsAsString()"{{{
" Returns List Of Operations
function! s:OperationController.GetOperationsAsString()
	let OperationsString = ''
	for operation in self.OperationSummaryDTO.OperationSummary
		let OperationsString = OperationsString.matchstr(operation.Id,'[0-9]\+')."  ".operation.Name."\n"
	endfor
	return OperationsString
endf
""}}}


function! OpenNewOperationBuffer()
let operationId = matchstr(getline('.'),'^[0-9]\+')
if empty(operationId)
	return
endif
exec 'tabe operation-'.operationId 
let result = CurlGetOperationById(g:FlutePlayerIp , g:FlutePlayerPort , operationId)
call setline('.',result)
call CreateFlutePlayerWindow()
endf

" SECTION: Config"{{{
" VARIABLES: Genral"{{{

let g:FlutePlayerIp = "192.168.0.204"
let g:FlutePlayerPort = "9441"
let g:FPConnectionTimeOut = '1'

" window settings 
let g:FlutePlayerWinSize = 31
let g:FlutePlayerWinPos  = "left"
let g:FlutePlayerHighlightCursorline = 1
let g:FlutePlayerStatusline = "FlutePlayer Operations"

let s:FlutePlayerBufName = "FlutePlayerBuf"
let s:next_buffer_number = 1 

let b:FlutePlayerShowHelp = 1
"}}}
" VARIABLES: Mappings"{{{

let g:FlutePlayerMapOpenNewOperationBuffer = 'o'

"}}}
"}}}

" SECTION: Initialaize"{{{


" Controllers Initialiation
let s:operationController = s:OperationController.New()

"}}}
"FUNCTION: CreateFlutePlayerWindow()"{{{
"Inits the FlutePlayer window. ie. opens it, sizes it, sets all the local
"options etc
function! CreateFlutePlayerWindow()
    "create the FlutePlayer window
    let splitLocation = g:FlutePlayerWinPos ==# "left" ? "topleft " : "botright "
    let splitSize = g:FlutePlayerWinSize

    if !exists('t:FlutePlayerBufName')
        let t:FlutePlayerBufName = s:nextBufferName()
        silent! exec splitLocation . 'vertical ' . splitSize . ' new'
        silent! exec "edit " . t:FlutePlayerBufName
    else
        silent! exec splitLocation . 'vertical ' . splitSize . ' split'
        silent! exec "buffer " . t:FlutePlayerBufName
    endif

    setlocal winfixwidth
    call s:setCommonBufOptions()
    call FlutePlayerRender()
endfunction

"}}}
" FUNCTION: s:nextBufferName() {{{2
" returns the buffer name for the next nerd tree
function! s:nextBufferName()
    let name = s:FlutePlayerBufName . s:next_buffer_number
    let s:next_buffer_number += 1
    return name
endfunction
"}}}
"FUNCTION: s:setCommonBufOptions() "{{{
function! s:setCommonBufOptions()
    "throwaway buffer options
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal nobuflisted
    setlocal nospell

    iabc <buffer>

    if g:FlutePlayerHighlightCursorline
        setlocal cursorline
    endif

    call s:setupStatusline()
    
    let b:FlutePlayerShowHelp = 0
    setfiletype FlutePlayer
    call s:bindMappings()
endfunction

"}}}


" setup Status Line"{{{
function! s:setupStatusline()
    if g:FlutePlayerStatusline != -1
        let &l:statusline = g:FlutePlayerStatusline
    endif
endfunction

"}}}"}}}
" SECTION: Bind Interface"{{{
"FUNCTION: s:bindMappings() "{{{
function! s:bindMappings()
    let s = '<SNR>' . s:SID() . '_'

    call FlutePlayerAddKeyMap({ 'key': g:FlutePlayerMapOpenNewOperationBuffer, 'scope': "OperationNode", 'callback': "OpenNewOperationBuffer" })

    "bind all the user custom maps
    call s:KeyMap.BindAll()

endfunction

" Function: s:SID()   {{{2
function! s:SID()
    if !exists("s:sid")
        let s:sid = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
    endif
    return s:sid
endfun

"}}}
"}}}
" SECTION: Curl Request Methods"{{{
" METHOD: CurlGetOperationSummary"{{{
" executing curl request on fluteplayer controller to get OperationSummaryList 
" and convert it to Diconary 
fu! CurlGetOperationSummary(ip, port)
	let g:result = system('curl --connect-timeout '.g:FPConnectionTimeOut.' --max-time '.g:FPConnectionTimeOut.' -s -v "http://'.a:ip.':'.a:port.'/operations/operationsummary?ItemsToSkip=0&ItemsToRetrieve=50"')
        let g:jsonResult='{"OperationSummary":'. matchstr(g:result , '\[{".\+":.\+}\]') . '}'

	if g:jsonResult == '{"OperationSummary":}' && matchstr(g:result , 'Operation timed out') != ''
		echo "Connection timed out."
	endif
	return g:jsonResult
endf
"}}}
" METHOD: CurlGetOperationWithId"{{{
" executing curl request with operationid to get an operation
" fromFlutePlayerController
fu! CurlGetOperationById(ip, port,id)
	let result = system('curl --connect-timeout '.g:FPConnectionTimeOut.' --max-time '.g:FPConnectionTimeOut.' -N -s -v "http://'.a:ip.':'.a:port.'/operations/operations-'.a:id.'"')
        let jsonResult= matchstr(result ,'{"Actions":.\+"Id":"operations-.\+}')

 	return jsonResult
endf


"}}}
" METHOD: CurlPostOperation
" send a post request to FlutePlayer Controller with jsoned operation.
fu! CurlPostOperation(ip,port,JsonOperation)
	let g:result = system('curl -v -X PUT --form "operationData='.a:JsonOperation.'" http://'.a:ip.':'.a:port.'/operations/Import')
	return g:result
endf
"}}}
" SECTION: View Functions {{{1
"============================================================
"FUNCTION: s:dumpHelp  {{{2
"prints out the quick help
function! s:dumpHelp()
    let old_h = @h
    if b:FlutePlayerShowHelp ==# 1
        let @h=@h."\" Bookmark commands~\n"
        let @h=@h."\" :Bookmark <name>\n"
        let @h=@h."\" :BookmarkToRoot <name>\n"
        let @h=@h."\" :RevealBookmark <name>\n"
        let @h=@h."\" :OpenBookmark <name>\n"
        let @h=@h."\" :ClearBookmarks [<names>]\n"
        let @h=@h."\" :ClearAllBookmarks\n"
        silent! put h
    endif

    let @h = old_h
endfunction
"}}}
"FUNCTION: s:renderView "{{{
"The entry function for rendering the tree
function! s:renderView()
    setlocal modifiable

    "remember the top line of the buffer and the current line so we can
    "restore the view exactly how it was
    let curLine = line(".")
    let curCol = col(".")
    let topLine = line("w0")

    "delete all lines in the buffer (being careful not to clobber a register)
    silent 1,$delete _

    call s:dumpHelp()

    "delete the blank line before the help and add one after it
    " if g:NERDTreeMinimalUI == 0
    "     call setline(line(".")+1, "")
    "     call cursor(line(".")+1, col("."))
    " endif

    " "add the 'up a dir' line
    " if !g:NERDTreeMinimalUI
    "     call setline(line(".")+1, s:tree_up_dir_line)
    "     call cursor(line(".")+1, col("."))
    " endif

    "draw the header line
    let header = "FlutePlayer Operations"
    call setline(line(".")+1, header)
    call cursor(line(".")+1, col("."))


    "draw the Operations manu
    call s:operationController.GetOperationSummary()
    let @o = "\n".s:operationController.GetOperationsAsString()
    silent put o


    "delete the blank line at the top of the buffer
    " silent 1,1delete _
    " restore the view
    let old_scrolloff=&scrolloff
    let &scrolloff=0
    call cursor(topLine, 1)
    normal! zt
    call cursor(curLine, curCol)
    let &scrolloff = old_scrolloff

    setlocal nomodifiable
endfunction
"}}}
"}}}
" SECTION: Public API {{{1
"============================================================

function! FlutePlayerAddKeyMap(options)
    call s:KeyMap.Create(a:options)
endfunction

function! FlutePlayerRender()
    call s:renderView()
endfunction
"}}}


fu! Test()


echo system('curl -v -X PUT --form "operationData= {"Actions":[{"__type":"SqlActionDto:#TopManage.FlutePlayer.DTOs","ActionIdentifier":"SqlAction","ExceptionResolution":"ABORT_ALL_OPERATIONS","Id":"878767e7-49a8-75a7-e3af-6ad24bfb56be","CommandText":{"Source":"FIXED_VALUE","Value":"\/*    \u000a -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>TOPMANAGE.COM.PA>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\u000a  >> Title:                  Create FP_Transaction Notification \u000a  >> Summary:                Realiza la creación de un Stored Procedure (en OBSERVER), por intermedio de Flute Player \u000a  >> Flute Player Operation: SqlAction \u000a  >> Author:                 Pedro Mauricio A. Lima   \u000a  >> Date:                   29\/02\/2012   \u000a  >> Copyright:              topmanage.com.pa \u000a  >> Revision:\u0009\u0009\u0009\u0009 OK  \u000a  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\u000a*\/ \u000a \u000aUSE [KENNEDYDB] \u000a\u000aDECLARE @CreateAlterFlag NVARCHAR(20) \u000a\u000aSET @CreateAlterFlag = ''alter'' \u000a\u000aIF NOT EXISTS (SELECT '''' \u000a               FROM   dbo.sysobjects \u000a               WHERE  Type = ''P'' \u000a                      AND Name = ''FP_TransactionNotidication'') \u000a  BEGIN \u000a      SET @CreateAlterFlag = ''create'' \u000a  END \u000a\u000aEXEC ( \u000a@createAlterFlag+''\u000a proc [dbo].[FP_TransactionNotidication]  \u000a\u0009     @object_type nvarchar(20),\u000a\u0009   \u0009@transaction_type nchar(1),\/* [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose *\/ \u000a\u0009\u0009  @num_of_cols_in_key int, \u000a\u0009\u0009  @list_of_key_cols_tab_del nvarchar(255), \u000a\u0009\u0009  @list_of_cols_val_tab_del nvarchar(255) \u000aas \u000a\u000aif (@object_type=4 and @transaction_type=''''U'''' AND @list_of_key_cols_tab_del=''''ItemCode'''')\u000abegin \u000a\u0009UPDATE OITM \u000a\u0009SET U_FPItemVersion = isnull(U_FPItemVersion,0)+1 \u000a\u0009WHERE ItemCode=@list_of_cols_val_tab_del \u000aend  \u000a''\u000a\u0009  ) \u000a\u0009  \u000a\u0009  \u000a\u0009  \u000a-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>TOPMANAGE.COM.PA>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"},"IsStoredProcedure":{"Source":"FIXED_VALUE","Value":"false"},"ReturnParameters":{"Source":"FIXED_VALUE","Value":"false"},"SqlConnectionString":{"Source":"FIXED_VALUE","Value":"Data Source=127.0.0.1;User Id=FlutePlayer;Password=fluteplayer123;"},"SqlDbParameters":[],"SqlProviderName":{"Source":"FIXED_VALUE","Value":"System.Data.SqlClient"}}],"DeploymentSettings":{"ConcurrencyLimit":0,"EnableSchedule":false,"IsActive":false,"Priority":5,"Schedule":"*\/60 * * * *","Targets":["agents-1"]},"Id":"operations-2","Name":"Create FP_TransactionNotification","Protected":false}" http://''.a:ip.'':''.a:port.''/operations/Import')

endf
