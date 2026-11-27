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
