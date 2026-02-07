
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
