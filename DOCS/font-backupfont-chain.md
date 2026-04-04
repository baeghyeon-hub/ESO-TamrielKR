# [폰트/엔진] BackupFont 체이닝과 특수문자 □ 렌더링

작성일: 2026-03-31
상태: 해결 완료 (접근법 1 채택, 7개 폰트 전체 적용)

## 문서 메타

- 문제 유형 태그: `폰트 메트릭`, `BackupFont`, `slug 변환`, `특수문자`, `유니코드 커버리지`
- 원인 레이어: `엔진 로딩`, `폰트 메트릭`
- 핵심 한 줄 요약: TamrielKR slug 폰트의 BackupFont가 한글 전용 폰트로만 연결되어 있어, 한글도 특수 유니코드 심볼도 아닌 문자가 □로 렌더링됐다.

## 1. 문제 요약

길드 명부 등에서 EsoKR CJK 인코딩과 무관하게, 일반 영문 사용자의 캐릭터명·노트에 포함된 특수문자가 □로 표시되는 현상.

### 대표 증상

- 길드 명부 캐릭터명: "Stop that □x b ‡ ∅ □ℸ□r"
- 일부 유니코드 심볼(‡ U+2021, ∅ U+2205, ℸ U+2138)은 렌더되지만, 다른 유니코드 문자는 □
- CNKR 디코딩과 무관 — 영문 사용자, ASCII + 특수문자 조합에서도 발생
- Font Inspector: `TamrielKR/fonts/univers57.slug`, backup `kr_gothic.slug`

## 2. 원인 분석

### TamrielKR 폰트 파이프라인

```
ESO 원본 .otf → slugfont.exe → TamrielKR/fonts/*.slug (7종)
                                한글 폰트 → kr_*.slug (4종, 별도 제작)
```

### 수정 전 BackupFont 체인 (univers57 예시)

```
[1홉] TamrielKR/fonts/univers57.slug → kr_gothic.slug
[2홉] kr_gothic.slug → $(FTN57_FONT)         ← 여기까지 도달하는가?
```

### 핵심 가설

ESO BackupFont는 **1단계만 해석**하고 체이닝하지 않을 가능성이 높았다.

- 1홉: `univers57.slug` → `kr_gothic.slug` — 한글은 여기서 찾음 ✓
- 특수문자: `kr_gothic.slug`에 없음 → 2홉 `$(FTN57_FONT)` 미도달 → □

### 폰트별 BackupFont 매핑 (수정 전)

| TamrielKR slug | 백업 대상 | 문제 |
|----------------|-----------|------|
| ftn47.slug | kr_gothic.slug | 특수문자 미포함 |
| ftn57.slug | kr_gothic_bold.slug | 특수문자 미포함 |
| ftn87.slug | kr_jalnan.slug | 특수문자 미포함 |
| proseantiquepsmt.slug | kr_maruburi.slug | 특수문자 미포함 |
| univers47.slug | kr_gothic_bold.slug | 특수문자 미포함 |
| univers55.slug | kr_maruburi.slug | 특수문자 미포함 |
| univers57.slug | kr_gothic.slug | 특수문자 미포함 |

모든 TamrielKR slug의 1차 백업이 한글 전용 폰트로만 연결되어 있어, slug 변환 시 누락된 특수 유니코드 글리프를 복구할 경로가 없었다.

## 3. 접근법 목록

### 접근법 1: 폴백 순서 뒤집기 (현재 테스트 중)

**변경**: `backupfont_kr.xml`만 수정

```xml
<!-- 수정 전 -->
<BackupFont originalFont="TamrielKR/fonts/univers57.slug" backupFont="TamrielKR/fonts/kr_gothic.slug"/>

<!-- 수정 후 -->
<BackupFont originalFont="TamrielKR/fonts/univers57.slug" backupFont="$(UNIVERS57_FONT)"/>
```

**의도하는 체인**:
```
univers57.slug → $(UNIVERS57_FONT)    [특수문자 해결]
$(UNIVERS57_FONT) → kr_gothic.slug    [이미 정의됨, 한글 해결]
```

