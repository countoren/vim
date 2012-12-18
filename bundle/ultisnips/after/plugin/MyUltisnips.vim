nmap <silent> <leader>s :let g:UltiSnipsEditSplit = 'normal'<cr>:UltiSnipsEdit<cr>

nmap <silent> <leader>ss :let g:UltiSnipsEditSplit = 'horizontal'<cr>:UltiSnipsEdit<cr>

nmap <silent> <leader>sa :let g:UltiSnipsEditSplit = 'vertical'<cr>:UltiSnipsEdit<cr>

let g:UltiSnipsSnippetsDir=$VIMFolder.'/bundle/ultisnips/MyUltiSnips'

let g:UltiSnipsSnippetDirectories=["MyUltiSnips","UltiSnips"]
