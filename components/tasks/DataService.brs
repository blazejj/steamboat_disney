sub init()
    m.config = getConfig()
    m.top.functionName = "startService"
end sub

sub startService()
    try
        m.port = CreateObject("roMessagePort")
        m.top.observeField("refReq", m.port)
        loadCatalog()

        while (true)
            msg = wait(0, m.port)
            msgType = type(msg)
            if msgType = "roSGNodeEvent" then

                if msg.getField() = "refReq" then
                    request = msg.getData()
                    loadRefData(request)
                end if
            end if
        end while
    catch e
        ? "Error: DataService: startService:"
        for each item in e.backtrace
            ? item
        end for
    end try
end sub

sub loadCatalog()
    try
        apiResponse = m.httpClient.GetToString(m.config.data_api.homeUrl)
        if apiResponse <> invalid and apiResponse.code = 200 and apiResponse.data <> invalid then
            catalog = ParseJson(apiResponse.data)
            catalogObj = catalog.data
            parseCatalog(catalogObj)
        else
            m.top.payload = {errorGettingCatalog: true}
        end if
    catch e
        m.top.payload = {errorGettingCatalog: true}
        ? "Error: DataService: loadCatalog:"
        for each item in e.backtrace
            ? item
        end for
    end try
end sub

sub loadRefData(request as object)
    try
        refUrl = m.config.data_api.refUrl.replace("{refId}", request.refId)
        apiResponse = m.httpClient.GetToString(refUrl)

        if apiResponse <> invalid and apiResponse.code = 200 and apiResponse.data <> invalid then
            refData = ParseJson(apiResponse.data)
            refDataObj = refData.data
            parseRefData(refDataObj)
        else
            m.top.refPayload = {errorGettingRefData: true}
        end if
    catch e
        m.top.refPayload = {errorGettingRefData: true}
        ? "Error: DataService: loadRefData:"
        for each item in e.backtrace
            ? item
        end for
    end try
end sub

sub parseRefData(refDataObj as object)
    errorGettingRefData = false
    rowItems = getTargetObj(refDataObj, "{}/items")'"CuratedSet/items")
    rowObj = {}
    rowObj.rowTitle = m.top.refReq.rowTitle
    rowObj.rowIndex = m.top.refReq.rowIndex
    rowObj.setId = getTargetObj(refDataObj, "{}/setId")'"CuratedSet/setId")
    rowItemsContainers = []

    if rowItems <> invalid then
        for each rowItem in rowItems
            rowItemObj = {}
            rowItemObj.tileTitle = getTargetObj(rowItem, "text/title/full/{}/default/content")
            rowItemObj.thumbnailUrl = getTargetObj(rowItem, "image/tile/1.78/{}/default/url")
            releases = getTargetObj(rowItem, "releases")

            if Type(releases) = "roArray" and releases.Count() = 1 then
                rowItemObj.releaseYear = getTargetObj(releases[0], "releaseYear")
            end if
            ratings = getTargetObj(rowItem, "ratings")

            if Type(ratings) = "roArray" and ratings.Count() = 1 then
                rowItemObj.ratings = getTargetObj(ratings[0], "value")
            end if
            rowItemsContainers.Push(rowItemObj)
        end for
    end if
    rowObj.rowItems = rowItemsContainers
    refPayload = CreateObject("roAssociativeArray")
    refPayload.AddReplace("errorGettingRefData", errorGettingRefData)
    refPayload.AddReplace("rowContainer", rowObj)
    m.top.refPayload = refPayload
end sub

sub parseCatalog(catalogObj as object)
    errorGettingCatalog = false
    pageTitle = getTargetObj(catalogObj, "StandardCollection/text/title/full/collection/default/content")
    apiRows = getTargetObj(catalogObj, "StandardCollection/containers")
    rowContainers = []
    rowIndex = 0

    for each apiRow in apiRows
        rowObj = {}
        rowObj.rowTitle = getTargetObj(apiRow, "set/text/title/full/set/default/content")
        rowObj.rowIndex = rowIndex
        rowIndex++
        rowObj.setId = getTargetObj(apiRow, "set/setId")
        rowObj.refId = getTargetObj(apiRow, "set/refId")
        rowItems = getTargetObj(apiRow, "set/items")
        rowItemsContainers = []

        if rowItems <> invalid then
            for each rowItem in rowItems
                rowItemObj = {}
                rowItemObj.tileTitle = getTargetObj(rowItem, "text/title/full/{}/default/content")
                rowItemObj.thumbnailUrl = getTargetObj(rowItem, "image/tile/1.78/{}/default/url")
                releases = getTargetObj(rowItem, "releases")

                if Type(releases) = "roArray" and releases.Count() = 1 then
                    rowItemObj.releaseYear = getTargetObj(releases[0], "releaseYear")
                end if
                ratings = getTargetObj(rowItem, "ratings")

                if Type(ratings) = "roArray" and ratings.Count() = 1 then
                    rowItemObj.ratings = getTargetObj(ratings[0], "value")
                end if
                rowItemsContainers.Push(rowItemObj)
            end for
        end if
        rowObj.rowItems = rowItemsContainers

        if rowObj.setId <> invalid then
            rowObj.isLoaded = true
        else
            rowObj.isLoaded = false
        end if
        rowContainers.Push(rowObj)
    end for
    payload = CreateObject("roAssociativeArray")
    payload.AddReplace("errorGettingCatalog", errorGettingCatalog)
    payload.AddReplace("pageTitle", pageTitle)
    payload.AddReplace("rowContainers", rowContainers)
    m.top.payload = payload
end sub