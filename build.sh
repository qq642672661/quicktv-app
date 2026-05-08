#!/bin/bash

echo "=========================================="
echo "QuickTV 快应用打包脚本"
echo "=========================================="

if [ ! -d "node_modules" ]; then
    echo "正在安装依赖..."
    npm install
fi

echo "正在清理旧的构建文件..."
rm -rf dist build

echo "正在构建快应用..."
npm run build

if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "构建成功！"
    echo "输出目录: dist/"
    echo "=========================================="
    
    if [ -f "dist/com.quicktv.app.rpk" ]; then
        echo "RPK 包已生成: dist/com.quicktv.app.rpk"
        echo "文件大小: $(du -h dist/com.quicktv.app.rpk | cut -f1)"
    fi
else
    echo "=========================================="
    echo "构建失败，请检查错误信息"
    echo "=========================================="
    exit 1
fi
