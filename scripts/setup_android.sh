#!/usr/bin/env bash
set -euo pipefail

flutter create . --platforms=android --org com.lookup

python3 - <<'PY'
from pathlib import Path
import re


DESUGAR_VERSION = "2.1.4"


def _line_ending(text: str) -> str:
    return "\r\n" if "\r\n" in text else "\n"


def _find_block_end(text: str, start_brace_idx: int) -> int:
    depth = 0
    for i in range(start_brace_idx, len(text)):
        ch = text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
    raise ValueError("Unbalanced braces in Gradle file")


def _ensure_compile_option(text: str, *, kotlin: bool) -> tuple[str, bool]:
    marker = "compileOptions {"
    start = text.find(marker)
    if start == -1:
        return text, False

    open_brace = text.find("{", start)
    close_brace = _find_block_end(text, open_brace)
    block = text[start : close_brace + 1]

    option = (
        "isCoreLibraryDesugaringEnabled = true"
        if kotlin
        else "coreLibraryDesugaringEnabled true"
    )
    if option in block:
        return text, False

    nl = _line_ending(text)
    lines = block.splitlines()
    closing_indent = re.match(r"\s*", lines[-1]).group(0)
    lines.insert(-1, f"{closing_indent}    {option}")
    updated_block = nl.join(lines)
    return text[:start] + updated_block + text[close_brace + 1 :], True


def _ensure_desugar_dependency(text: str, *, kotlin: bool) -> tuple[str, bool]:
    line = (
        f'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:{DESUGAR_VERSION}")'
        if kotlin
        else f'coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:{DESUGAR_VERSION}"'
    )
    if line in text:
        return text, False

    nl = _line_ending(text)
    marker = "dependencies {"
    start = text.find(marker)
    if start != -1:
        open_brace = text.find("{", start)
        close_brace = _find_block_end(text, open_brace)
        line_start = text.rfind(nl, 0, close_brace)
        if line_start == -1:
            line_start = 0
        else:
            line_start += len(nl)
        closing_indent = re.match(r"\s*", text[line_start:close_brace]).group(0)
        insertion = f"{closing_indent}    {line}{nl}"
        return text[:close_brace] + insertion + text[close_brace:], True

    block = f"{nl}dependencies {{{nl}    {line}{nl}}}{nl}"
    return text + block, True


def _patch_gradle(path: Path, *, kotlin: bool) -> None:
    text = path.read_text(encoding="utf-8")
    text, changed_a = _ensure_compile_option(text, kotlin=kotlin)
    text, changed_b = _ensure_desugar_dependency(text, kotlin=kotlin)
    if changed_a or changed_b:
        path.write_text(text, encoding="utf-8")


gradle_kts = Path("android/app/build.gradle.kts")
gradle_groovy = Path("android/app/build.gradle")

if gradle_kts.exists():
    _patch_gradle(gradle_kts, kotlin=True)
elif gradle_groovy.exists():
    _patch_gradle(gradle_groovy, kotlin=False)
else:
    raise SystemExit("Could not find android/app/build.gradle(.kts) after flutter create")
PY

cp tooling/android/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
cp tooling/android/google_maps_api.xml android/app/src/main/res/values/google_maps_api.xml
