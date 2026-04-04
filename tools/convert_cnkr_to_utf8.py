#!/usr/bin/env python3
"""
EsoKR CJK → UTF-8 한글 변환기

EsoKR 한글패치에서 사용하는 CJK 코드포인트 인코딩을
TamrielKR에서 사용하는 네이티브 UTF-8 한글로 변환합니다.

사용법:
    python convert_cnkr_to_utf8.py <입력파일> [출력파일]

예시:
    python convert_cnkr_to_utf8.py kr.lang kr_utf8.lang
    python convert_cnkr_to_utf8.py kr.lang              (원본 덮어쓰기)

CJK → 한글 매핑:
    U+6E00-U+99A3  →  U+AC00-U+D7A3  (한글 음절, +0x3E00)
    U+5E00-U+5EFF  →  U+1100-U+11FF  (한글 자모, -0x4D00)
    U+5F01-U+5F5F  →  U+3131-U+318F  (호환용 한글 자모, -0x2DD0)
"""

import sys
import os


def convert_cjk_to_korean(data: bytes) -> bytes:
    """CJK 인코딩된 바이트를 네이티브 한글 UTF-8로 변환"""
    result = bytearray()
    i = 0
    converted = 0

    while i < len(data):
        b0 = data[i]

        # 3-byte UTF-8 sequence (0xE0-0xEF)
        if 0xE0 <= b0 <= 0xEF and i + 2 < len(data):
            b1 = data[i + 1]
            b2 = data[i + 2]

            if (b1 & 0xC0) == 0x80 and (b2 & 0xC0) == 0x80:
                cp = ((b0 & 0x0F) << 12) | ((b1 & 0x3F) << 6) | (b2 & 0x3F)
                new_cp = None

                # 한글 음절 (CJK → Hangul Syllables)
                if 0x6E00 <= cp <= 0x99A3:
                    new_cp = cp + 0x3E00

                # 한글 자모 (CJK → Hangul Jamo)
                elif 0x5E00 <= cp <= 0x5EFF:
                    new_cp = cp - 0x4D00

                # 호환용 한글 자모 (CJK → Hangul Compatibility Jamo)
                elif 0x5F01 <= cp <= 0x5F5F:
                    new_cp = cp - 0x2DD0

                if new_cp is not None:
                    # Encode new codepoint as UTF-8
                    if new_cp < 0x800:
                        result.append(0xC0 | (new_cp >> 6))
                        result.append(0x80 | (new_cp & 0x3F))
                    elif new_cp < 0x10000:
                        result.append(0xE0 | (new_cp >> 12))
                        result.append(0x80 | ((new_cp >> 6) & 0x3F))
                        result.append(0x80 | (new_cp & 0x3F))
                    converted += 1
                    i += 3
                    continue

        result.append(b0)
        i += 1

    return bytes(result), converted


def main():
    if len(sys.argv) < 2:
        print("EsoKR CJK → UTF-8 한글 변환기")
        print()
        print("사용법: python convert_cnkr_to_utf8.py <입력파일> [출력파일]")
        print()
        print("예시:")
        print("  python convert_cnkr_to_utf8.py kr.lang kr_utf8.lang")
        print("  python convert_cnkr_to_utf8.py kr.lang  (원본 덮어쓰기)")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else input_path

    if not os.path.exists(input_path):
        print(f"파일을 찾을 수 없습니다: {input_path}")
        sys.exit(1)

    file_size = os.path.getsize(input_path)
    print(f"읽는 중: {input_path} ({file_size / 1024 / 1024:.1f} MB)")

    with open(input_path, "rb") as f:
        data = f.read()

    result, converted = convert_cjk_to_korean(data)

    if converted == 0:
        print("CJK 인코딩된 한글이 없습니다. 이미 UTF-8일 수 있습니다.")
        sys.exit(0)

    with open(output_path, "wb") as f:
        f.write(result)

    print(f"변환 완료: {converted}개 문자 변환")
    print(f"저장: {output_path}")


if __name__ == "__main__":
    main()
