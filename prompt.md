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

## 6. 리뷰어 모델·CLAUDE.md 개정·툴체인/CI 구성 (Exam2.md 추가분)

**프롬프트:** `@Exam2.md` (리뷰 에이전트 게이트·Haiku, 이후 CLAUDE.md 개정 + 개발 환경 + Jenkins CI 지시)

**답변 요약:**
- `reviewer`: 무자비한 리뷰, 부적합 전부 조치해야 다음 단계, 조건부 승인 제거, 모델 `claude-haiku-5-5`. (커밋·푸시 완료)
- `CLAUDE.md` 전면 개정: 애자일 1이터레이션(분석~시스템 테스트), 이터레이션 완료 시 사용자 확인 후 PR, 메인 에이전트가 개발, TDD 테스트 분리(`test/tdd`)·별도 결과/커버리지, 커버리지 기준(시스템 요구사항 100% / 통합 함수 100% / 단위 MC/DC 100%), 순환복잡도 ≤10·함수 라인 ≤80(Lizard + Stop 훅), Doxygen Human-in-the-Loop 주석, Git Flow + CI 게이트, 개발 환경·CI 환경.
- 빌드 도구는 CMake + Ninja 추천. 도커 이미지 `ClaudeCLangBuild`는 대문자 불가라 태그 `claudeclangbuild`(`docker/build/Dockerfile`, Clang 19, GTest/GMock, CppCheck, Lizard, CLOC, PICT).
- Jenkins LTS(`ci/jenkins/`)를 Docker로 기동, 포트 8080, 플러그인 설치 및 `ClaudeClang` 멀티브랜치 잡 생성. `Jenkinsfile`, `scripts/ci/*`, `.claude/settings.json`(Stop 훅) 추가.
- 검증 중 `check_mcdc.py`가 MC/DC 미충족을 못 잡는 결함(출력 형식 오가정)을 발견해 수정, 미충족 rc=1/충족 rc=0 확인. Lizard 훅 위반 시 rc=2 확인.
- 미결: `cppcheck --enable=all`은 라이브러리 단독 분석에서 `unusedFunction` 등 오탐이 나와 샘플이 불합격함 → 검사 범위 조정 여부는 사용자 결정 대기.

## 7. Git Flow 진행 및 Jenkins 실증 (자율 진행)

**프롬프트:** git flow 따라라 / jenkins 실행을 해야 한다. 스캔해서 실행해봐 / 현재 진행 상태 요약 보고해 / gitflow 따라가고 이후 작업 네가 알아서 진행해. 문제가 발생하면 원인 파악해서 해결하고, 마지막에 나에게 보고해. 환경 모두 구성 진행해. 사전에 내가 정해줘야 하는 것 알려줘

**답변 요약:**
- Git Flow: `develop` 생성 → `feature/aspice-toolchain-ci` → PR #1 → Jenkins 통과(#2) 후 `develop`에 병합.
- `.gitattributes` 추가(sh/py/Dockerfile/Jenkinsfile 등 LF 고정).
- Jenkins 멀티브랜치 스캔·실행 실증(검증용 브랜치 3개를 만들어 확인 후 삭제, 병합 안 함):
  - 통과 케이스: SUCCESS, 테스트 9건 통과, CppCheck/Lizard가 Warnings NG에 집계(0건), 커버리지 HTML(단위 MC/DC 100%) 열람 가능.
  - MC/DC 미충족: `Unit Test` 단계 FAILURE.
  - 정적분석 위반: `Static Analysis` 단계 FAILURE, Warnings NG에 CppCheck 5건·Lizard 1건 표시.
- `develop` 브랜치도 Jenkins 빌드 SUCCESS.
- 한계: Jenkins가 로컬(localhost)이라 GitHub가 웹훅을 보낼 수 없음 → PR 상태 체크/브랜치 보호 연동은 미구성(사용자 결정 필요).

## 8. 도구 최신 버전 업그레이드

**프롬프트:** 구 버전의 툴은 최신 버전으로 설치하도록 한다. (직전 질문: 설치 내역, 검증 툴 보고)

**답변 요약:**
- 최신 릴리스를 GitHub/PyPI/apt.llvm.org/Docker Hub에서 조회해 확인한 뒤 Git Flow(`feature/upgrade-toolchain-latest`)로 진행.
- 이미지 기반을 Ubuntu 26.04 LTS로 올리고 LLVM 19→23.1.6, CMake 3.28→4.5.1, CppCheck 2.13→2.22.0, Doxygen 1.9.8→1.18.0, GoogleTest 1.14→1.18.0, CLOC 1.98→2.12, Ninja 1.11→1.13.2, Python 3.12→3.14.4, clang-format 18→23. Lizard 1.26.1, PICT는 이미 최신(PICT는 v3.7.4 태그로 고정). 버전은 Dockerfile `ARG`에서 관리.
- Jenkins LTS 기반을 JDK 21→25로 변경(Jenkins 2.580.3은 이미 최신 LTS), 플러그인 97개 업데이트 대기 없음.
- 빌드 중 문제: `libpcre3-dev`가 26.04에서 제거됨(제외), apt 미러 일시 오류(재시도 설정 추가). 빌드 로그가 덮어써지기 전에 이전 실패를 읽는 모니터 오탐도 있었으나 실제 빌드 상태를 재확인.
- 검증: 로컬 컨테이너와 Jenkins 모두에서 통과 케이스 SUCCESS, MC/DC 미충족 FAILURE, 정적분석 위반 실패 확인. 임시 검증 브랜치는 삭제.
- `CLAUDE.md`에 "모든 도구는 최신 릴리스" 규칙과 고정 버전 목록 추가.
