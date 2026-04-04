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


def find_text_section_offset(data: bytes) -> int:
    """바이너리 인덱스 섹션 이후 텍스트 데이터가 시작되는 오프셋을 찾는다.

    ESO .lang 파일은 바이너리 인덱스(16바이트 레코드) + 텍스트 데이터(null-terminated 문자열)로 구성됨.
    바이너리 인덱스 영역의 null 바이트 밀도가 텍스트 영역보다 훨씬 높은 점을 이용하여 경계를 탐지.
    """
    WINDOW = 1024
    # 바이너리 인덱스: null 밀도 ~300+/1KB, 텍스트: ~3-30/1KB
    THRESHOLD = 100

    prev_nulls = WINDOW  # 파일 시작은 바이너리
    for offset in range(0, len(data) - WINDOW, WINDOW):
        nulls = data[offset:offset + WINDOW].count(0)
        if prev_nulls >= THRESHOLD and nulls < THRESHOLD:
            # 경계 발견 — 이 블록의 시작점부터 텍스트 섹션
            return offset
        prev_nulls = nulls

    # 경계를 찾지 못한 경우 (순수 텍스트 파일 등) 처음부터 변환
    return 0


def convert_cjk_to_korean(data: bytes) -> bytes:
    """CJK 인코딩된 바이트를 네이티브 한글 UTF-8로 변환 (텍스트 섹션만)"""
    text_start = find_text_section_offset(data)

    # 바이너리 헤더는 그대로 보존
    result = bytearray(data[:text_start])
    i = text_start
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
        print("EsoKR CJK -> UTF-8 Korean Converter")
        print()
        print("Usage: python convert_cnkr_to_utf8.py <input> [output]")
        print()
        print("Examples:")
        print("  python convert_cnkr_to_utf8.py kr.lang kr_utf8.lang")
        print("  python convert_cnkr_to_utf8.py kr.lang  (overwrite)")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else input_path

    if not os.path.exists(input_path):
        print(f"File not found: {input_path}")
        sys.exit(1)

    file_size = os.path.getsize(input_path)
    print(f"Reading: {input_path} ({file_size / 1024 / 1024:.1f} MB)")

    with open(input_path, "rb") as f:
        data = f.read()

    result, converted = convert_cjk_to_korean(data)

    if converted == 0:
        print("No CJK-encoded Korean found. File may already be UTF-8.")
        sys.exit(0)

    with open(output_path, "wb") as f:
        f.write(result)

    print(f"Converted {converted:,} characters")
    print(f"Saved: {output_path}")


if __name__ == "__main__":
    main()
