# 프로젝트 지침

A-SPICE 기반 SW 개발 프로젝트(C++, Clang 18+ 툴체인)입니다.

## 1. 개발 절차
- 개발은 **A-SPICE**를 기준으로 한다. 각 단계 산출물과 상·하위 산출물 간 **양방향 추적성**을 유지한다(`docs/requirements/traceability.md`).
- 개발 생명주기는 **애자일**이다. **분석(SWE.1) → 아키텍처 설계(SWE.2) → 상세 설계(SWE.3) → 구현 → 단위(SWE.4)/통합(SWE.5)/시스템(SWE.6) 테스트**를 **하나의 이터레이션**으로 한다.
- 각 단계가 끝나면 **`reviewer` 서브 에이전트**(`review-skill`)가 산출물을 리뷰한다. **부적합 사항을 모두 조치하고 재리뷰를 통과해야** 다음 단계로 진행한다.
- **이터레이션이 끝나면 사용자에게 확인을 받는다.** 확인 후에 PR 절차를 진행한다. 사용자 확인 없이 PR을 만들지 않는다.
- 개발은 **기본적으로 메인 에이전트**가 수행하며, 각 단계에 맞는 스킬을 사용한다.

| 단계 | 사용 스킬 |
|---|---|
| 요구사항 분석 | `requirements-skill` |
| 아키텍처 설계 | `architecture-design-skill` |
| 상세 설계 | `detailed-design-skill` |
| 구현 | `implementation-skill`, `test-driven-development` |
| 단위 테스트 | `unit-test-skill` |
| 통합 테스트 | `integration-test-skill` |
| 시스템 테스트 | `system-test-skill` (`system-test-case` 에이전트) |
| 리뷰 | `review-skill` (`reviewer` 에이전트, Haiku) |

  (`.claude/agents/`의 단계별 에이전트 — `requirements-analyst`, `architect`, `detailed-designer`, `implementer`, `unit-tester`, `integration-tester` — 는 사용자가 위임을 지시할 때만 쓴다.)
- **구현은 TDD**(`test-driven-development` 스킬)로 한다. 단, TDD로 만든 테스트 코드는 **단위 테스트 코드와 분리**(`test/tdd/`)하고, **별도의 결과(`build/reports/tdd-*`)로 도출**하며, **커버리지도 별도로 측정**한다. 단위 테스트(`test/unit/`)는 `unit-test-skill`로 따로 작성한다.

## 2. 소스코드 품질 기준
하나라도 어기면 PR을 완료할 수 없다.

### 테스트 커버리지
| 테스트 | 기준 |
|---|---|
| 시스템 테스트 | **요구사항 커버리지 100%** |
| 통합 테스트 | **함수(function) 커버리지 100%**, **테스트 성공률 100%** |
| 단위 테스트 | **MC/DC 커버리지 100%**, **테스트 성공률 100%** |

- 목표 달성 전까지 테스트 케이스를 추가·반복한다. skip/disable로 실패를 숨기지 않고, 커버리지 제외 지시는 쓰지 않는다.
- 모든 테스트 함수에는 Doxygen 주석으로 목적·입력값·절차·예상 출력값을 쓴다.

### 정적분석
- **CppCheck 룰 대상 100% 만족.** 경고가 하나라도 남으면 불합격이며 **예외 처리(suppress, 인라인 억제 주석)는 없다.** 분석은 전체 프로그램(`src`·`include`·`test`, `unusedFunction` 정확도 목적)으로 하고, 판정 대상은 소스코드(`src/`·`include/`)의 지적 0건이다(`test/` 의 GTest 매크로 오탐은 대상이 아님).
  `cppcheck --enable=all --inconclusive --library=googletest -I include --xml src include test` 후 `scripts/ci/filter_cppcheck.py`

### 소스코드 메트릭
- 함수 **순환복잡도 10 이하**, 함수 **라인 수 80 이하**. **Lizard**로 검사한다: `lizard -C 10 -L 80 -w src/ include/`.
- **구현이 끝날 때 Hook으로 검사한다**(`.claude/settings.json`의 Stop 훅 → `scripts/hooks/lizard_check.sh`). 위반 시 구현을 마칠 수 없다.
- 모든 함수는 반환값을 가지며 `return`은 함수 끝에서 한 번만 쓴다(`implementation-skill`). 컴파일 경고 0(`-Wall -Wextra -Werror`).

### 주석 (Doxygen)
- 주석은 **Doxygen 형식**으로 작성한다. 주석률은 **CLOC**으로 측정·보고한다(`cloc src include --by-file`).
- 모든 소스/헤더 파일(및 클래스·함수 단위 Doxygen 블록)에 아래 **Human-in-the-Loop 항목**을 **반드시** 포함한다(Doxygen 형식).
  - 작성한 **AI 모델**, 작성 **일시**, **요청자**
  - **사용자 리뷰 완료 여부**, 완료했다면 **일시와 리뷰어**
  ```cpp
  /**
   * @file    sensor.cpp
   * @brief   센서 값 읽기
   *
   * @par Human-in-the-Loop
   * - @c ai_model     : claude-sonnet-5-5
   * - @c generated_at : 2026-11-27T14:30+09:00
   * - @c requested_by : ggooyong-beep
   * - @c user_review  : done          (pending | done)
   * - @c reviewed_by  : ggooyong-beep  (미완료면 "-")
   * - @c reviewed_at  : 2026-11-27T16:00+09:00  (미완료면 "-")
   */
  ```
