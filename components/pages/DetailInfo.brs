sub init()
    width = getSafeWidth()
    height = Int(width / 1.78)
    m.top.width = width
    m.top.height = height
    m.top.translation = [getSafeX(), getSafeY()]
    m.top.color = "#000000"

    fontSize = 50
    hRatio = .25

    m.infoPoster = m.top.findNode("infoPoster")
    m.infoPoster.width = width
    m.infoPoster.height = height
    m.infoPoster.visible = true

    infoGroup = m.top.findNode("infoGroup")
    infoGroup.translation = [0, 100]
    infoGroup.visible = true

    m.lblTitle = m.top.findNode("lblTitle")
    m.lblTitle.font.size = fontSize + fontSize
    m.lblTitle.width = width
    m.lblTitle.height = height * hRatio

    m.lblReleased = m.top.findNode("lblReleased")
    m.lblReleased.font.size = fontSize
    m.lblReleased.width = width
    m.lblReleased.height = height * hRatio

    m.lblRatings = m.top.findNode("lblRatings")
    m.lblRatings.font.size = fontSize
    m.lblRatings.width = width
    m.lblRatings.height = height * hRatio
end sub

sub onSelectedContent()
    selectedContent = m.top.selectedContent
    if selectedContent <> invalid then

        thumbnailUrl = selectedContent.thumbnailUrl
        if thumbnailUrl <> invalid
            m.infoPoster.observeField("loadStatus", "onInfoPosterLoadStatus")
            m.infoPoster.uri = thumbnailUrl
        end if

        title = selectedContent.title
        if title <> invalid and  title <> "" then
            m.lblTitle.text = title
        end if

        releaseYear = selectedContent.releaseYear
        if releaseYear <> invalid and  releaseYear <> "" then
            m.lblReleased.text = m.lblReleased.text.replace("{releaseYear}", releaseYear)
        else
            m.lblReleased.text = "Release year info not available"
        end if

        ratings = selectedContent.ratings
        if ratings <> invalid and  ratings <> "" then
            m.lblRatings.text = m.lblRatings.text.replace("{ratings}", ratings)
        else
            m.lblRatings.text = "Ratings info not available"
        end if
    end if
end sub

sub onInfoPosterLoadStatus()
    backupThumbnail = m.top.selectedContent.backupThumbnail
    if m.infoPoster.loadStatus = "failed" and backupThumbnail <> invalid then
        m.infoPoster.uri = backupThumbnail
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "back" or key = "OK" then
            m.top.exit = true
        end if
    end if
    return true
end function