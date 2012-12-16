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
    * focus
        現在注目しているガジェット
        fullモードで使用

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


gadgetのメニューはどう変更するべきか
renderとremoveについて
* render
    renderは更新の為に呼ばれる
    -> create & update

* Modal
    要素がdocumentに無くても起動は可能
    ただしゴミがdocumentに溜まっていくので消していく必要あり

* GadgetMenuは分割するべきか

* Market

