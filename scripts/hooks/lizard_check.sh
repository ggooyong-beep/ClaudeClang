#!/usr/bin/env bash
# @brief Stop 훅: 구현을 마치기 전에 Lizard(CCN<=10, 함수 라인<=80)를 컨테이너에서 검사한다.
#        위반 시 exit 2 로 에이전트가 수정하도록 되돌린다. 소스가 없으면 통과한다.
input="$(cat)"
# 훅이 이미 한 번 되돌린 뒤의 재진입이면 무한 루프를 막기 위해 통과시킨다.
echo "$input" | grep -q '"stop_hook_active": *true' && exit 0

cd "$(dirname "$0")/../.." || exit 0
[ -n "$(find src include -name '*.[ch]*' 2>/dev/null | head -1)" ] || exit 0

if ! docker image inspect claudeclangbuild >/dev/null 2>&1; then
  echo "claudeclangbuild 이미지가 없어 Lizard를 검사할 수 없습니다: docker build -t claudeclangbuild docker/build/" >&2
  exit 2
fi
out="$(MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W 2>/dev/null || pwd):/work" -w /work claudeclangbuild \
        lizard -C 10 -L 80 -w src include 2>&1)"
if [ $? -ne 0 ]; then
  echo "Lizard 위반(순환복잡도>10 또는 함수 라인>80). 수정 후 다시 완료하세요:" >&2
  echo "$out" >&2
  exit 2
fi
exit 0
