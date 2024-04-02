function getConfig() as object
    if m.config = invalid then
        m.config = ParseJson(ReadAsciiFile("pkg:/configs/config.json"))
    end if
    return m.config
end function

function getArbSingleChildObj(srcObj as object) as object
    retVal = invalid
    childItems = srcObj.Items()
    if childItems <> invalid and Type(childItems) = "roArray" and childItems.Count() = 1 then
        keysValues = childItems[0]
        if Type(keysValues) = "roAssociativeArray" and keysValues.value <> invalid then
            retVal = keysValues.value
        end if
    end if
    return retVal
end function

function getResolution(dimType = "DefaultSceneResolution" as string) as dynamic
    if m.resolution = invalid then
        m.resolution = m.top.getScene().currentDesignResolution
    end if
    retVal = m.resolution
    if dimType = "width" or dimType = "height"
        retVal = retVal[dimType]
    else if dimType = "minSafeWidth"
        retVal = getResolution("width") * .9
    else if dimType = "minSafeHeight"
        retVal = getResolution("height") * .9
    else if dimType = "safeWidth"
        retVal = getResolution("width") * .8
    else if dimType = "safeHeight"
        retVal = getResolution("height") * .8
    end if
    return retVal
end function

function getWidth() as integer
    return getResolution("width")
end function

function getHeight() as integer
    return getResolution("height")
end function

function getSafeWidth() as integer
    return getResolution("safeWidth")
end function

function getSafeHeight() as integer
    return getResolution("safeHeight")
end function

function getMinSafeWidth() as integer
    return getResolution("minSafeWidth")
end function

function getMinSafeHeight() as integer
    return getResolution("minSafeHeight")
end function

function getSafeX() as integer
    return (getWidth() - getSafeWidth()) / 2
end function

function getSafeY() as integer
    return (getHeight() - getSafeHeight()) / 2
end function

function getMinSafeX() as integer
    return (getWidth() - getMinSafeWidth()) / 2
end function

function getMinSafeY() as integer
    return (getHeight() - getMinSafeHeight()) / 2
end function

function getTileDimension(countAccross = 5 as integer, spacing = 40 as integer, ratio = 1.78 as float) as object
    retVal = []
    sumTilesWidth = getSafeWidth() - (spacing * countAccross)
    tileWidth = Int(sumTilesWidth / 5)
    tileHeight = Int(tileWidth / ratio)
    retVal.Push(tileWidth)
    retVal.Push(tileHeight)
    return retVal
end function