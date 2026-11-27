---
name: unit-test-skill
description: A-SPICE SWE.4 단위 테스트. 목표 커버리지(MC/DC 100%) 달성까지 테스트 케이스 반복 추가, Stub/Mock 최소 사용, 의미 없는 테스트 금지, Doxygen 주석(목적·입력·절차·예상 출력), 경계값·동치 클래스·PICT 활용, LLVM 기반 MC/DC 측정 스크립트 제공. "단위 테스트", "MC/DC", "SWE.4" 요청 시 사용.
---

# Unit-Test-Skill (SWE.4)

## 규칙
1. 정해진 커버리지(기본: **MC/DC 100%**, `CLAUDE.md` 기준)를 달성할 때까지 **반복해서 테스트 케이스를 추가**한다. 달성 전에는 완료를 보고하지 않는다.
2. 필요한 경우 Stub/Mock을 쓸 수 있으나 **과의존하지 않는다.** 실제 코드로 검증 가능하면 실제 코드를 쓰고, 외부 하드웨어·OS·시간·타 컴포넌트처럼 격리가 불가피한 경우에만 대체한다.
3. **커버리지만 채우는 무의미한 테스트 금지**(검증문(assert) 없는 호출, 기대값이 구현을 복사한 테스트, 중복 클래스). 모든 테스트는 "실패하면 어떤 결함을 발견하는가"에 답해야 한다.
4. 모든 테스트 함수에는 **Doxygen 주석**으로 테스트 **목적, 입력값, 절차, 예상 출력값**을 쓴다.
   ```c
   /**
    * @test  sensor_read: NULL 출력 포인터 거부
    * @purpose out==NULL 일 때 크래시 없이 오류 코드를 반환하는지 확인
    * @input   s=유효 센서(value=5), out=NULL
    * @procedure 1) 유효 센서 준비 2) sensor_read(&s, NULL) 호출
    * @expected STATUS_ERR_NULL 반환, 센서 상태 불변
    * @traces FN-012, FR-003
    */
   ```
5. **경계값 분석, 동치 클래스, PICT 조합**을 적극 활용한다. PICT는 `.claude/skills/system-test-skill/bin/pict.exe`(컨테이너에서는 `pict`)와 `run_pict.py`를 재사용한다.
6. **MC/DC** 목표가 있으면 **LLVM 도구**로 측정하고, 미충족 조건에 대해 독립 영향(independence pair)을 보이는 케이스를 추가한다. 도구는 이 스킬의 `scripts/`로 제공한다.
7. 구현은 TDD(`test-driven-development`)를 따른다. 테스트가 먼저 실패하는 것을 확인한다.
8. 테스트 성공률 100%. 비활성화(skip/disable)로 실패를 숨기지 않는다.

## 절차 (반복 루프)
1. 상세 설계의 함수별 입력 도메인에서 EP/BVA/PICT로 케이스 도출 → 테스트 작성.
2. `scripts/run_mcdc.sh <test_src> <unit_src...>` 실행 → 빌드·실행·리포트.
3. `scripts/check_mcdc.py build/cov/mcdc.txt` 로 미충족 판정 목록 확인(100% 아니면 exit 1).
4. 미충족 판정마다 조건 조합을 분석해 케이스 추가 → 2로. 도달 불가능(dead) 코드이면 임의 제외하지 말고 사용자에게 보고한다.

## 산출물
- `test/unit/`: 테스트 코드. `docs/test/unit-test-report.md`: 커버리지 결과, 요구사항·함수 ↔ TC 추적.

## 도구 요건
clang/LLVM 18+ (`-fcoverage-mcdc`), `llvm-profdata`, `llvm-cov`. 모두 Docker 툴체인 컨테이너에 포함된다.
