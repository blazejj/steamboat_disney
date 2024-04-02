function HttpClient() as object
    try
        instance = {}
        instance.constructor = function()
            m.http_transferPool = []
        end function
        instance.GetToString = function(url as String)
            netClient = m.http_transferPool.Pop()
            if netClient = invalid then
                netClient = createObject("roUrlTransfer")
            end if
            port = createObject("roMessagePort")
            netClient.setMessagePort(port)
            netClient.setCertificatesFile("common:/certs/ca-bundle.crt")
            netClient.setUrl(url)
            netClient.retainBodyOnError(true)
            netClient.asyncGetToString()
            while (true)
                msg = wait(0, port)
                msgType = type(msg)
                if msgType = "roUrlEvent" then
                    response = { code: msg.GetResponseCode(), data: msg.GetString(), headers: msg.GetResponseHeaders() }
                    exit while
                end if
            end while
            m.http_transferPool.Push(netClient)
            return response
        end function
        instance.constructor()
        return instance
    catch e
        ? "Error: HttpClient:"
        for each item in e.backtrace
            ? item
        end for
    end try
end function
