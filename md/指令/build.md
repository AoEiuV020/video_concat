
1. 添加一个skill到.claude/skills ， 用于build编译测试，修改代码确认提交前执行，
1. 在skill中简单介绍flutter build debug，然后添加一个dart脚本用于执行flutter build并过滤输出，
1. 注意脚本代码不要拥挤，要注意可读性，拆分多文件，入口/编译/过滤都要分开，
1. 先编译一次把完整输出保存到临时文件，用于测试过滤， 过滤需要确保错误信息简单的保留下来，其他全部丢弃， 包括警告，
1. 如果编译成功， 直接输出编译成功， 不要多余内容， 
1. 最终的脚本要能简单调用只有一个必填参数是app模块相对路径，
1. 注意如果有可能相对通用的代码要转移到/lib目录以便复用，

1. .claude/skills/flutter-build/SKILL.md:8 不该强调mac，应该根据系统自动决定，
1. AGENTS.md:3 也要调整， 只说根据某skill执行编译，不用讲具体内容，

1. 我说”通用“的才能放在/lib， 只和build相关的当然不算通用了，

1. 禁止对`md/指令`进行任何操作， 有变化就一起提交，禁止查看内容，这点写进 AGENTS.md 一行说清楚，

1. 新增了 .claude/skills/git-commit/SKILL.md ，查看并注意后续遵守，
1. 然后删除 AGENTS.md:4 

1. .claude/skills/flutter-build/SKILL.md:13 skill禁止强调skill所在路径，用尖括号意思一下， 参考template-sync，

1. 不是这样啊， 你到底参考没有， 我让你别写skill路径， 不是别写script路径，
