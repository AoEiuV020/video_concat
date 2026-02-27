
1. 严格遵守相关skill中的要求，
1. 先设计生成详细的文档到`md/规划/通用/`， 
1. 然后设计flutter版文档，决定具体的库的使用，
1. 先不生成代码，

# app

mvvm架构，

## 主页
1. 列表，一行一个视频，最核心的功能需要最简单的使用，不要二次确认，
- 添加视频（支持拖动添加），
- 删除视频，
- 拖动排序，不要item长按，单独拖动按钮，
- 自动生成输出文件名，可修改名字和后缀分开，持久化记住后缀修改，
- 确认生成，查看命令输出，

## 设置页
1. 设置ffmpeg所在，

# ffmpeg模块
1. 需要能传入ffmpeg路径，
1. 核心支持接受命令参数，执行ffmpeg命令，接收命令输出，打断，
1. 额外支持视频合并相关的简化封装函数，


1. flutter文档参考 ln/git/md_mvvm/md/规划/flutter 尽量使用相同技术栈，

1. md/规划/flutter/实现设计.md 设计不要直接编写实现代码，只要体现设计和技术栈库，这约束更新到ln/AI/skills/docs-style/SKILL.md
1. md/规划/通用/架构设计.md 接口命名Base挺糟糕的，更新 ln/AI/skills/mvvm-guide/SKILL.md vmBase是给基类用的，用于大型vm拆分时的基类，这不是接口， 想办法描述清楚，

1. 权限配置，

1. 默认目录，
1. mac沙盒，ffmpeg执行权限怎么处理好，具体怎么做，

1. 没用， 不必要的话删了，
1. 我听说有个“com.apple.security.files.user-selected.executable“，有用没？

1. 还是得关闭沙盒才可以，难搞，
1. 参考 https://www.dididigu.com/posts/mac-app-upload-and-sandbox-notes/ 看看有没有什么办法？

1. 我已经关闭沙盒了， 你看看还有什么没用的可以删掉，

1. 啥玩意儿连read-write都是不需要的吗？

1. 到最后我也没搞明白 com.apple.security.files.user-selected.executable 的用途， 

1. 写入文件还是需要权限， 报错了， ‘PlatformException (PlatformException(ENTITLEMENT_REQUIRED_WRITE, The Read-Write entitlement is required for this action., null, null))’

1. 写个readme， 重点强调不重新编码，以及要求视频片段是完全相同的参数， 具体列出哪些可能有影响的参数，

1. 系统要求， 理论上桌面版应该都支持？只测试了mac版， 这些都写上，
1. 顺便检查一下当前代码在windows是否会有问题， 

1. 关于windows， 参考如下脚本， 这是测试可行的，本应用尽量使用相同的处理，
```
@echo off
set bin=%~dp0
set old_path=%cd%
set name=%~dpn1
set out=%~dpnx1
set a=%~dpnx2
set b=%~dpnx3
if "x%a%" neq "x" (
    if "x%b%" neq "x" (
    echo file '%a:\=/%' > %name%.merge_files
    echo file '%b:\=/%' >> %name%.merge_files
    call %0 %1
    del %name%.merge_files
    goto end:
    )
)

%bin%ffmpeg -safe 0 -f concat -i "%name%.merge_files" -vcodec copy -acodec copy "%out:\=/%"

:end
```

1. 目标文件已存在时ffmpeg会停下询问y/n，这个没法处理，看能不能阻止ffmpeg提问， 最差也应该先删除目标文件再开始任务，
1. 强行中止ffmpeg无效，

1. 目前强行中断的情况也显示了”合并完成“，

1. 每个item添加文件大小显示， 最终合并文件预计大小也显示，

1. 重复代码必须封装，比如格式化文件大小，

1. 添加github ci自动打包，

1. 一键重置，开始新任务，
1. 第一次进入设置页不要直接显示不可用，
1. 检查文件名，如果不是字典序，变色提示，
1. 注意每一小点都要提交git，

1. 所有，能清除的都要清除，就和刚启动一样，

1. 为什么你依然把计划创建到了会话目录，没有遵守docs-style skill， 调整 ~/.claude/skills/docs-style/SKILL.md:3 务必确保你自己能在创建计划时遵守，

1. AGENTS.md 添加一行，提交代码前需要运行编译`flutter build macos --build`

1. AGENTS.md 中的星号太多了， 没用，都删了，
