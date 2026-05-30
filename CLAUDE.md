# AI-QA Project

SAP QA automation workspace — combines functional QA testing with SAP transactional execution.

---

## Session Start Checklist

At the start of every Claude Code session, run this checklist:

```
1. Read abap_vibe_coding/AGENTS.md         # agent registry & orchestration contract
2. Read abap_vibe_coding/skills/abap-dev/SKILL.md   # ABAP dev workflows (or /abap-dev)
3. Read abap_vibe_coding/skills/post-write-chain/SKILL.md  # mandatory QA chain
4. Read memory/MEMORY.md                   # recent session history (skip if absent)
```

---

## Skills & Commands

### Core (from abap_vibe_coding)

| Command | Invoke | Purpose |
|---------|--------|---------|
| `abap-dev` | `/abap-dev` | ABAP 개발 워크플로우 로드 (세션 시작 시) |
| `triage` | `/triage <request>` | 요청 분류 → task 파일 생성 → Phase 1 병렬 디스패치 |
| `post-write` | `/post-write <object>` | SyntaxCheck → RunUnitTests → RunATCCheck |
| `transport` | `/transport <action>` | CTS 트랜스포트 관리 |
| `sap-sd/mm/fi/co/pp/le` | `/sap-sd` 등 | 모듈별 도메인 컨텍스트 로드 |
| `memlog` | `/memlog` | 오늘 개발 로그 기록 |
| `sync` | `/sync <message>` | audit + memory + git commit |
| `new-task` | `/new-task <name>` | task 파일 생성 |

### Project-Specific

| Skill | Invoke | Purpose |
|-------|--------|---------|
| `sap-tx` | `/sap-tx <description>` | Execute SAP transactions via BAPI (VA02, ME22N, etc.) |

## SAP Transaction Skill (`/sap-tx`)

- **Advisor**: Always spawns an Opus agent (`claude-opus-4-7`) for BAPI strategy and risk assessment before execution
- **Execution**: Generates a temp ABAP program in `$TMP`, runs via MCP, then deletes
- **Safety gates**: Confirms with user before executing HIGH-risk or irreversible operations
- **Logs**: All executions logged to `logs/sap-tx-log.md`

## Guidelines

- SAP 트랜잭션 처리는 항상 `/sap-tx` 스킬을 통해 진행
- Advisor(Opus)의 No-Go 판정 시 반드시 사용자 확인 후 진행
- Production 시스템(SID: HKP 등)에서는 추가 확인 필수
- 임시 ABAP 프로그램은 `$TMP` 패키지 사용 (트랜스포트 불필요)
- SAP GUI 창을 열었을때 항상 화면을 최대화 한다