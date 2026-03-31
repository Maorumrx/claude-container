# Claude Dev Container

Dev Container สำหรับพัฒนาโปรเจกต์ร่วมกับ Claude Code CLI พร้อม ZSH, Node 24, และ extensions ที่จำเป็น

---

## สิ่งที่ต้องติดตั้งก่อน

| เครื่องมือ | ดาวน์โหลด |
|---|---|
| Docker Desktop | https://www.docker.com/products/docker-desktop |
| VS Code | https://code.visualstudio.com |
| VS Code Extension: Dev Containers | ค้นหา `ms-vscode-remote.remote-containers` ใน Extensions |

---

## ขั้นตอนการใช้งาน (ทำครั้งแรกครั้งเดียว)

### 1. ติดตั้ง Claude Code บนเครื่อง

> จำเป็นต้องทำก่อน เพราะ Container จะ mount โฟลเดอร์ `~/.claude` จากเครื่องคุณ

```bash
npm install -g @anthropic-ai/claude-code
claude
```

กด Enter เพื่อเปิด browser → Login ด้วย Anthropic account → รอจนขึ้น `✓ Logged in`

---

### 2. Clone repo นี้

```bash
git clone https://github.com/Maorumrx/claude-container.git
cd claude-container
```

---

### 3. ตั้งค่าข้อมูลส่วนตัว

Copy ไฟล์ตัวอย่าง:

```bash
# Mac / Linux
cp .env.example .env.local

# Windows (Command Prompt)
copy .env.example .env.local
```

เปิดไฟล์ `.env.local` แล้วแก้ให้เป็นข้อมูลของคุณ:

```env
GIT_CONFIG_NAME=ชื่อของคุณ
GIT_CONFIG_EMAIL=อีเมลของคุณ
```

---

### 4. เปิดใน VS Code

```bash
code .
```

VS Code จะถามว่า **"Reopen in Container?"** → กด **Reopen in Container**

> ครั้งแรกจะใช้เวลา build image ประมาณ 3–5 นาที ครั้งต่อไปจะเร็วมาก

---

### 5. รอ Container พร้อม

เมื่อ Terminal ใน VS Code ขึ้น prompt `➜ /workspace` แสดงว่าพร้อมใช้งานแล้ว

ทดสอบ Claude Code:

```bash
claude --version
```

---

## Windows (PowerShell/CMD) — ข้อควรระวัง

ค่า default ใน `.devcontainer/devcontainer.json` ตั้งมาสำหรับ **WSL / Mac / Linux** (`HOME`)

ถ้ารันจาก **Windows PowerShell หรือ CMD** (ไม่ใช่ WSL) ให้แก้บรรทัด mount:

```jsonc
// เปลี่ยนจาก
"source=${localEnv:HOME}/.claude, ..."

// เป็น
"source=${localEnv:USERPROFILE}/.claude, ..."
```

---

## รันด้วย Dev Container CLI (WSL / Terminal)

ใช้วิธีนี้แทนการกด "Reopen in Container" ใน VS Code ได้เลย

### ติดตั้ง CLI (ครั้งแรกครั้งเดียว)

```bash
npm install -g @devcontainers/cli
```

### รัน Container

```bash
# เข้าโฟลเดอร์โปรเจกต์ก่อน
cd /path/to/your-project

# build + start container
devcontainer up --workspace-folder .
```

### เปิด VS Code เชื่อมต่อกับ Container ที่รันอยู่

```bash
devcontainer open .
```

### รันคำสั่งใน Container โดยตรง (ไม่ต้องเปิด VS Code)

```bash
devcontainer exec --workspace-folder . zsh
```

---

## สิ่งที่ติดตั้งมาใน Container

| เครื่องมือ | รายละเอียด |
|---|---|
| Node.js 24 | JavaScript runtime |
| Claude Code CLI | `claude` command |
| ccusage | ดู Claude token usage |
| ZSH + Powerlevel10k | Shell สวยงาม |
| GitHub CLI (`gh`) | จัดการ GitHub จาก terminal |
| git-delta | diff ที่อ่านง่ายขึ้น |
| Python 3 | scripting |
| jq, tree, fzf | utility tools |

---

## ถ้ากรอก git config ผิด หรืออยากแก้ทีหลัง

แก้ไฟล์ `.env.local` แล้วรัน:

```bash
bash .devcontainer/scripts/setup.sh
```