- AI가 코드를 만들거나 수정하면 `generated_at`을 갱신하고 `user_review`를 `pending`으로 되돌린다. `done`은 **사용자가 리뷰했다고 확인한 뒤에만** 쓴다.

## 3. Git 브랜치 및 PR 전략
- 브랜치는 **Git Flow**를 준수한다. 영구 브랜치 `main`(릴리스)·`develop`(통합)에 직접 커밋/푸시하지 않는다.
- 작업 브랜치: `feature/<설명>`(`develop`에서 분기 → `develop`으로 PR), `release/<버전>`(`develop`에서 분기 → `main`·`develop`, 태그 `vX.Y.Z`), `hotfix/<설명>`(`main`에서 분기 → `main`·`develop`). 설명은 영문 소문자 kebab-case. 병합이 끝난 브랜치는 삭제한다.
- **PR은 CI를 활용**하며, **CI를 통과해야만 PR을 완료**한다. CI 통과 항목은 **빌드 성공 + 위 2절의 소스코드 품질 기준 전부**다.
- PR은 이터레이션 완료에 대한 사용자 확인 후에 만든다.
- 커밋 메시지는 `<유형>: <요약>`(`feat`, `fix`, `refactor`, `test`, `docs`, `chore`), 요약은 한글.

## 4. 개발 환경
| 항목 | 도구 |
|---|---|
| 개발 언어 | C++ (Clang 18 이상의 최신, 현재 Docker 이미지는 Clang 23, C++20) |
| 빌드 도구 | **CMake + Ninja** (추천: Clang과 `compile_commands.json` 연동이 좋고 증분 빌드가 빠름) |
| 정적 분석 | CppCheck |
| 테스트 프레임워크 | Google Test / GMock |
| 커버리지 측정 | LLVM(`-fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc`, `llvm-profdata`, `llvm-cov`) — MC/DC 포함 |
| 순환복잡도/함수 라인 수 | Lizard |
| 주석률 | CLOC |
| 추가 도구 | PICT(조합 테스트), clang-format(서식), Doxygen(문서), Python 3(리포트·검사 스크립트) |

- **모든 도구는 최신 릴리스 버전을 사용한다.** 버전은 `docker/build/Dockerfile`의 `ARG`(LLVM, CMake, CppCheck, Doxygen, GoogleTest, CLOC, PICT, Lizard)와 `ci/jenkins/Dockerfile`(Jenkins LTS)에서 한곳씩 관리하며, 오래된 버전을 발견하면 최신으로 올린 뒤 CI 검증을 통과해야 병합한다. 현재 고정 버전: LLVM 23.1.6, CMake 4.5.1, Ninja 1.13.2, CppCheck 2.22.0, Doxygen 1.18.0, GoogleTest 1.18.0, CLOC 2.12, PICT 3.7.4, Lizard 1.26.1, Ubuntu 26.04 LTS.
- **개발 빌드와 CI 빌드는 동일한 Docker 이미지**를 쓴다. 이미지 이름은 **`ClaudeCLangBuild`**다.
  - Docker는 저장소 이름에 대문자를 허용하지 않으므로 실제 태그는 소문자 `claudeclangbuild`다.
  - 빌드: `docker build -t claudeclangbuild docker/build/`
  - 사용: `docker run --rm -v "$PWD":/work -w /work claudeclangbuild <명령>`
- **빌드 이상의 작업**(빌드, 테스트, 커버리지, 정적분석, 메트릭, PICT)은 모두 컨테이너에서 수행한다. 호스트에서 직접 실행하지 않는다.
- 디렉터리: `src/`·`include/`(소스), `test/tdd|unit|integration/`(테스트), `docs/`(산출물), `scripts/`(CI·훅·검사), `build/`(산출물, git 제외).

## 5. CI 환경
- CI는 **Jenkins LTS(안정화 버전)**이며 이 PC의 Docker에서 실행한다. **포트 8080**.
- 구성: `ci/jenkins/`(Dockerfile, `plugins.txt`, `docker-compose.yml`, JCasC). 실행: `docker compose -f ci/jenkins/docker-compose.yml up -d` → http://localhost:8080
- 파이프라인은 저장소 루트의 `Jenkinsfile`이며, `claudeclangbuild` 이미지 안에서 빌드→테스트→정적분석→메트릭→품질 게이트를 수행한다.
- 테스트·정적분석 결과는 Jenkins 플러그인(JUnit, Warnings Next Generation, HTML Publisher)에서 확인한다.
