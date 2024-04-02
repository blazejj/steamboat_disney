sub init()
    m.top.functionName = "loadCatalog"
    m.config = getConfig()
end sub

sub loadCatalog()
    try
        apiResponse = m.httpClient.GetToString(m.config.data_api.homeUrl)
        if apiResponse <> invalid and apiResponse.code = 200 and apiResponse.data <> invalid then
            catalog = ParseJson(apiResponse.data)
            catalogObj = catalog.data.StandardCollection
            parseCatalog(catalogObj)
        else
            m.top.payload = {errorGettingCatalog: true}
        end if
    catch e
        m.top.payload = {errorGettingCatalog: true}
        ? "Error: DataService: LoadFullCatalog:"
        for each item in e.backtrace
            ? item
        end for
    end try
end sub

sub parseCatalog(catalogObj as Object)
    errorGettingCatalog = false
    pageTitle = ""
    rowContainers = []
    if catalogObj <> invalid then
        content = catalogObj.text.title.full.collection.default.content
        if content <> invalid then
            pageTitle = content
        end if

        if Type(catalogObj.containers) = "roArray"
            apiRows = catalogObj.containers
            for each row in apiRows
                rowObj = {}
                rowSet = row.set

                if rowSet <> invalid then
                    content = rowSet.text.title.full.set.default.content

                    if content <> invalid then
                        rowObj.rowTitle = content
                    end if

                    if rowSet <> invalid and Type(rowSet.items) = "roArray" then
                        rowItems = rowSet.items
                        rowItemsContainers = []
                        for each rowItem in rowItems
                            rowItemObj = {}

                            'fetching row item title
                            currNode = rowItem.text.title.full
                            if currNode <> invalid then
                                arbitraryObjNode = getArbSingleChildObj(currNode)

                                itemTitle = arbitraryObjNode.default.content
                                if itemTitle <> invalid then
                                    rowItemObj.tileTitle = itemTitle
                                end if
                            end if

                            'fetching tile thumbnail url
                            currNode = rowItem.image.tile["1.78"]
                            if currNode <> invalid then
                                arbitraryObjNode = getArbSingleChildObj(currNode)

                                itemThumbnailUrl = arbitraryObjNode.default.url
                                if itemThumbnailUrl <> invalid then
                                    rowItemObj.thumbnailUrl = itemThumbnailUrl
                                end if
                            end if

                            'fetching release year
                            currNode = rowItem.releases
                            if Type(currNode) = "roArray" and currNode.Count() = 1
                                currNode = currNode[0].releaseYear
                                if currNode <> invalid
                                    rowItemObj.releaseYear = currNode
                                end if
                            end if

                            'fetching ratings
                            currNode = rowItem.ratings
                            if Type(currNode) = "roArray" and currNode.Count() = 1
                                currNode = currNode[0].value
                                if currNode <> invalid
                                    rowItemObj.ratings = currNode
                                end if
                            end if

                            rowItemsContainers.Push(rowItemObj)
                        end for
                        rowObj.rowItems = rowItemsContainers
                    end if
                end if
                rowContainers.Push(rowObj)
            end for
        end if
    else
        errorGettingCatalog = true
    end if
    payload = CreateObject("roAssociativeArray")
    payload.AddReplace("errorGettingCatalog", errorGettingCatalog)
    payload.AddReplace("pageTitle", pageTitle)
    payload.AddReplace("rowContainers", rowContainers)
    m.top.payload = payload
end sub