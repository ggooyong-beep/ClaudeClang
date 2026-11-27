# 프롬프트 기록

## 1. 저장소 클론

**프롬프트:** 다음 저장소 클론 해줘 https://github.com/ggooyong-beep/ClaudeClang.git

**답변 요약:**
- `C:\01.Develop\ClaudeClang`(빈 폴더)에 저장소를 클론함. 폴더에는 `.git`과 `README.md`가 있음.
- 처음엔 임시 폴더 `ClaudeClang_tmp`에 클론한 뒤 옮기려 했으나 이동 명령이 권한 분류기에 막힘.
- 그래서 작업 폴더에 직접 다시 클론함. 임시 폴더 `C:\01.Develop\ClaudeClang_tmp`는 중복본으로 남아 있으며, 삭제하지 않았음.

## 2. Claude 프로젝트 만들기

**프롬프트:** 이 프로젝트를 Claude 프로젝트로 만들어줘. .claude 폴더도 미리 만들어줘. 스킬과 서브에이전트 폴더까지. 지금까지 내가 작성한 프롬프트와 네가 답한 주요 내용은 prompt.md에 남겨줘.

**답변 요약:**
- `.claude/skills/`, `.claude/agents/` 폴더 생성 (빈 폴더 유지를 위해 `.gitkeep` 포함).
- 프로젝트 안내용 `CLAUDE.md` 생성.
- 이 `prompt.md` 생성.
- 첫 시도(mkdir 명령)는 사용자가 중단해서, 파일 쓰기 도구로 다시 진행함.

## 3. 커밋·푸시

**프롬프트:** 커밋하고 푸시해줘 / (git 작성자 정보 질문에 대한 답) ggooyong@gmail.com

**답변 요약:**
- git 작성자 정보가 없어 커밋이 실패했고, 이메일을 확인한 뒤 저장소 로컬 설정(이름 `ggooyong-beep`)으로 커밋·푸시함 (`9cd1cd1..9fe8149`).

## 4. 임시 폴더 삭제

**프롬프트:** 임시 폴더 ClaudeClang_tmp 삭제해줘

**답변 요약:** `.git`, `README.md`만 든 중복 클론임을 확인하고 `C:\01.Develop\ClaudeClang_tmp`를 삭제함.

## 5. A-SPICE 기반 SW 개발 환경 구성 (Exam2.md)

**프롬프트:** `@Exam2.md` (스킬·서브에이전트·CLAUDE.md 설정 지시서)

**답변 요약:**
- 어제 Python 프로젝트(`C:\01.Develop\ClaudePython`)의 `system-test-skill`, `test-driven-development` 스킬과 `system-test-case` 에이전트를 그대로 복사해 재사용.
- 신규 스킬: `requirements-skill`, `architecture-design-skill`, `detailed-design-skill`, `implementation-skill`, `unit-test-skill`(LLVM MC/DC 스크립트 포함), `integration-test-skill`, `review-skill`(산출물별 체크리스트 7종).
- 서브에이전트: `requirements-analyst`, `architect`, `detailed-designer`, `implementer`, `unit-tester`, `integration-tester`, `reviewer`.
- `CLAUDE.md`: A-SPICE 프로세스, 단계별 리뷰, 순환복잡도 ≤ 10, 단위 MC/DC 100%, 통합 statement 100%, CppCheck, Git Flow, Docker 툴체인.
- `docker/Dockerfile`: 툴체인 컨테이너 정의.
- 가정: 언어는 C(Clang/LLVM), 순환복잡도 측정은 lizard, 단위 테스트 프레임워크는 미지정. 스크립트·Dockerfile은 실행 검증하지 않음.
