# neovim

## 一、安装 neovim

参考官方文档：https://github.com/neovim/neovim/blob/master/INSTALL.md

### 1、Windows 安装

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



## 二、安装 neovim  插件依赖

### 1、windows

```
scoop update
# 安装 fzf
scoop install fzf

# 安装 yazi 和依赖
scoop install yazi
scoop install ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick
```



### 2、Debian Ubuntu yazi安装待完成

```
sudo apt update

# 安装 fzf
sudo apt install fzf

# 使用二进制文件下载安装 yazi
curl -LO https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip
sudo rm -rf yazi-temp
sudo unzip yazi-x86_64-unknown-linux-musl.zip -d yazi-temp
sudo mv yazi-temp/yazi-x86_64-unknown-linux-musl/{ya,yazi} /usr/local/bin

sudo apt install ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick -y
```



## 二、安装 neovim  插件

### 1、windows

```
# 环境变量
Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak

# 根据情况备份
Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak

# 克隆配置
git clone git@gitee.com:jiaopengzi/nvim.git $env:LOCALAPPDATA\nvim
```



### 2、Debian Ubuntu

```
# 备份
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}

# 克隆配置
git clone git@gitee.com:jiaopengzi/nvim.git ~/.config/nvim
```





执行`nvim`，安装插件。



