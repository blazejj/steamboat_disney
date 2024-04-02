sub init() as void
    m.itemImage = m.top.findNode("itemImage") 
    m.itemLabel = m.top.findNode("itemLabel")
end sub
sub onItemContent()
    itemData = m.top.itemContent
    if itemData <> invalid then
        m.focusScaleRatio = itemData.focusScaleRatio
        setItemImage(itemData)
        setItemLabel(itemData)
        m.itemImage.scaleRotateCenter = [itemData.itemDim[0] /2, itemData.itemDim[1] / 2]
    end if
end sub

sub setItemLabel(itemData as object)
    itemLabelSpacing = itemData.tileSpacing
    m.itemLabel.text = itemData.title
    m.itemLabel.maxWidth = itemData.itemDim[0]
    m.itemLabel.font.size = 18
    m.itemLabel.translation = [itemLabelSpacing / 2, itemData.itemDim[1] + itemLabelSpacing ]
    m.itemLabel.visible = true
end sub

sub setItemImage(itemData as object)
    m.itemImage.uri = itemData.thumbnailUrl
    m.itemImage.failedBitmapUri = itemData.backupThumbnail
    m.itemImage.width = itemData.itemDim[0]
    m.itemImage.height = itemData.itemDim[1]
    m.itemImage.visible = true
end sub

sub onFocus()
    scaleUp = 1 + (m.top.focusPercent * m.focusScaleRatio)
    m.itemImage.scale = [scaleUp, scaleUp]
end sub

sub onRowFocus()
    m.itemImage.scale = [1, 1]
end sub