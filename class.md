#model
## 一般的なModel
* Gadgets
    + Gadget
        - Config
* User
    + Person
    + Courses
    + Options

## Viewに関連するModel
+ Home
    でもViewにもeventsはある...?
    changeでtriggerが発火しない

    * mode
        いわゆる表示モード
        - list
        - grid
        - full
    * sub-span
    * main-span
    * gadget-span

#view
* HomeView
    HomeViewが.subや.mainのspanを変えてるのがキモい
    + HomeSubView::sub-span
        + HomeViewSwitch
        + GadgetNavs
            - GadgetNavItem
    + GadgetIframes::main-span
        - GadgetIframe::gadget-span
        - GadgetUserConfig #Modalとか使ってみる

* Market

##spanの変更
