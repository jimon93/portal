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


子が親に情報を渡したい時はEventsを利用する
gadgetのメニューはどう変更するべきか
renderとremoveについて

backboneのノウハウでは renderは再構築となっている
２つのメリットがある
    1. create, updateを分ける必要がない
    2. modelのデータ変更もこの関数だけですむ
しかしデメリットもある
    1. iframeのようにrenderに重いものもある
    2. modelの複数の値が変更された場合,複数回renderが呼ばれる
    3. 全体の一部を書き直したいだけの場合でも、全体を再構築する必要がある。
2に関しては`change:all`という抜け道はある。
backboneは要素の表示/非表示をDOMに構築/DOMから削除で行なっている
見た目のだけならばjQueryのshow/hideで切り替えることが出来る。
それぞれの違いとしてはDOMを適宜綺麗にしていくのでメモリを消費しにくい
しかし構築に時間がかかるかもしれない

renderが汚くなった！


* Modal
    要素がdocumentに無くても起動は可能
    ただしゴミがdocumentに溜まっていくので消していく必要あり

* GadgetMenuは分割するべきか

* Market

