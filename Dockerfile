# Dockerfile

# 使用官方 Python 基础镜像
# 推荐使用 slim-buster 版本，因为它体积更小
FROM python:3.9-slim-buster

# 设置工作目录
# 您的所有项目文件都将放在这个目录下
WORKDIR /app

# 将 requirements.txt 复制到容器中
COPY requirements.txt .

# 安装所有 Python 依赖
# 使用 --no-cache-dir 可以节省空间
RUN pip install --no-cache-dir -r requirements.txt

# --- START: 为 keras-rl2 解决 TensorFlow 兼容性问题打补丁 ---
# 这个补丁会修改 keras-rl2 内部的文件，解决 ImportError: cannot import name '__version__' from 'tensorflow.keras'
# 它将尝试从 'keras' 包而不是 'tensorflow.keras' 导入 __version__
# 确保 /usr/local/lib/python3.9/site-packages/rl/callbacks.py 路径正确
RUN sed -i 's/from tensorflow.keras import __version__ as KERAS_VERSION/from keras import __version__ as KERAS_VERSION/g' /usr/local/lib/python3.9/site-packages/rl/callbacks.py
# --- END: 补丁代码 ---

# 将您的项目代码复制到容器中
# 假设您的所有项目文件都在当前目录下
COPY . .

# 如果您打算在 Docker 容器中运行 Jupyter Notebook，请暴露 8888 端口
# Jupyter 默认运行在 8888 端口
EXPOSE 8888

# 定义容器启动时的默认命令
# 这里可以根据您的主要用途来选择
# 选项 1: 如果主要运行 Python 脚本
# CMD ["python", "your_main_script.py"]

# 选项 2: 如果主要使用 Jupyter Notebook 进行开发
# 这将在容器启动时自动启动 Jupyter 服务
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]

# 如果您还需要其他系统级的依赖（例如特定编译器或库），
# 可以在这里添加 RUN apt-get update && apt-get install -y <package-name> 命令。
# 但对于纯 Python ML 项目，通常不太需要。