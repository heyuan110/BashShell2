#!/bin/bash

# 检查origin目录是否存在
if [ ! -d "origin" ]; then
    echo "错误：origin目录不存在。"
    exit 1
fi

# 创建输出目录
mkdir -p out

# 遍历origin目录中的所有MP4文件
for file in origin/*.mp4; do
    if [ -f "$file" ]; then
        # 提取文件名（不含路径和扩展名）
        filename=$(basename "$file" .mp4)
        output_file="out/${filename}_1080p.mp4"
        
        # 检查输出文件是否已存在
        if [ -f "$output_file" ]; then
            echo "跳过已处理文件：$file → $output_file"
            continue
        fi

        echo "正在处理：$file → $output_file"

        # 执行FFmpeg压缩命令（关键改动在 scale 滤镜），注意要强制宽度为偶数，高度固定为1080
        if ! ffmpeg -y -i "$file" \
            -vf "scale=trunc(iw/2)*2:1080" \
            -codec:v libx264 -crf 24 -preset slow \
            -g 60 -keyint_min 60 \
            -b:v 2000k -maxrate 2500k -bufsize 5000k \
            -b:a 100k -ar 44100 \
            -f mp4 -movflags +faststart \
            "$output_file"; then
            echo "错误：处理 $file 失败"
        else
            echo "已生成：$output_file"
        fi
    fi
done

echo "所有视频处理完成！"