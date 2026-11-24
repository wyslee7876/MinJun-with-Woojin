# 티켓헬퍼 소스 코드

## JSP/Servlet 프로젝트

Java 웹 프로젝트는 Maven WAR로 패키징합니다. Maven이 설치된 환경에서 저장소 루트에서 `mvn clean package`를 실행하면 `target/tickethelper.war`가 생성됩니다.

디렉터리 구조, MVC Model 2 계층별 책임, 코드와 커밋 규칙은 [JSP/Servlet 개발 가이드](docs/java-web.md)에서 확인할 수 있습니다.

## 실행
Node.js 20 이상. 별도 패키지 설치가 필요 없습니다.

```bash
npm run build
npm run dev
```

http://localhost:3000 접속. 다른 포트: `npm run dev -- --port 4173`.
수정 후 다시 빌드하고 서버를 재시작하세요.

## 주요 파일
- `index.html`: 화면, CSS, 지도, 검색·필터·관심 저장·일정 다운로드
- `worker/index.js`: KOPIS 조회 및 수집본 대체 응답을 제공하는 서버
- `snapshot.json`: 2026-11-17 KOPIS에서 수집한 서울 공연 167건
- `build.mjs`: HTML과 데이터를 포함하는 Worker 파일 생성
- `dev.mjs`: 로컬 Node.js 서버
- `dist/server/index.js`: 빌드 후 생성되는 배포용 Worker
- `preview/index.html`: 빌드 후 생성되는 정적 화면

## 데이터 및 제한
KOPIS 공식 사이트의 공개 조회 경로를 사용합니다.
https://kopis.or.kr:9001/api/prs/v1/por/db/prfrdb/perfo-infos
인증키 기반 정식 Open API와는 다른 경로로, 사이트 개편에 따라 변경될 수 있습니다.
장기 운영 시 정식 KOPIS Open API 인증키를 발급받아 서버 조회 부분을 교체하는 것을 권장합니다.
콘서트·뮤지컬·연극을 각각 최대 100건 조회한 뒤 서울 주소만 표시합니다.
전체 공연 DB를 모두 조회하는 구현은 아닙니다.
외부 조회 실패 시 포함된 수집본을 사용하며 화면에 표시합니다.
운영 환경에 따라 해당 포트의 외부 요청이 제한될 수 있습니다.

지도는 Leaflet과 CARTO/OpenStreetMap을 사용합니다.
일부 공연장 좌표를 코드에 지정했으며 위치가 없는 공연은 목록에서만 확인할 수 있습니다.
폰트·지도·포스터는 인터넷 연결이 필요합니다.
관심 공연 및 사용자 지정 일정은 브라우저 localStorage에 저장합니다.
별도 계정·DB·백그라운드 알림 발송은 구현되어 있지 않습니다.
일정은 사용자가 시각을 지정해 ICS 파일로 다운로드한 후 캘린더 앱에 추가하는 방식입니다.
예매 오픈 시각·잔여 좌석·혼잡도는 제공하지 않습니다.
포스터 권리는 각 권리자에게 있으며 공연 정보 출처는 KOPIS입니다.

## 배포
Cloudflare Worker 호환 fetch 진입점을 제공합니다.
`.openai/hosting.json`에는 기존 사이트 ID와 인증정보를 포함하지 않았습니다.
Sites에 새로 배포하려면 새 프로젝트 ID를 설정하세요.
