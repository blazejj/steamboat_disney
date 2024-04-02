
sub init()
    m.rowTitle = m.top.findNode("rowTitle")
    m.rowTitle.font.size = 24
end sub
'
sub changeItem()
    if m.top.content <> invalid and m.top.content.title <> invalid then 
        m.rowTitle.text = m.top.content.title
    end if 
end sub
