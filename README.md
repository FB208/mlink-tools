# Windows Symlink Manager

一个简单的 Windows 软链接管理工具。

## 使用方法

1. 下载并解压所有文件到任意目录
2. 双击 `start.bat` 运行程序
3. 首次运行时会请求管理员权限（创建软链接需要管理员权限）

## 功能特色

- 快速创建和删除软连接
- 基于PowerShell打造，超轻量仅9K，无任何环境依赖    
- 支持图形化界面

## 注意事项

- PowerShell对中文支持实在是不友好，没有做汉化
- 所有创建的软链接信息都保存在同目录下的 symlinks.json 文件中，请勿删除
- 启动项目可能会报错`. : 无法加载文件 C:\Users\87897\Documents\WindowsPowerShell\profile.ps1，因为在此系统上禁止运行脚本。`,并不影响使用
- 实在看着难受，可以执行命令`set-ExecutionPolicy RemoteSigned`来解决报错

## 系统要求

- Windows 7 或更高版本
- PowerShell 3.0 或更高版本 