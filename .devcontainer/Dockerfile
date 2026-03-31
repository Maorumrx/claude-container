ARG NODE_VERSION=24
FROM node:${NODE_VERSION}

ARG TZ=Asia/Bangkok
ENV TZ="$TZ"
ENV DEVCONTAINER=true

# ─── Proxy (optional) ──────────────────────────────────────────────────────────
# ส่งผ่าน build args: --build-arg HTTP_PROXY=http://proxy:port
ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""
ARG NO_PROXY="localhost,127.0.0.1"
ENV HTTP_PROXY=$HTTP_PROXY \
    HTTPS_PROXY=$HTTPS_PROXY \
    http_proxy=$HTTP_PROXY \
    https_proxy=$HTTPS_PROXY \
    NO_PROXY=$NO_PROXY \
    no_proxy=$NO_PROXY

# ─── System packages ───────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
  less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  gh \
  jq \
  tree \
  dnsutils \
  && rm -rf /var/lib/apt/lists/*

# Python
RUN apt-get update && apt-get install -y --fix-missing python3-full python3-pip || true \
  && rm -rf /var/lib/apt/lists/*

# ─── git-delta ─────────────────────────────────────────────────────────────────
RUN ARCH=$(dpkg --print-architecture) && \
  wget -q "https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_${ARCH}.deb" && \
  dpkg -i "git-delta_0.18.2_${ARCH}.deb" && \
  rm "git-delta_0.18.2_${ARCH}.deb" || echo "git-delta install skipped"

# ─── Directory & permissions ───────────────────────────────────────────────────
ARG USERNAME=node

RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

RUN mkdir /commandhistory && \
  touch /commandhistory/.bash_history && \
  chown -R $USERNAME /commandhistory

RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

# ─── Switch to node user ───────────────────────────────────────────────────────
USER node

ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin
ENV SHELL=/bin/zsh

# ─── npm proxy config (ถ้ามี proxy จะ set อัตโนมัติ) ─────────────────────────
RUN if [ -n "$HTTP_PROXY" ]; then \
  npm config set proxy "$HTTP_PROXY"; \
  npm config set https-proxy "$HTTPS_PROXY"; \
  npm config set noproxy "$NO_PROXY"; \
  echo "npm proxy set to $HTTP_PROXY"; \
  fi

# ─── ZSH + Powerlevel10k ───────────────────────────────────────────────────────
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Claude Code CLI จะถูก install ใน postCreateCommand (setup.sh)
# เพื่อให้ proxy ทำงานได้ถูกต้องและไม่ block Docker build
