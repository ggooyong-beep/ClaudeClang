# 프로젝트 지침

A-SPICE 기반 SW 개발 프로젝트(C, Clang/LLVM 툴체인)입니다.

## 개발 프로세스 (A-SPICE)
- 개발은 요구사항 분석(SWE.1) → 아키텍처 설계(SWE.2) → 상세 설계·구현(SWE.3) → 단위 테스트(SWE.4) → 통합 테스트(SWE.5) → 시스템 테스트(SWE.6) 순서로 진행한다.
- 각 단계의 산출물과 상위·하위 산출물 간 **양방향 추적성**을 유지한다(`docs/requirements/traceability.md`).
- 단계별 담당 서브에이전트와 스킬:

| 단계 | 서브에이전트 | 스킬 |
|---|---|---|
| 요구사항 | `requirements-analyst` | `requirements-skill` |
| 아키텍처 | `architect` | `architecture-design-skill` |
| 상세 설계 | `detailed-designer` | `detailed-design-skill` |
| 구현 | `implementer` | `implementation-skill`, `test-driven-development` |
| 단위 테스트 | `unit-tester` | `unit-test-skill` |
| 통합 테스트 | `integration-tester` | `integration-test-skill` |
| 시스템 테스트 | `system-test-case` | `system-test-skill` |
| 리뷰 | `reviewer` | `review-skill` |

- 구현은 TDD(`test-driven-development` 스킬)로 한다. 서브에이전트에 구현을 맡길 때는 프롬프트에 TDD 스킬 사용을 명시한다.

## 리뷰
- **매 단계가 끝날 때마다** `reviewer` 에이전트(`review-skill`)로 산출물을 리뷰한다. 리뷰를 통과(모든 항목 Pass/N-A)하기 전에는 다음 단계로 넘어가지 않는다.
- 리뷰 부적합 사항은 **모두 조치 완료**하고 재리뷰를 통과해야 다음 단계로 넘어갈 수 있다. 리뷰는 봐주지 않고 엄격하게 수행한다.
- 작성자와 리뷰어는 분리한다. 리뷰 기록은 `docs/reviews/`에 남긴다.

## 소스코드 품질
품질 기준은 하나라도 어기면 PR을 병합할 수 없다.
- 함수 **순환 복잡도(지표) 10 이하**. 측정: `lizard -C 10 -w src/` (경고 있으면 미충족).
- 모든 함수는 반환값을 가지며 `return`은 함수 끝에서 한 번만 쓴다(`implementation-skill`).
- 컴파일러 경고 0 (`-Wall -Wextra -Werror`).

## 테스트 요건
- **단위 테스트**: **MC/DC 100%**를 달성할 때까지 테스트를 추가·반복한다. 측정은 LLVM(`-fcoverage-mcdc`, `llvm-cov`)이며 도구는 `unit-test-skill/scripts/`에 있다.
- **통합 테스트**: **statement 커버리지 100%**를 달성할 때까지 테스트를 추가·반복한다. 측정은 `llvm-cov`.
- 테스트 성공률 100%. skip/disable로 실패를 숨기지 않는다. 커버리지 제외는 사용자 승인 없이 쓰지 않는다.
- 모든 테스트 함수에 Doxygen 주석으로 목적·입력값·절차·예상 출력값을 쓴다.

## 정적분석
- **CppCheck**를 사용한다: `cppcheck --enable=all --inconclusive --error-exitcode=1 --suppress=missingIncludeSystem src/ include/`. 경고가 남아 있으면 품질 기준 미충족이다.

## Git / PR 정책 (Git Flow)
- 영구 브랜치: `main`(릴리스, 항상 배포 가능), `develop`(통합). `main`·`develop`에 직접 커밋/푸시하지 않는다.
- 작업 브랜치: `feature/<설명>`(`develop`에서 분기 → `develop`으로 PR), `release/<버전>`(`develop`에서 분기 → `main`과 `develop`으로 병합, 태그 `vX.Y.Z`), `hotfix/<설명>`(`main`에서 분기 → `main`과 `develop`으로 병합).
- 설명은 영문 소문자 kebab-case. 병합이 끝난 브랜치는 삭제한다.
- 모든 병합은 PR로만 한다. PR은 CI 품질 게이트(빌드, 단위/통합 테스트, 커버리지, CppCheck, 순환 복잡도)와 리뷰 승인을 통과해야 한다.
- 커밋 메시지는 `<유형>: <요약>` 형식(`feat`, `fix`, `refactor`, `test`, `docs`, `chore`). 요약은 한글.

## 개발 환경 (툴체인)
- 툴체인은 **Docker 컨테이너**로 제공한다(`docker/Dockerfile`). 포함 도구: clang/LLVM 18+(llvm-cov, llvm-profdata), CMake, CppCheck, lizard, PICT, cloc, Python 3.
- **빌드 이상의 작업**(빌드, 테스트 실행, 커버리지, 정적분석, 복잡도 측정, PICT)은 모두 컨테이너에서 수행한다. 호스트에서 직접 실행하지 않는다.
  ```
  docker build -t claudeclang-toolchain docker/
  docker run --rm -v "$PWD":/work -w /work claudeclang-toolchain <명령>
  ```
- 소스는 `src/`·`include/`, 테스트는 `test/unit/`·`test/integration/`, 문서는 `docs/`에 둔다.
