from __future__ import annotations

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


REPO_ROOT = Path(__file__).resolve().parents[1]
PATCH_ROOT = REPO_ROOT / "Addon PATCHES"

LANG_GUARD = """local function TamrielKR_IsKoreanClient()
\tif TamrielKR and TamrielKR.GetLanguage then
\t\tlocal ok, lang = pcall(TamrielKR.GetLanguage, TamrielKR)
\t\tif ok and lang == "kr" then
\t\t\treturn true
\t\tend
\tend
\treturn GetCVar("language.2") == "kr"
end

if not TamrielKR_IsKoreanClient() then
\treturn
end

"""

PATCHES = {
    "ActionDurationReminder-KR-Minion": {
        "title": "ActionDurationReminder - Korean Patch",
        "description": "Standalone Korean patch for ActionDurationReminder.",
        "depends_on": "ActionDurationReminder",
        "api_version": "101049",
        "install_mode": "standalone",
        "files": [
            "ActionDurationReminder/i18n/kr.lua",
        ],
    },
    "Azurah-KR-Minion": {
        "title": "Azurah - Korean Patch",
        "description": "Standalone Korean patch for Azurah.",
        "depends_on": "Azurah",
        "api_version": "101049",
        "install_mode": "standalone",
        "files": [
            "Azurah/Locales/Korean_kr.lua",
        ],
    },
    "BanditsUserInterface-KR-Minion": {
        "title": "BanditsUserInterface - Korean Patch",
        "description": "Overwrite-only Korean patch for BanditsUserInterface.",
        "depends_on": "BanditsUserInterface",
        "api_version": "101049",
        "install_mode": "overwrite",
        "output_zip": "BanditsUserInterface-KR-Overwrite.zip",
        "files": [
            "BanditsUserInterface/BUI_Vars.lua",
            "BanditsUserInterface/BUI_Controls.lua",
            "BanditsUserInterface/BUI_Menu.lua",
            "BanditsUserInterface/BUI_Settings.lua",
            "BanditsUserInterface/BUI_Automation.lua",
            "BanditsUserInterface/BUI_Initialize.lua",
            "BanditsUserInterface/lang/kr.lua",
        ],
    },
    "Destinations-KR-Minion": {
        "title": "Destinations - Korean Patch",
        "description": "Standalone Korean patch for Destinations.",
        "depends_on": "Destinations",
        "api_version": "101049",
        "install_mode": "standalone",
        "files": [
            "Destinations/data/kr/DestinationsCollectibles_kr.lua",
            "Destinations/data/kr/DestinationsSettings_kr.lua",
        ],
    },
    "DolgubonsLazyWritCreator-KR-Minion": {
        "title": "DolgubonsLazyWritCreator - Korean Patch",
        "description": "Standalone Korean patch for DolgubonsLazyWritCreator.",
        "depends_on": "DolgubonsLazyWritCreator",
        "api_version": "101049",
        "install_mode": "standalone",
        "files": [
            "DolgubonsLazyWritCreator/Languages/kr.lua",
        ],
    },
    "FancyActionBarPlus-KR-Minion": {
        "title": "FancyActionBar+ - Korean Patch",
        "description": "Overwrite-only Korean patch for FancyActionBar+.",
        "depends_on": "FancyActionBar+",
        "api_version": "101049",
        "install_mode": "overwrite",
        "output_zip": "FancyActionBarPlus-KR-Overwrite.zip",
        "files": [
            "FancyActionBar+/lang/kr.lua",
            "FancyActionBar+/menu.lua",
        ],
    },
    "HarvestMap-KR-Minion": {
        "title": "HarvestMap - Korean Patch",
        "description": "Standalone Korean patch for HarvestMap.",
        "depends_on": "HarvestMap",
        "api_version": "101049",
        "install_mode": "standalone",
        "files": [
            "HarvestMap/Modules/HarvestMap/Localization/kr.lua",
        ],
    },
    "LibAddonMenu-2.0-KR-Minion": {
        "title": "LibAddonMenu-2.0 - Korean Patch",
        "description": "Overwrite-only Korean patch for LibAddonMenu-2.0.",
        "depends_on": "LibAddonMenu-2.0",
        "api_version": "101049",
        "install_mode": "overwrite",
        "output_zip": "LibAddonMenu-2.0-KR-Overwrite.zip",
        "files": [
            "LibAddonMenu-2.0/LibAddonMenu-2.0.lua",
        ],
    },
    "LibSavedVars-KR-Minion": {
        "title": "LibSavedVars - Korean Patch",
        "description": "Standalone Korean patch for LibSavedVars.",
        "depends_on": "LibSavedVars",
        "api_version": "101049",
        "install_mode": "standalone",
        "files": [
            "LibSavedVars/localization/kr.lua",
        ],
    },
    "LostTreasure-KR-Minion": {
        "title": "LostTreasure - Korean Patch",
        "description": "Standalone Korean patch for LostTreasure.",
        "depends_on": "LostTreasure",
        "api_version": "101049",
        "install_mode": "standalone",
        "files": [
            "LostTreasure/lang/kr.lua",
        ],
    },
    "pChat-KR-Minion": {
        "title": "pChat - Korean Patch",
        "description": "Standalone Korean patch for pChat.",
        "depends_on": "pChat",
        "api_version": "101049",
        "install_mode": "standalone",
        "files": [
            "pChat/i18n/kr.lua",
        ],
    },
    "TamrielTradeCentre-KR-Minion": {
        "title": "TamrielTradeCentre - Korean Patch",
        "description": "Standalone Korean patch for TamrielTradeCentre.",
        "depends_on": "TamrielTradeCentre",
        "api_version": "101049",
        "install_mode": "standalone",
        "files": [
            "TamrielTradeCentre/ItemLookUpTable_kr.lua",
            "TamrielTradeCentre/lang/kr.lua",
        ],
    },
    "USPF-KR-Minion": {
        "title": "USPF - Korean Patch",
        "description": "Overwrite-only Korean patch for USPF.",
        "depends_on": "USPF",
        "api_version": "101048",
        "install_mode": "overwrite",
        "output_zip": "USPF-KR-Overwrite.zip",
        "files": [
            "USPF/lang/strings.lua",
            "USPF/lang/kr.lua",
            "USPF/USPF_Menu.lua",
            "USPF/USPF.lua",
        ],
    },
    "VotansMiniMap-KR-Minion": {
        "title": "VotansMiniMap - Korean Patch",
        "description": "Overwrite-only Korean patch for VotansMiniMap.",
        "depends_on": "VotansMiniMap",
        "api_version": "101044 101045",
        "install_mode": "overwrite",
        "output_zip": "VotansMiniMap-KR-Overwrite.zip",
        "files": [
            "VotansMiniMap/lang/strings.lua",
            "VotansMiniMap/lang/kr.lua",
            "VotansMiniMap/Settings.lua",
            "VotansMiniMap/PinLevels.lua",
            "VotansMiniMap/PinSizes.lua",
            "VotansMiniMap/Styles.lua",
        ],
    },
}


