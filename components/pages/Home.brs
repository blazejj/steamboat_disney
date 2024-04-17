sub init()
    m.config = getConfig()
    minSafeWidth = getMinSafeWidth()
    safeY = getSafeY()
    minSafeX = getMinSafeX()
    minSafeY = getMinSafeY()

    countAccross = 5
    m.tileSpacing = 20
    ratio = 1.78
    m.tileDim = getTileDimension(countAccross, m.tileSpacing, ratio)

    pageTitle = m.top.findNode("pageTitle")
    pageTitle.translation = [minSafeX, minSafeY]

    m.focusScaleRatio = .05
    focusScaleDim = [(1 + m.focusScaleRatio) * m.tileDim[0], (1 + m.focusScaleRatio) * m.tileDim[1]]

    m.homeRowList = m.top.FindNode("HomeRowList")
    m.homeRowList.translation = [minSafeX, safeY]
    m.homeRowList.rowLabelOffset = [[0, m.tileSpacing / 2]]
    m.homeRowList.itemSize = [minSafeWidth, 260]
    m.homeRowList.rowItemSize = [focusScaleDim]
    m.homeRowList.rowItemSpacing = [[5, 0]]
    m.homeRowList.focusBitmapUri = m.config.focusBorder
    m.homeRowList.focusXOffset = [8]

    m.homeRowList.observeField("itemFocused", "onItemFocused")
    m.homeRowList.observeField("rowItemSelected", "onRowItemSelected")
    m.homeRowList.setFocus(true)
    m.homeRowList.visible = true
end sub

sub handleFocus()
    m.homeRowList.setFocus(m.top.setFocus)
end sub

sub onRowItemSelected(field as object)
    selectedIndex = field.getData()
    if m.homeRowList <> invalid and m.homeRowList.content <> invalid
        selectedRow = m.homeRowList.content.getChild(selectedIndex[0])
        selectedContent = selectedRow.getChild(selectedIndex[1])
        showDetailInfo(selectedContent)
    end if
end sub

sub onItemFocused(field as object)
    if m.homeRowList <> invalid and m.homeRowList.content <> invalid
        focusedRowIndex = field.getData()
        lastRowIndex = m.homeRowList.content.getChildCount() - 1
        lastRowInViewIndex = focusedRowIndex + m.homeRowList.numRows - 1

        if lastRowInViewIndex > lastRowIndex 'and lastRowInViewIndex - lastRowIndex = 1 then
            refRow = m.rowContainers[lastRowInViewIndex]

            if refRow <> invalid and not refRow.isLoaded then
                refRow.isLoaded = true
                m.top.refReq = {rowIndex: refRow.rowIndex, refId: refRow.refId, rowTitle: refRow.rowTitle}
            end if
        end if
    end if
end sub

sub showDetailInfo(selectedContent as object)
    m.detailInfo = CreateObject("roSGNode", "DetailInfo")
    m.detailInfo.selectedContent = selectedContent
    m.top.appendChild(m.detailInfo)
    m.detailInfo.setFocus(true)
    m.detailInfo.observeField("exit", "onDetailInfoExit")
end sub

sub onDetailInfoExit()
    if m.detailInfo <> invalid and m.detailInfo.exit
        m.top.removeChild(m.detailInfo)
        m.detailInfo  = invalid
        m.top.setFocus = true
    end if
end sub

sub onPayload()
    payload = m.top.payload
    pageTitle = m.top.findNode("pageTitle")
    pageTitle.text = payload.pageTitle
    pageTitle.visible = true
    m.rowContainers = payload.rowContainers
    homeContent = CreateObject("roSGNode", "ContentNode")
    for each row in m.rowContainers
        if row.isLoaded then
            rowItems = row.rowItems

            if rowItems <> invalid then
                homeRow = homeContent.CreateChild("ContentNode")
                homeRow.title = row.rowTitle
                homeRow.id = row.rowIndex
                homeRow.addField("refId", "string", false)
                homeRow.addField("setId", "string", false)
                homeRow.refId = row.refId
                homeRow.setId = row.setId

                for each rowItem in rowItems
                        homeRowItem = homeRow.CreateChild("RowItem")
                        homeRowItem.title = rowItem.tileTitle
                        homeRowItem.thumbnailUrl = rowItem.thumbnailUrl
                        homeRowItem.itemDim =  m.tileDim
                        homeRowItem.backupThumbnail = m.config.backupThumbnail
                        homeRowItem.focusScaleRatio = m.focusScaleRatio
                        homeRowItem.tileSpacing = m.tileSpacing
                        homeRowItem.releaseYear = rowItem.releaseYear
                        homeRowItem.ratings = rowItem.ratings
                end for
            end if
        end if
    end for
    m.homeRowList.content = homeContent
end sub

sub onRefPayload()
    refPayload = m.top.refPayload
    rowContainer = refPayload.rowContainer
    rowItems = rowContainer.rowitems
    if rowItems <> invalid then
        refRow = CreateObject("roSGNode", "ContentNode")
        refRow.title = rowContainer.rowTitle
        refRow.id = rowContainer.rowIndex
        refRow.addField("refId", "string", false)
        refRow.addField("setId", "string", false)
        refRow.refId = rowContainer.refId
        refRow.setId = rowContainer.setId

        for each rowItem in rowItems
            refRowItem = refRow.CreateChild("RowItem")
            refRowItem.title = rowItem.tileTitle
            refRowItem.thumbnailUrl = rowItem.thumbnailUrl
            refRowItem.itemDim =  m.tileDim
            refRowItem.backupThumbnail = m.config.backupThumbnail
            refRowItem.focusScaleRatio = m.focusScaleRatio
            refRowItem.tileSpacing = m.tileSpacing
            refRowItem.releaseYear = rowItem.releaseYear
            refRowItem.ratings = rowItem.ratings
        end for
        m.homeRowList.content.insertChild(refRow, refRow.id.ToInt())
    end if
end sub