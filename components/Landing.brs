sub init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0x000032ff"
    m.top.setFocus(true)
    m.homePage = m.top.findNode("homePage")
    loadData()
end sub

sub loadData()
    m.dataService = CreateObject("roSGNode", "DataService")
    m.dataService.control = "Run"
    m.dataService.ObserveField("payload", "onPayload")
end sub

sub onPayload()
    m.top.setLoadSpinner = false
    payLoad = m.dataService.payload
    m.homePage.payload = payload
end sub