/*** FPOS  Files   *****/

let FPControllerIp = "192.168.0.204"
let FPControllerPort = "9441"

/*Open Json Values (Replace unicodes with  enter , tabs)*/
nmap <F5> :%s/\\u000a/\r/g\|%s/\\u0009/\t/g<CR><CR> 


/*Close Json Values ( Rplace Enter , Tabs with unicodes*/
nmap <F7> m':%s/\t/\\u0009/g\|%s/$/\\u000a/g\|:%j!<CR>A<BS><BS><BS><BS><BS><BS><ESC>`'



/*FPO: Create New Text Column Value*/
nmap <F8> /],"RowsInHeader":{"Source":"<CR>i,{"ColumnNumber":{"Source":"FIXED_VALUE","Value":"0"},"FieldLength":{"Source":"FIXED_VALUE","Value":"0"},"FieldName":{"Source":"FIXED_VALUE","Value":"VIM_ValueToPut"},"FillerCharacter":{"Source":"FIXED_VALUE","Value":"0"},"FillerDirection":{"Source":"FIXED_VALUE","Value":"FILL_RIGHT"},"StartingPosition":{"Source":"FIXED_VALUE","Value":"0"},"Value":{"Source":"CURRENT_DATA_ROW","Value":"VIM_ValueToPut"}}<ESC>?VIM_ValueToPut<CR>

/*FPO: Create New SQL Paramter */
nmap <F4> /SqlDbParameters":\[/e<CR>a{"DbParameterName":{"Source":"FIXED_VALUE","Value":"VIM_ValueToPut"},"DbType":{"Source":"FIXED_VALUE","Value":"VIM_ValueToPut"},"Direction":{"Source":"FIXED_VALUE","Value":"Input"},"Value":{"Source":"CURRENT_DATA_ROW","Value":"VIM_ValueToPut"}},<ESC>m'?VIM_ValueToPut<CR>`'

/*FPO: Select all Sql Command*/
nmap <F3> ?"CommandText":{"Source":"FIXED_VALUE","Value":"?e+1<CR>v/"},"IsStoredProcedure":{"Source":"FIXED_VALUE","Value":"false"},"ReturnParameters":/s-1<CR>

