# 판매오더 아이템별 배송예정일 산출 리포트

## 프로그램 정보

| 항목 | 값 |
|------|-----|
| 프로그램명 | `$ABAP_SO_DELVDATE` |
| 패키지 | `$TMP` (로컈 오브젝트, 트랜스포트 불필요) |
| 타입 | 실행 가능한 프로그램 (Report) |
| ABAP 버전 | 7.40 |
| 생성 방법 | SE38 → 프로그램명 입력 → Create → 소스 붙여넣기 → Ctrl+F3 Activate → F8 실행 |

## 조회 테이블 구조

```
VBAK (SO 헤더)
  └── VBAP (SO 아이템)
        └── VBEP (낙기일정선) ← 배송예정일 핵심 테이블
              └── VBFA (문서흐름: SO→배송)
                    └── LIPS (배송 아이템: 실제출하일)
KNA1 (고객마스터: 고객명)
```

## 핵심 날짜 필드

| 필드 | 테이블 | 설명 |
|------|--------|------|
| VDATU | VBAK | 고객 요청 낙기일 |
| **EDATU** | **VBEP** | **확정 낙기일 (배송예정일 핵심)** |
| MBDAT | VBEP | 자재 가용일 (역방향 스케줄링) |
| WADAT | VBEP | 계획 출하일 (계획 GI일) |
| WADAT_IST | LIPS | 실제 출하일 (PGI 후 기록) |

## 지연 판단 로직

```
실제 출하(WADAT_IST) 있음  →  GREEN  (출고 완료)
EDATU <= VDATU             →  GREEN  (정상 낙기)
EDATU - VDATU <= 7일       →  YELLOW (소폭 지연)
EDATU - VDATU >  7일       →  RED    (심각 지연)
VDATU = 미입력             →  GREEN  (비교 불가, 정상 처리)
```

---

## ABAP 소스코드

```abap
*&---------------------------------------------------------------------*
*& Report: $ABAP_SO_DELVDATE
*& 판매오더 아이템별 배송예정일 산출 리포트
*& - VBAK+VBAP+VBEP INNER JOIN으로 낙기일정선 읽기
*& - VBFA→LIPS로 실제 배송 실적 보강
*& - 지연 일수 계산 및 신호등 아이콘 표시
*&---------------------------------------------------------------------*
REPORT $abap_so_delvdate.

INCLUDE <icon>.

" ... (full source in SAP system)
```

---

## SE38 생성 절차

1. **SE38 실행** → 프로그램명 `$ABAP_SO_DELVDATE` 입력
2. **Create 버튼** 클릭
3. 속성 입력:
   - Title: `판매오더 배송예정일 산출`
   - Type: `1` (Executable Program)
   - Package: `$TMP`
4. **소스코드 붙여넣기** (위 코드 전체)
5. **Ctrl+F3** → Activate
6. **F8** → 실행

## 주요 참고사항

- **VBEP.ETENR**: 낙기일정선 번호 (0001, 0002…). 아이템 1개에 여러 개 생성 가능 (분할낙기)
- **LIPS 실제출하일 우선**: 배송이 생성된 경우 LIPS.WADAT_IST가 VBEP.WADAT_IST보다 우선
- **FOR ALL ENTRIES 가드**: 구동 테이블 비어있으면 전체 조회 발생 — IF IS NOT INITIAL 체크 필수
- **지연 계산 예외**: VDATU = '00000000'이면 지연 비교 스킵 (GREEN 처리)
