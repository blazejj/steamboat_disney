sub init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0x000032ff"
    m.top.setFocus(true)
    m.homePage = m.top.findNode("homePage")
    m.homePage.observeField("refReq", "onRefReq")
    loadData()
end sub

sub loadData()
    m.dataService = CreateObject("roSGNode", "DataService")
    m.dataService.observeField("payload", "onPayload")
    m.dataService.control = "Run"
end sub

sub onPayload()
    m.top.setLoadSpinner = false
    payLoad = m.dataService.payload
    if payload <> invalid then
        m.homePage.payload = payload
        m.dataService.unobserveField("payload")
        m.top.signalBeacon("AppLaunchComplete")
    end if
end sub

sub onRefPayload()
    refPayload = m.dataService.refPayload
    if refPayload <> invalid then
        m.homePage.refPayload = refPayload
        m.dataService.unobserveField("refPayload")
    end if
end sub

sub onRefReq()
    m.dataService.observeField("refPayload", "onRefPayload")
    m.dataService.refReq = m.homePage.refReq
end sub