---
name: integration-test-skill
description: A-SPICE SWE.5 통합 테스트. statement 커버리지 100%까지 반복, 인터페이스 중심 컴포넌트 간 연동 검증, Stub/Mock 최소화, Doxygen 테스트 주석, 경계값·동치 클래스·PICT 활용. "통합 테스트", "SWE.5" 요청 시 사용.
---

# Integration-Test-Skill (SWE.5)

## 규칙
1. 정해진 커버리지(기본: **statement 100%**, `CLAUDE.md` 기준)를 달성할 때까지 **반복해서 테스트 케이스를 추가**한다.
2. Stub/Mock은 필요한 경우에만 쓰고 **과의존하지 않는다.** 통합 테스트의 가치는 실제 컴포넌트끼리 맞물리는 것이므로, 대상 컴포넌트들은 실제 구현을 링크한다. 하드웨어·OS 경계만 대체한다.
3. **커버리지만 채우는 무의미한 테스트 금지.**
4. 모든 테스트 함수에 Doxygen 주석으로 **목적, 입력값, 절차, 예상 출력값**을 쓴다(`unit-test-skill`의 형식과 동일, `@traces`는 `IF-nnn`/`FR-nnn`).
5. **경계값 분석, 동치 클래스, PICT 조합**을 적극 활용한다(PICT는 `system-test-skill`의 도구 재사용).
6. **인터페이스 중심**: 각 `IF-nnn` 인터페이스마다 정상 호출, 경계/무효 인자, 오류 코드 전파, 호출 순서 위반, 상태 의존 동작을 검증한다. 컴포넌트 단독 로직 검증은 단위 테스트의 몫이다.
7. 구현 보완이 필요하면 TDD(`test-driven-development`)를 따른다.

## 절차 (반복 루프)
1. 아키텍처 인터페이스 표에서 인터페이스별 케이스 도출 → 테스트 작성(`test/integration/`).
2. 통합 빌드·실행 + statement 커버리지 측정:
   ```
   clang -O0 -g -fprofile-instr-generate -fcoverage-mapping <integ_test.c> <components.c...> -o build/cov/integ
   LLVM_PROFILE_FILE=build/cov/integ.profraw build/cov/integ
   llvm-profdata merge -sparse build/cov/integ.profraw -o build/cov/integ.profdata
   llvm-cov report build/cov/integ -instr-profile=build/cov/integ.profdata --ignore-filename-regex='(^|/)test/'
   llvm-cov show  build/cov/integ -instr-profile=build/cov/integ.profdata --show-line-counts-or-regions --ignore-filename-regex='(^|/)test/'
   ```
3. Line(statement) 커버리지가 100% 미만이면 미실행 구문을 분석해 케이스 추가 → 2로. 도달 불가 코드는 임의 제외하지 말고 보고한다.

## 산출물
`test/integration/`, `docs/test/integration-test-report.md`(커버리지, 인터페이스 ↔ TC 추적).
