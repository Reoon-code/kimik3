# KimiK3-4G - Windows Quick Start

## 1. Install MSYS2

Install MSYS2 to the default folder:

```text
C:\msys64
```

Open **MSYS2 MINGW64** and run:

```bash
pacman -Syu
pacman -S --needed git make mingw-w64-x86_64-gcc python
```

## 2. Build from PowerShell

Open PowerShell / Windows Terminal in the `kimik3-4gb` folder:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\bootstrap-windows.ps1
```

Or from CMD:

```bat
scripts\bootstrap.cmd
```

## 3. Expected model folders

Example:

```text
D:\AI\KimiK3\model
D:\AI\KimiK3\trunk
```

The official checkpoint + packed trunk still needs roughly **1.7 TB SSD space**.

## 4. Run from PowerShell

```powershell
.\scripts\run-4gb.ps1 `
  -Model "D:\AI\KimiK3\model" `
  -Trunk "D:\AI\KimiK3\trunk" `
  -Tok "D:\AI\KimiK3\model" `
  -Prompt "The capital of France is" `
  -Gen 1 `
  -Threads 2
```

## 5. Run from CMD

```bat
scripts\run-4gb.cmd -Model "D:\AI\KimiK3\model" -Trunk "D:\AI\KimiK3\trunk" -Tok "D:\AI\KimiK3\model" -Prompt "Hello" -Gen 1 -Threads 2
```

## 6. Run from MSYS2 MINGW64 terminal

```bash
bash scripts/run-4gb.sh \
  --model /d/AI/KimiK3/model \
  --trunk /d/AI/KimiK3/trunk \
  --tok /d/AI/KimiK3/model \
  --prompt "Hello" \
  --gen 1
```

## 7. Verify

PowerShell:

```powershell
.\scripts\verify-windows.ps1
```

CMD:

```bat
scripts\verify.cmd
```

## 8. 4 GB Windows settings

- Keep Windows page file enabled; **8-16 GB page file** is recommended.
- Close browsers, IDEs, Docker Desktop and WSL VMs.
- Start with `-Gen 1` and `-Threads 2`.
- Use a fast NVMe SSD.
- The low-memory profile always forces `--preset ultra --ultra-low-memory`.
- Upstream measured the inference process around **2.57 GiB peak RSS**, but Windows itself also needs RAM.
