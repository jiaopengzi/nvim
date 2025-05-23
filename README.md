# neovim

## 一、安装 neovim

参考官方文档：https://github.com/neovim/neovim/blob/master/INSTALL.md

### 1、Windwos 安装

在 windows 中使用 scoop 安装。

```
scoop bucket add main
scoop install neovim
```

### 2、Debian Ubuntu 安装

```
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim*
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
```



环境变量

```
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
source ~/.bashrc
```



### 3、查看nvim版本信息

```
 nvim -v
```



## 二、安装插件

### 1、windows

```
# 环境变量
Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak

# 根据情况备份
Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak

# 克隆配置
git clone https://gitee.com/jiaopengzi/nvim $env:LOCALAPPDATA\nvim
```



### 2、Debian Ubuntu

```
# 备份
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}

# 克隆配置
git clone https://gitee.com/jiaopengzi/nvim ~/.config/nvim
```





执行`nvim`，安装插件。使用 `:LazyHealth`检查健康状况