def read_text_preserve_bom(path: Path) -> tuple[str, bytes]:
    data = path.read_bytes()
    bom = b""
    if data.startswith(b"\xef\xbb\xbf"):
        bom = b"\xef\xbb\xbf"
        data = data[3:]
    return data.decode("utf-8"), bom


def write_text_preserve_bom(path: Path, text: str, bom: bytes) -> None:
    encoded = text.encode("utf-8")
    path.write_bytes(bom + encoded)


def ensure_guard(path: Path) -> None:
    text, bom = read_text_preserve_bom(path)
    if "TamrielKR_IsKoreanClient" in text:
        return
    write_text_preserve_bom(path, LANG_GUARD + text, bom)


def get_install_mode(config: dict[str, str | list[str]]) -> str:
    return str(config["install_mode"])


def get_output_zip_name(package: str, config: dict[str, str | list[str]]) -> str:
    return str(config.get("output_zip", f"{package}.zip"))


def get_addon_root(config: dict[str, str | list[str]]) -> str:
    first_file = str(config["files"][0])
    return first_file.split("/", 1)[0]


def build_manifest(config: dict[str, str | list[str]]) -> str:
    lines = [
        f"## Title: {config['title']}",
        f"## Description: {config['description']}",
        "## Version: 1.0.0",
        "## AddOnVersion: 10000",
        "## Author: TamrielKR",
        f"## APIVersion: {config['api_version']}",
        f"## DependsOn: {config['depends_on']}",
        "## OptionalDependsOn: TamrielKR",
        "",
    ]
    lines.extend(config["files"])
    lines.append("")
    return "\n".join(lines)


