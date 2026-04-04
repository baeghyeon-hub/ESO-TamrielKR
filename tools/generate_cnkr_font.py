"""
MaruBuri 폰트의 한글 글리프를 CJK 코드포인트 위치에도 매핑하는 스크립트.
TamrielKR Bridge가 TextChanged에서 한글→CJK 인코딩할 때,
CJK 문자가 한글로 렌더링되도록 하기 위함.

Usage:
    pip install fonttools
    python generate_cnkr_font.py MaruBuri-SemiBold.otf MaruBuri-CNKR.otf
"""

import sys
from fontTools.ttLib import TTFont


# EsoKR CJK 매핑 (한글 → CJK 오프셋)
MAPPINGS = [
    # (Korean start, Korean end, offset to get CJK position)
    (0xAC00, 0xD7A3, -0x3E00),   # 한글 음절 → CJK U+6E00-U+99A3
    (0x1100, 0x11FF, 0x4D00),    # 한글 자모 → CJK U+5E00-U+5EFF
    (0x3131, 0x318F, 0x2DD0),    # 호환 자모 → CJK U+5F01-U+5F5F
]


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <input.otf> <output.otf>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    print(f"Loading: {input_path}")
    font = TTFont(input_path)

    added = 0
    for table in font["cmap"].tables:
        if not hasattr(table, "cmap") or not isinstance(table.cmap, dict):
            continue

        new_entries = {}
        for kr_start, kr_end, offset in MAPPINGS:
            for cp in range(kr_start, kr_end + 1):
                glyph = table.cmap.get(cp)
                if glyph:
                    cnkr_cp = cp + offset
                    new_entries[cnkr_cp] = glyph  # 기존 한자 글리프 덮어쓰기

        table.cmap.update(new_entries)
        if new_entries:
            added = max(added, len(new_entries))

    print(f"Added {added} CJK mappings (Korean glyphs at CJK positions)")
    print(f"Saving: {output_path}")
    font.save(output_path)
    print("Done!")


if __name__ == "__main__":
    main()
