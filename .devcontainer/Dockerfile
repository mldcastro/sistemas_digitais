FROM ubuntu:24.04

# Prevent interactive prompts during apt installations
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install TerosHDL backend requirements and EDA tools
RUN apt update && apt install -y \
    # Core build tools
    build-essential \
    make \
    git \
    wget \
    curl \
    # VHDL & Verilog Simulators / Linters
    ghdl \
    gtkwave \
    verilator \
    iverilog \
    # Native Yosys + GHDL Plugin for VHDL Schematic Viewer
    yosys \
    yosys-plugin-ghdl \
    # Graphviz: REQUIRED by TerosHDL for state machine diagrams
    graphviz \
    # Python tools and headers
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Ubuntu 24.04 strictly enforces PEP 668, so we must use a virtual environment
# to install Python packages globally inside the container.
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install VUnit and YoWASP Yosys
# YoWASP puts a 'yosys' wrapper directly into the venv PATH so TerosHDL finds it automatically
RUN pip install --no-cache-dir \
    vunit-hdl \
    edalize \
    cocotb \
    vsg

# Create a non-root user (Standard practice for VS Code Devcontainers)
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=1000

# Give the ubuntu user sudo access for installing things later if needed
RUN apt-get update && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Set the default user
USER $USERNAME
