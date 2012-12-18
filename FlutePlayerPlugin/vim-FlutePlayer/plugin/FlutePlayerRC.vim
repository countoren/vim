" ============================================================================
" File:        FlutePlayer.vim
" Description: vim plugin for TopManage FlutePlayer
" Maintainer:  Oren Rozen <countoren at gmail dot com>
" Last Change: Wed May 23 11:59:37 2012
"
" ============================================================================
let s:FlutePlayerVimVersion = '1.0.0'
" Mapping - get sql you are on open new tab paste it and run FPLogToSql 
"
nmap <silent> <leader>s ?Adding Parameters to Query<CR><S-v>/Executing the following Query on<CR>/[0-9]\{4\}-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9]\{4\}<CR>kky:tabe<CR>pgg<S-v>G:call FPLogToSql()<CR>







" curl -v -H "Content-Type: multipart/form-data" -X PUT --form "operationData={\"Actions\":[],\"DeploymentSettings\":{\"ConcurrencyLimit\":0,\"EnableSchedule\":true,\"IsActive\":false,\"Priority\":5,\"Schedule\":\"*\/60 * * * *\",\"Targets\":[]},\"Id\":\"operations-2\",\"Name\":\"test\",\"Protected\":false}" http://192.168.0.204/FlutePlayer/Import
" 



" FlutePlayer Log
" table of Sql Types To .net Types
let g:SqlTypeDotNetType = [
			\ ['BigInt','Int64'],
			\ ['Binary','Byte'],
			\ ['Bit','Boolean'],
			\ ['NVarChar','String'],
			\ ['Char','String'],
			\ ['DateTime','DateTime'],
			\ ['Decimal','Decimal'],
			\ ['Float','Double'],
			\ ['Int','Int32'],
			\ ['Money','Decimal'],
			\ ['NChar','String'],
			\ ['Real','Single'],
			\ ['SmallDateTime','DateTime'],
			\ ['SmallInt','Int16'],
			\ ['SmallMoney','Decimal'],
			\ ['Text','String'],
			\ ['TinyInt','Byte'],
			\ ['UniqueIdentifier','Guid'],
			\ ['VarChar','String'],
			\ ['NText','String'],
			\ ['Variant','Object']]

" converts from .net to sql type 
function! DotNetTypeToSqlType(ClientDotNetType)
      for [SqlType, DotNetType] in g:SqlTypeDotNetType 
	      if (DotNetType == a:ClientDotNetType)
		      return SqlType
		     endif
      endfor
endf
" converts from sql to .net type
function! SqlTypeToDotNet(ClientSqlType)
      for [SqlType,DotNetType] in g:SqlTypeDotNetType 
	      if (SqlType == a:ClientDotNetType)
		      return DotNetType
		     endif
      endfor
endf


" convert FlutePlayer log sqls querys and parameters into pure sql statements 
function! FPLogToSql() range 

let n   = a:firstline 
let max = a:lastline 
let paramCounter = -1
while n <= max 
	let line = getline(n)

        if line =~ "Creating dbParameter for provider"
	let paramCounter = 0

	elseif paramCounter == 1
		let paramName = matchlist( line , 'parameter with \a\+ \(\a\+\)')		
	elseif paramCounter == 2
		let paramType = matchlist( line , 'parameter with \a\+ \(\a\+\)')		
	elseif paramCounter == 5
		let paramValue =matchlist( line , 'resulting value was (\(.*\))')	
	endif 

	if paramCounter == 5

		if (paramType[1] == "String")
			let s:type = "NvarChar(max)"
		else
			let s:type = DotNetTypeToSqlType(paramType[1])
		endif

		exe "normal ".n."G5ck"."declare ".paramName[1]." ".s:type." set ".paramName[1]." = '".paramValue[1]."'"
		let n -=5
		let max -=5	
	endif

	if paramCounter == 6
		exe "normal ".n."Gd/database:\<CR>dndW"
	endif

	if paramCounter == -1 
		let paramCounter = -1 
	else 
		let paramCounter += 1
	endif
	
	let n += 1

endwhile 
endfunction 




" executing curl request on fluteplayer controller to get OperationSummaryList 
" and convert it to Diconary
fu! GetOperationSummery(ip, port)
	let s:result = system('curl -v "http://'.a:ip.':'.a:port.'/operations/operationsummary?ItemsToSkip=0&ItemsToRetrieve=50"')
        let jsonResult='{"OperationSummary":'. matchstr(s:result , '\[{".\+":.\+}\]') . '}'
	return ParseJSON(jsonResult)
endf

" gets OperationSummary Dictonary  and print in buffer from current line
fu! PrintOperationsToBuffer (objectOperationSummary)
	let s:i = line('.')
	for item in a:objectOperationSummary.OperationSummary
		call setline( s:i,matchstr(item.Id,"[0-9]")."  ".item.Name )
		let s:i+=1
	endfor
endfunction


