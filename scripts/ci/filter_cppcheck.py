#!/usr/bin/env python3
"""CppCheck XML에서 소스코드(src/, include/) 대상 지적만 남기고, 하나라도 있으면 불합격 처리한다.

@brief  전체 프로그램(src, include, test)을 --enable=all 로 분석한 결과 중 판정 대상은 src/·include/ 이다.
        (test/ 의 GTest TEST 매크로 함수에 대한 unusedFunction, 시스템 헤더 안내 등은 소스코드 품질 대상이 아니다.)
        억제(suppress) 설정은 사용하지 않는다.
@usage  filter_cppcheck.py <cppcheck.xml> <filtered.xml>
@return 0: 소스 대상 지적 0건, 1: 1건 이상, 2: 입력 오류
"""
import sys
import xml.etree.ElementTree as ET

TARGET_PREFIXES = ("src/", "include/")


def in_target(error):
    """@brief 지적 위치가 src/ 또는 include/ 인지 판정. @param error <error> 요소. @return bool."""
    result = False
    for location in error.findall("location"):
        path = location.get("file", "").replace("\\", "/").lstrip("./")
        if path.startswith(TARGET_PREFIXES):
            result = True
    return result


def main(argv):
    """@brief 진입점. @param argv 명령행 인자. @return 종료 코드."""
    status = 0
    if len(argv) != 3:
        print(__doc__)
        status = 2
    else:
        tree = ET.parse(argv[1])
        errors = tree.getroot().find("errors")
        kept = [err for err in errors if in_target(err)]
        for err in list(errors):
            if err not in kept:
                errors.remove(err)
        tree.write(argv[2], encoding="utf-8", xml_declaration=True)
        for err in kept:
            loc = err.find("location")
            print(f"{loc.get('file')}:{loc.get('line')}: {err.get('severity')}: {err.get('msg')} [{err.get('id')}]")
        print(f"CppCheck 소스 대상 지적: {len(kept)}건")
        status = 1 if kept else 0
    return status


if __name__ == "__main__":
    sys.exit(main(sys.argv))
