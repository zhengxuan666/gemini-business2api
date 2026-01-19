import importlib.util
import re
from pathlib import Path


def patch_undetected_chromedriver() -> bool:
    spec = importlib.util.find_spec("undetected_chromedriver")
    if spec is None or not spec.origin:
        return False

    module_path = Path(spec.origin).resolve()
    patcher_path = module_path.parent / "patcher.py"
    if not patcher_path.exists():
        return False

    content = patcher_path.read_text(encoding="utf-8")
    original = content

    content = content.replace(
        "from distutils.version import LooseVersion",
        "from packaging.version import parse as parse_version",
    )
    content = re.sub(r"\bLooseVersion\(", "parse_version(", content)

    if content != original:
        patcher_path.write_text(content, encoding="utf-8")
        return True

    return False


if __name__ == "__main__":
    changed = patch_undetected_chromedriver()
    print("patched" if changed else "no-change")
