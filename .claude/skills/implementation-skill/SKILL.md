---
name: implementation-skill
description: A-SPICE SWE.3 구현(코딩) 규칙. 모든 함수는 반환값을 가지며 return은 함수 끝에서 한 번만, 반환할 값이 없으면 void 대신 정상 실행 여부 상태 코드를 반환. C++ 소스 작성·수정 시 사용.
---

# Implementation-Skill

## 규칙
1. **모든 함수는 반드시 반환값을 가진다.**
2. **`return`은 함수의 마지막에 한 번만** 호출한다. 조기 return, 중간 return 금지. 오류 분기는 결과 변수(`status`)에 값을 담고 끝에서 반환한다.
3. 적절한 반환값이 없으면 `void` 대신 **정상 실행 여부를 판단할 수 있는 값**(예: `status_t` 열거형 `STATUS_OK` / `STATUS_ERR_*`)을 반환한다. `main`도 같은 규칙을 따른다.
4. 호출자는 반환값을 무시하지 않는다(`[[nodiscard]]` 또는 `__attribute__((warn_unused_result))` 사용).
5. 컴포넌트 간 접근은 상세 설계의 인터페이스(공개 헤더)로만 한다. 내부 심볼은 `static`.
6. 품질 한도는 `CLAUDE.md`를 따른다(함수 순환 복잡도 ≤ 10, 함수 라인 수 ≤ 80 — Lizard, CppCheck 경고 0·예외 없음). 한도를 넘기면 함수를 분리한다.
7. 구현은 TDD로 진행한다(`test-driven-development` 스킬): 실패하는 테스트 → 실패 확인 → 최소 구현. TDD 테스트는 `test/tdd/`에 두어 단위 테스트(`test/unit/`)와 분리하고, 결과·커버리지를 별도로 측정한다(`scripts/ci/run_tests.sh tdd`).
8. 모든 소스/헤더 파일과 클래스·함수의 Doxygen 블록에 **Human-in-the-Loop 항목**(AI 모델, 생성 일시, 요청자, 사용자 리뷰 여부·리뷰어·리뷰 일시)을 넣는다. 형식은 `CLAUDE.md`의 주석 절을 따른다. 코드를 수정하면 `generated_at`을 갱신하고 `user_review`를 `pending`으로 되돌리며, `done`은 사용자 확인 후에만 쓴다.

## 패턴
```c
status_t sensor_read(const sensor_t *s, int32_t *out)
{
    status_t status = STATUS_OK;

    if ((s == NULL) || (out == NULL)) {
        status = STATUS_ERR_NULL;
    } else if (!s->ready) {
        status = STATUS_ERR_NOT_READY;
    } else {
        *out = s->value;
    }

    return status;   /* 유일한 return */
}
```

## 완료 조건
- 컴파일 경고 0, CppCheck 경고 0, 모든 함수가 단일 return + 반환값 보유.
- 소스 ↔ 상세 설계 함수 ID 추적(Doxygen `@req`/`@design` 태그 또는 추적 표).