def build_readme(config: dict[str, str | list[str]]) -> str:
    file_list = "\n".join(f"- `{path}`" for path in config["files"])
    install_mode = get_install_mode(config)

    if install_mode == "standalone":
        return (
            f"# {config['title']}\n\n"
            "이 패키지는 Minion/ESOUI 배포를 위한 독립 한국어 패치 애드온입니다.\n\n"
            "## 설치 방법\n\n"
            f"1. 원본 애드온 `{config['depends_on']}`를 먼저 설치합니다.\n"
            "2. 이 패키지를 `AddOns` 폴더에 별도 폴더로 풀어 설치합니다.\n"
            "3. TamrielKR 환경에서는 한국어일 때만 자동 적용됩니다.\n\n"
            "## 포함 파일\n\n"
            f"{file_list}\n\n"
            "## 비고\n\n"
            f"- `## DependsOn: {config['depends_on']}` 기반으로 원본 애드온 다음에 로드됩니다.\n"
            "- 패치 파일은 비한글 환경에서 즉시 종료되도록 가드가 들어 있습니다.\n"
            "- 원본 폴더에 직접 덮어쓰지 않는 Minion 친화적 구조입니다.\n"
        )

    addon_root = get_addon_root(config)
    return (
        f"# {config['title']}\n\n"
        "이 패키지는 현재 독립 `-KR` 애드온으로는 안전하지 않아 원본 폴더에 덮어써야 하는 한국어 패치입니다.\n\n"
        "## 설치 방법\n\n"
        f"1. 원본 애드온 `{config['depends_on']}`를 먼저 설치합니다.\n"
        "2. 게임을 종료합니다.\n"
        f"3. 압축 안의 `{addon_root}` 폴더 내용을 `AddOns` 안의 원본 `{config['depends_on']}` 폴더에 덮어씁니다.\n"
        "4. 원본 애드온만 켜고, 별도 `-KR` 애드온처럼 설치하지 않습니다.\n\n"
        "## 포함 파일\n\n"
        f"{file_list}\n\n"
        "## 비고\n\n"
        "- 이 패치는 원본 핵심 파일 일부를 직접 교체합니다.\n"
        "- Minion 독립 패치 애드온으로 분리하면 초기화 순서나 전역 상태 재생성 때문에 문제가 날 수 있습니다.\n"
    )


def build_standalone_zip(package_dir: Path, package: str) -> None:
    zip_path = PATCH_ROOT / get_output_zip_name(package, PATCHES[package])
    if zip_path.exists():
        zip_path.unlink()

    root_manifest = package_dir / f"{package}.txt"
    with ZipFile(zip_path, "w", compression=ZIP_DEFLATED) as zf:
        for path in sorted(package_dir.rglob("*")):
            if path.is_dir():
                continue
            if path.suffix.lower() in {".txt", ".addon"} and path != root_manifest:
                continue
            rel_path = path.relative_to(package_dir.parent)
            zf.write(path, rel_path.as_posix())


def build_overwrite_zip(package_dir: Path, package: str, config: dict[str, str | list[str]]) -> None:
    zip_path = PATCH_ROOT / get_output_zip_name(package, config)
    if zip_path.exists():
        zip_path.unlink()

    addon_root = get_addon_root(config)
    with ZipFile(zip_path, "w", compression=ZIP_DEFLATED) as zf:
        for rel_path in config["files"]:
            abs_path = package_dir / rel_path
            zf.write(abs_path, str(rel_path).replace("\\", "/"))
        readme_path = package_dir / "README.md"
        zf.write(readme_path, f"{addon_root}/README.TamrielKR.md")


def build_zip(package_dir: Path, package: str, config: dict[str, str | list[str]]) -> None:
    if get_install_mode(config) == "standalone":
        build_standalone_zip(package_dir, package)
    else:
        build_overwrite_zip(package_dir, package, config)


def cleanup_legacy_zip(package: str, config: dict[str, str | list[str]]) -> None:
    expected = get_output_zip_name(package, config)
    legacy = f"{package}.zip"
    if expected != legacy:
        legacy_path = PATCH_ROOT / legacy
        if legacy_path.exists():
            legacy_path.unlink()


def sync_manifest(package_dir: Path, package: str, config: dict[str, str | list[str]]) -> None:
    manifest_path = package_dir / f"{package}.txt"
    if get_install_mode(config) == "standalone":
        manifest_path.write_text(build_manifest(config), encoding="utf-8", newline="\n")
    elif manifest_path.exists():
        manifest_path.unlink()


def main() -> None:
    for package, config in PATCHES.items():
        package_dir = PATCH_ROOT / package
        if not package_dir.exists():
            raise FileNotFoundError(package_dir)

        for rel_path in config["files"]:
            ensure_guard(package_dir / rel_path)

        sync_manifest(package_dir, package, config)
        readme_path = package_dir / "README.md"
        readme_path.write_text(build_readme(config), encoding="utf-8", newline="\n")
        build_zip(package_dir, package, config)
        cleanup_legacy_zip(package, config)
        print(f"rebuilt {package} [{get_install_mode(config)}]")


if __name__ == "__main__":
    main()
