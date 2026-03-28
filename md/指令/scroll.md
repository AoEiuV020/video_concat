
1. 滚动的处理还是不行， 默认窗口高度压根不够放三个部件的，整理一下思路，考虑一般嵌套滚动要怎么处理，
1. 目前主页就是三个部分， 视频列表滚动，导出选项固定，导出命令窗口滚动， 
1. 我希望的效果是，导出选项这部分永远不离开屏幕，上下两个列表都能完全出屏只看另一个， 
1. 也就是默认情况上面的视频列表占满剩余空间，导出选项固定在底部，
1. 开始导出后导出选项固定在开头， 下面的命令窗口占满剩下空间，下拉导出选项可以把上面的视频列表拉出来， 
1. 先考虑有没有办法实现，给几个可行的方案， 考虑每个预计效果和优劣，

1. 超过五行不要直接回答，必须写到临时文档，这点写进`~/.copilot/copilot-instructions.md`

1. 临时文档不要做大段修改，新内容尽量保存新文档，更新instructions
1. 然后开始实现，

1. 拖动过程报错， 但拖动本身好像有效，

1. 红色框，
No Material widget found.
The ancestors of this widget were:
    : VideoListTile-[<'17746687334552310'>]
        dependencies: [InheritedCupertinoTheme, _InheritedTheme, _LocalizationsScope-[GlobalKey#6c410]]
    : MaterialApp
        state: _MaterialAppState#2d776
    : App
        dependencies: [_UncontrolledProviderScope]
        state: _ConsumerState#e0b19
    : ProviderScope
        state: ProviderScopeState#19f4b

1. 拖动没问题， 
1. 底部固定没有起到效果， 视频多了底部就被挤到屏幕外了，要滚动才会出现在列表最后，但我想要的是上面列表随便滚动，底部选项栏一直固定着，

1. 搞了半天你压根没明白我要的是什么， 
1. 生成时选项栏固定在顶部，下面是可滚动的命令窗，但继续下拉往上滚要能把视频列表滚下来，

1. 完全不行， 我本意是选项夹在视频列表和命令窗中间， 
1. 但是算了， 仔细想想把命令窗放在视频列表最后一起滚动效果似乎就可以， 
1. 就是命令窗黑底部分是个独立的子列表单独滚动， 粉底的整个块和视频列表一起滚动， 
1. 总之就是导出栏一直固定在最底部，

1. 就是这样， 更新规划文档`md/规划/通用`，注意通用，详细描写当前设计，
