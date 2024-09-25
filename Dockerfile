# 第一阶段：构建
FROM --platform=linux/arm64 node:alpine as builder

# 设置工作目录
WORKDIR /opt/raneto

# 安装 Git 和构建工具
RUN echo "https://mirrors.aliyun.com/alpine/v3.19/main/" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.19/community/" >> /etc/apk/repositories && \
    apk update
RUN apk add --no-cache git python3 make g++
RUN npm config set registry https://mirrors.huaweicloud.com/repository/npm/ && npm install -g gulp-cli
#RUN npm install -g gulp-cli

#修改版本支持中文
RUN git clone --depth 1 https://gitclone.com/github.com/ly55521/Raneto.git .

# 安装所有依赖项
RUN npm install --omit=dev
RUN npm install lunr-languages

# 运行 Gulp 构建任务
RUN gulp

# 第二阶段：运行
FROM --platform=linux/arm64 node:alpine

# 设置工作目录
WORKDIR /opt/raneto

# 从构建阶段复制 Node.js 应用程序和 node_modules
COPY --from=builder /opt/raneto .

# 暴露 Raneto 默认端口
EXPOSE 3000

# 将配置和内容目录设置为卷，以便可以从 Docker 主机映射
VOLUME ["/opt/raneto/config", "/opt/raneto/content"]

# 定义运行时的命令
CMD [ "npm", "start" ]
