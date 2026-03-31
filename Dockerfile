ARG NODE_VERSION=24
FROM node:${NODE_VERSION}

ARG TZ=Asia/Bangkok
ENV TZ="$TZ"
ENV DEVCONTAINER=true

# ─── System packages (cache layer — เปลี่ยนน้อยมาก) ───────────────────────────
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

# Python (แยก layer เพราะ --fix-missing อาจ fail แล้ว fallback)
RUN apt-get update && apt-get install -y --fix-missing python3-full python3-pip || true \
  && rm -rf /var/lib/apt/lists/*

# ─── git-delta (cache layer) ───────────────────────────────────────────────────
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

# ─── ZSH + Powerlevel10k (cache layer — ไม่ต้อง rebuild ถ้าไม่เปลี่ยน) ────────
# ใช้ hash ตาย version ป้องกัน re-download โดยไม่จำเป็น
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# ─── Claude Code CLI (cache layer — แยก ARG ไว้ท้ายสุด) ──────────────────────
# วางไว้ท้ายสุดเพราะเปลี่ยนบ่อย (version update) จะได้ไม่ invalidate layer ข้างบน
ARG INSTALL_CLAUDE_CLI=true
RUN if [ "$INSTALL_CLAUDE_CLI" = "true" ]; then \
  npm install -g @anthropic-ai/claude-code; \
  npm install -g ccusage@latest; \
  fi

# ─── Git config (ทำท้ายสุด เพราะเปลี่ยนได้บ่อย) ──────────────────────────────
ARG GIT_CONFIG_EMAIL="user@example.com"
ARG GIT_CONFIG_NAME="Developer"
RUN git config --global user.email "$GIT_CONFIG_EMAIL" && \
  git config --global user.name "$GIT_CONFIG_NAME"