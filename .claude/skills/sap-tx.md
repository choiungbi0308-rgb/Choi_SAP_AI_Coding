# SAP Transaction Processor (sap-tx)

> QA-integrated SAP transactional execution skill.  
> Advisor role uses **claude-opus-4-7** for risk assessment and transaction strategy.  
> Execution uses **SAP GUI Scripting** (PowerShell COM) — no ABAP program creation required.

## Purpose

Execute SAP business transactions (VA02, ME22N, VA01, etc.) by:
1. Querying related data via MCP table tools
2. Consulting an Opus Advisor for transaction strategy and risk assessment
3. Automating SAP GUI via PowerShell COM scripting (standard transactions)
4. Verifying results via MCP table query
5. Logging execution history

---

## Invocation

```
/sap-tx <description of what to do>
```

Examples:
- `/sap-tx SO 5700416643 reason for rejection 처리, 연결 PO 먼저 삭제`
- `/sap-tx ME22N PO 4500012345 라인 1 수량 변경 50EA`
- `/sap-tx VA02 SO 5700416643 헤더 텍스트 변경`

---

## Execution Pipeline

### Stage 1 — Data Recon (MCP)

MCP 도구로 현재 시스템 상태 파악:

| 확인 항목 | MCP 도구 | 조회 테이블 |
|---------|---------|----------|
| SO 기본 정보 | `GetTableContents` | VBAK, VBAP |
| 연결 문서 흐름 | `GetSqlQuery` | VBFA |
| PO 정보 | `GetTableContents` | EKKO, EKPO |
| 배송/청구 여부 | `GetTableContents` | LIPS, VBRP |
| SO 상태 | `GetTableContents` | VBUK, VBUP |

블로킹 조건 확인 (PGI 완료, 청구서 발행, GR 전기 등)

---

### Stage 2 — Advisor Consultation (Opus)

Spawn Agent with `model: opus`:

- Input: Stage 1 recon data + 사용자 요청
- Advisor 판단 항목:
  - 처리 순서 (예: PO 삭제 → SO rejection 순서 확인)
  - 사용할 트랜잭션 및 화면 경로 (메뉴 → 필드명 → 값)
  - 처리 전 필수 조건
  - 리스크 등급: **LOW / MEDIUM / HIGH**
  - **GO / NO-GO** 판정 및 근거
- HIGH 리스크 또는 NO-GO → 사용자 확인 후 진행

---

### Stage 3 — SAP GUI Scripting (PowerShell COM)

SAP GUI가 설치된 Windows 환경에서 PowerShell COM 자동화로 표준 트랜잭션 실행.

**연결 정보 참조:** `.sc4sap/sap.env`

---

### Stage 4 — Verify (MCP)

처리 완료 후 MCP로 결과 검증:
- 변경된 필드 값 재조회
- 상태 플래그 확인
- 예상 값과 실제 값 비교 → 성공/실패 판정

---

### Stage 5 — Log

`logs/sap-tx-log.md`에 기록

---

## Risk Gates

다음 경우 Stage 3 실행 전 반드시 사용자 확인:
- Advisor 리스크 **HIGH** 또는 **NO-GO**
- PGI 완료된 배송 연결
- 청구서 발행 완료
- GR 전기 완료된 PO
