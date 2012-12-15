" FlutePlayer LogFile
" Mapping - get sql you are on open new tab paste it and run FPLogToSql 
"
nmap <silent> <leader>f ?Adding Parameters to Query<CR><S-v>/Executing the following Query on<CR>/[0-9]\{4\}-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9]\{4\}<CR>kky:tabe<CR>pgg<S-v>G:call FPLogToSql()<CR>






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