**위험**: ESO가 2홉 체이닝을 안 하면 한글이 깨짐

**최종 결과**:
- 1차 테스트: univers57.slug만 변경 → 한글 정상 (체이닝 작동 확인)
- 2차 테스트: 7개 전체 적용 → "Confederaci**ó**n Hispana" 네임플레이트에서 ó (U+00F3) 정상 렌더 확인, 한글도 전체 정상
- **채택 확정**

### 접근법 2: kr_client.str에서 ESO 원본 폰트 직접 참조 (불필요)

**변경**: `kr_client.str`의 폰트 경로를 slug 대신 ESO 원본으로 교체

```
수정 전: [Font:ZoFontGame] = "TamrielKR/fonts/univers57.slug|18|soft-shadow-thin"
수정 후: [Font:ZoFontGame] = "$(UNIVERS57_FONT)|18|soft-shadow-thin"
         또는: "esoui/common/fonts/univers57.otf|18|soft-shadow-thin"
```

**원리**: slug 변환 자체를 우회하여 원본 OTF의 전체 글리프 사용. BackupFont로 한글만 보조.

**위험**: .str 파일에서 $() 상수나 ESO 내부 경로가 지원되지 않을 수 있음

### 접근법 3: slugfont.exe 옵션으로 유니코드 범위 확장

**변경**: `generate_slugs.bat`에 문자 범위 파라미터 추가

```bat
:: 현재
"%SLUGFONT%" "%~1" -o "%~2"

:: 확장 유니코드 포함 (옵션이 존재한다면)
"%SLUGFONT%" "%~1" -o "%~2" --unicode-range "0020-FFFF"
```

**원리**: slug 생성 시 더 넓은 유니코드 범위를 포함하여 글리프 누락 방지

**위험**: slugfont.exe에 해당 옵션이 없을 수 있음. 확인 필요.

## 4. 체이닝 작동 확인 및 최종 검증

### ESO BackupFont 체이닝 확인

- `univers57.slug → $(UNIVERS57_FONT) → kr_gothic.slug` 경로에서 한글이 정상 렌더됨
- 이는 ESO BackupFont가 **최소 2단계까지 체이닝을 지원**한다는 증거
- 이전 가설("1단계만 해석")은 기각됨

### 특수문자 수정 확인

- 길드 상인 NPC 네임플레이트: "Confederaci□n Hispana" → "Confederación Hispana"
- ó (U+00F3, Latin-1 Supplement) 정상 렌더 확인
- `slugfont.exe`가 OTF→slug 변환 시 확장 라틴 문자를 누락시킨다는 근본 원인 확정

### 최종 적용 (7개 폰트)

| slug | 1홉 백업 (ESO 원본) | 2홉 체이닝 (한글) |
|------|-------------------|-----------------|
| ftn47.slug | $(FTN47_FONT) | → kr_gothic.slug |
| ftn57.slug | $(FTN57_FONT) | → kr_gothic_bold.slug |
| ftn87.slug | $(FTN87_FONT) | → kr_jalnan.slug |
| proseantiquepsmt.slug | $(PROSE_ANTIQUE_FONT) | → kr_maruburi.slug |
| univers47.slug | $(UNIVERS67_FONT) | → kr_gothic_bold.slug |
| univers55.slug | $(UNIVERS55_FONT) | → kr_maruburi.slug |
| univers57.slug | $(UNIVERS57_FONT) | → kr_gothic.slug |

## 6. 현재 코드 위치

- `backupfont_kr.xml` — BackupFont 체인 정의 (univers57만 변경 적용 중)
- `tools/generate_slugs.bat` — slug 생성 스크립트
- `EsoUI/lang/kr_client.str` — 폰트 정의

---

이 문서는 "BackupFont 체인에 의한 특수문자 □ 렌더링" 이슈에 한정한 기록이다.
CJK 인코딩에 의한 길드 텍스트 깨짐은 `compat-cnkr-guild-ui.md`, `compat-cnkr-guild-roster-ranks.md`를 참고할 것.
