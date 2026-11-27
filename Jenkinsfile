// CI 파이프라인: claudeclangbuild 이미지(개발과 동일) 안에서 모든 빌드 이상의 작업을 수행한다.
// 품질 게이트(빌드, CppCheck 0, Lizard, 단위 MC/DC 100%, 통합 함수 100%, 성공률 100%)를 모두 통과해야 PR을 완료할 수 있다.
pipeline {
  agent { docker { image 'claudeclangbuild'; args '-u root' } }
  options { timestamps(); ansiColor('xterm'); buildDiscarder(logRotator(numToKeepStr: '20')) }
  stages {
    stage('Build')            { steps { sh 'bash scripts/ci/build.sh' } }
    stage('Static Analysis')  { steps { sh 'bash scripts/ci/static_analysis.sh' } }
    stage('Unit Test')        { steps { sh 'bash scripts/ci/run_tests.sh unit' } }
    stage('Integration Test') { steps { sh 'bash scripts/ci/run_tests.sh integration' } }
    stage('TDD Test (참고)')  { steps { sh 'bash scripts/ci/run_tests.sh tdd' } }
  }
  post {
    always {
      junit allowEmptyResults: true, testResults: 'build/reports/*/junit.xml'
      recordIssues enabledForFailure: true, tools: [
        cppCheck(pattern: 'build/reports/cppcheck.xml', id: 'cppcheck', name: 'CppCheck'),
        gcc(pattern: 'build/reports/lizard.txt', id: 'lizard', name: 'Lizard (CCN/라인)')
      ], qualityGates: [[threshold: 1, type: 'TOTAL', unstable: false]]
      publishHTML(target: [reportDir: 'build/reports/unit/html', reportFiles: 'index.html',
                           reportName: 'Unit Coverage (MC/DC)', allowMissing: true, keepAll: true])
      publishHTML(target: [reportDir: 'build/reports/integration/html', reportFiles: 'index.html',
                           reportName: 'Integration Coverage', allowMissing: true, keepAll: true])
      publishHTML(target: [reportDir: 'build/reports/tdd/html', reportFiles: 'index.html',
                           reportName: 'TDD Coverage', allowMissing: true, keepAll: true])
      archiveArtifacts artifacts: 'build/reports/**', allowEmptyArchive: true
    }
  }
}
