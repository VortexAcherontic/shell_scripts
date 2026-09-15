#!/usr/bin/env python3
"""
Linux System Information Gatherer — pipe-separated output
Requires: Python 3.6+ (stdlib only)
Optional CLI tools: nvidia-smi, vulkaninfo, glxinfo
"""

import re
import shutil
import subprocess
from pathlib import Path


# ── Helpers ───────────────────────────────────────────────────────────────────

def run(cmd: list[str], timeout: int = 10) -> str | None:
    """Run a command, return stripped stdout or None on any failure."""
    if not shutil.which(cmd[0]):
        return None
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return r.stdout.strip() or None
    except (subprocess.TimeoutExpired, OSError):
        return None


# ── Collectors ────────────────────────────────────────────────────────────────

def get_kernel() -> str:
    return run(["uname", "-r"]) or "Unknown"


def get_distro() -> str:
    try:
        with open("/etc/os-release") as f:
            data = {}
            for line in f:
                line = line.strip()
                if "=" in line:
                    k, v = line.split("=", 1)
                    data[k] = v.strip('"')
        return data.get("PRETTY_NAME") or data.get("NAME") or "Unknown"
    except OSError:
        return run(["lsb_release", "-ds"]) or "Unknown"


def get_nvidia_gpu() -> str:
    if not shutil.which("nvidia-smi"):
        return "N/A"
    return run(["nvidia-smi", "--query-gpu=name", "--format=csv,noheader,nounits"]) or "Unknown"


def get_nvidia_driver() -> str:
    if not shutil.which("nvidia-smi"):
        return "N/A"
    return run(["nvidia-smi", "--query-gpu=driver_version", "--format=csv,noheader,nounits"]) or "Unknown"


def get_cuda_version() -> str:
    if not shutil.which("nvidia-smi"):
        return "N/A"
    header = run(["nvidia-smi"])
    if header:
        m = re.search(r"CUDA Version:\s*([\d.]+)", header)
        if m:
            return m.group(1)
    return "N/A"


def get_cpu() -> str:
    try:
        with open("/proc/cpuinfo") as f:
            for line in f:
                if line.startswith("model name"):
                    return line.split(":", 1)[1].strip()
    except OSError:
        pass
    lscpu = run(["lscpu"])
    if lscpu:
        m = re.search(r"Model name\s*:\s*(.+)", lscpu)
        if m:
            return m.group(1).strip()
    return "Unknown"


def get_ram() -> str:
    try:
        with open("/proc/meminfo") as f:
            for line in f:
                if line.startswith("MemTotal"):
                    kb = int(line.split()[1])
                    return f"{kb / 1024 / 1024:.1f} GiB"
    except OSError:
        pass
    return "Unknown"


def get_proton_version() -> str:
    """
    Scan /proc/<pid>/environ of all running processes for Proton-related
    environment variables set by Steam when launching a game with Proton.
    """
    patterns = [
        ("PROTON_VERSION", lambda v: v),
        ("WINELOADER",     lambda v: _extract_proton_ver(v)),
        ("WINE",           lambda v: _extract_proton_ver(v)),
        ("PROTON_PATH",    lambda v: _extract_proton_ver(v)),
    ]

    for pid_dir in Path("/proc").iterdir():
        if not pid_dir.name.isdigit():
            continue
        try:
            raw = (pid_dir / "environ").read_bytes()
            env = {}
            for entry in raw.split(b"\x00"):
                if b"=" in entry:
                    k, v = entry.split(b"=", 1)
                    env[k.decode(errors="replace")] = v.decode(errors="replace")

            for key, extractor in patterns:
                if key in env:
                    result = extractor(env[key])
                    if result:
                        return result
        except (PermissionError, FileNotFoundError, OSError):
            continue

    return "No active Proton game"


def _extract_proton_ver(path: str) -> str | None:
    """Pull a version number out of a Proton install path."""
    m = re.search(r"[Pp]roton[\s_-]?([\w.]+)", path)
    return f"Proton {m.group(1)}" if m else None


def get_vulkan_version() -> str:
    if not shutil.which("vulkaninfo"):
        return "N/A (install vulkan-tools)"
    out = run(["vulkaninfo", "--summary"])
    if out:
        # Prefer the instance-level version reported at the top
        m = re.search(r"Vulkan Instance Version:\s*([\d.]+)", out)
        if m:
            return m.group(1)
        # Fall back to device apiVersion, e.g. "4206803 (1.3.277)"
        m = re.search(r"apiVersion\s*=\s*\d+\s*\(([\d.]+)\)", out)
        if m:
            return m.group(1)
    return "Unknown"


def get_opengl_version() -> str:
    if not shutil.which("glxinfo"):
        return "N/A (install mesa-utils)"
    out = run(["glxinfo", "-B"])
    if out:
        m = re.search(r"OpenGL version string:\s*(.+)", out)
        if m:
            return m.group(1).strip()
    return "Unknown"


# ── Main ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    fields = [
        get_kernel(),
        get_distro(),
        get_nvidia_gpu(),
        get_nvidia_driver(),
        get_cuda_version(),
        get_cpu(),
        get_ram(),
        get_proton_version(),
        get_vulkan_version(),
        get_opengl_version(),
    ]

    output = " | ".join(fields)

    # ── Print to terminal ─────────────────────────────────────────────────────
    print(output)

    # ── Write to file ─────────────────────────────────────────────────────────
    out_path = Path.home() / ".local" / "share" / "systeminfo.txt"
    out_path.parent.mkdir(parents=True, exist_ok=True)

    out_path.write_text(output + "\n", encoding="utf-8")
    print(f"[✓] Saved to {out_path}")

