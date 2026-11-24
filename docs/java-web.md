# JSP/Servlet 개발 가이드

## 프로젝트 구조

```text
.
├── pom.xml
├── README.md
├── database/
│   ├── schema.sql
│   └── seed.sql
├── docs/
└── src/main/
    ├── java/com/tickethelper/
    │   ├── controller/
    │   ├── service/
    │   ├── dao/
    │   ├── dto/
    │   ├── filter/
    │   └── util/
    ├── resources/
    └── webapp/
        ├── WEB-INF/views/
        │   ├── common/
        │   ├── performance/
        │   ├── festival/
        │   └── user/
        ├── css/
        ├── js/
        └── assets/
```

`src/main/resources`에는 WAR의 클래스패스에 포함할 설정과 리소스를 둡니다. `webapp`에는 JSP와 정적 파일을 둡니다. `database`에는 스키마와 개발용 초기 데이터를 관리하며, SQL은 WAR 밖에서 실행합니다.

## 개발 환경 및 실행

| 구성 | 버전과 설정 |
| --- | --- |
| Java | JDK 17 기준으로 컴파일합니다. `mvn -version`으로 Maven이 사용하는 JDK를 확인합니다. |
| 웹 컨테이너 | Apache Tomcat 10.1.x |
| Servlet·JSP | Servlet 6.0, JSP 3.1. Java 코드는 `jakarta.servlet` 네임스페이스를 사용하고 API는 Tomcat이 제공합니다. |
| JSTL | Jakarta Tags API 3.0.2와 GlassFish 구현 3.0.1을 WAR에 포함합니다. 코어 태그 URI는 `jakarta.tags.core`입니다. |
| Oracle JDBC | Oracle Thin 드라이버 `ojdbc8` 19.29.0.0을 Maven 런타임 의존성으로 사용합니다. |

1. 저장소 루트에서 `mvn clean package`를 실행합니다.
2. `target/tickethelper.war`를 Tomcat의 `webapps`에 복사합니다.
3. Tomcat을 실행하고 기본 포트 기준 `http://localhost:8080/tickethelper/health`에 접속합니다. “JSP·Servlet 실행 확인 완료”가 표시되면 Servlet 요청, JSP 포워드와 JSTL 렌더링이 동작한 것입니다.

[Tomcat과 Servlet·JSP 버전 대응표](https://tomcat.apache.org/whichversion.html)

### Oracle JDBC 연결 확인

Oracle 리스너를 실행하고 `CREATE SESSION` 권한이 있는 개발 계정을 사용합니다. 실행할 터미널에 아래 환경변수를 설정합니다.

| 환경변수 | 값 |
| --- | --- |
| `TICKETHELPER_DB_URL` | 개발 DB 연결 URL. 서비스 이름이 `XEPDB1`이면 `jdbc:oracle:thin:@//localhost:1521/XEPDB1`, Oracle XE 11g의 SID가 `XE`이면 `jdbc:oracle:thin:@localhost:1521:XE` |
| `TICKETHELPER_DB_USER` | 개발 계정 이름 |
| `TICKETHELPER_DB_PASSWORD` | 개발 계정 비밀번호 |

저장소 루트에서 `mvn clean package`를 실행한 뒤 JDBC 확인 클래스를 실행합니다.

```powershell
# Windows
java -cp "target/test-classes;target/tickethelper/WEB-INF/lib/*" com.tickethelper.dao.OracleConnectionCheck
```

```sh
# macOS / Linux
java -cp 'target/test-classes:target/tickethelper/WEB-INF/lib/*' com.tickethelper.dao.OracleConnectionCheck
```

연결에 성공하면 `SELECT 1 FROM DUAL` 결과를 확인하고 성공 메시지를 출력합니다. JVM이 환경변수를 읽으므로 DB 비밀번호를 POM이나 명령 인자에 넣을 필요가 없습니다. 이 확인은 #4의 애플리케이션 테이블을 요구하지 않습니다.

## MVC Model 2

브라우저 요청을 Servlet이 받습니다. Servlet은 Service를 호출하고 조회 결과를 요청 속성에 담아 JSP로 전달합니다. 데이터가 필요한 Service는 DAO를 통해 Oracle에 접근합니다.

| 위치 | 책임 |
| --- | --- |
| `controller` | Servlet URL 매핑, 요청 파라미터 읽기, Service 호출, JSP 포워드 또는 리다이렉트 |
| `service` | 유스케이스와 비즈니스 규칙 처리, 여러 DAO 호출 조합 |
| `dao` | Oracle JDBC 접근, SQL 실행, 조회 결과를 DTO에 매핑 |
| `dto` | 계층 사이에 전달하는 데이터 표현 |
| `filter` | 인코딩, 인증과 같이 여러 요청에 공통으로 적용하는 처리 |
| `util` | 특정 계층이나 도메인에 속하지 않는 공통 기능 |
| `WEB-INF/views` | Servlet이 전달한 데이터를 JSP·JSTL·EL로 렌더링. 화면은 HTML5·CSS3·Vanilla JavaScript 사용 |

JSP는 `WEB-INF/views` 아래에 배치하고 Servlet을 통해 접근하게 합니다. SQL은 DAO에, 비즈니스 규칙은 Service에 둡니다.

## 공통 JSP 레이아웃

`<head>`에 `head.jsp`를 포함하면 UTF-8과 모바일 뷰포트 설정, 공통 스타일을 가져옵니다. 페이지별 `<title>`은 각 JSP에서 지정합니다. 공통 헤더와 푸터 사이에 `id="main-content"`가 있는 `<main>`을 두면 본문 바로가기 링크가 작동합니다. `/health`가 이 구조를 사용합니다.

```jsp
<jsp:include page="/WEB-INF/views/common/head.jsp"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<main id="main-content" class="container site-main" tabindex="-1">
    <!-- 페이지별 콘텐츠 -->
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
```

`css/site.css`의 `:root`에서 배경·본문·보조 텍스트·보라색 강조 색상과 타이포그래피를 관리합니다. 본문은 시스템 글꼴 1rem, 보조 텍스트는 .875rem, 제목은 화면 폭에 따라 1.6–2.4rem을 사용합니다.

| 요소 | 클래스와 사용 방법 |
| --- | --- |
| 버튼 | `.button`을 기본으로 사용하고, 화면의 주요 동작에 `.button--primary`를 추가합니다. 이동에는 링크를, 폼 제출에는 버튼을 사용합니다. |
| 카드 | `.card`로 콘텐츠를 묶습니다. 배경, 테두리, 여백과 모서리 모양을 공통 CSS가 제공합니다. |
| 검색 | GET 폼에 `.search-form`, 검색 입력에 `.search-form__input`, 제출 버튼에 `.button`을 사용합니다. 입력에 `<label>` 또는 `aria-label`을 지정합니다. |

`.container`는 콘텐츠 최대 폭을 72rem으로 제한합니다. 40rem 이하에서 좌우 여백을 줄이고 검색 입력과 버튼을 세로로 쌓습니다. 새 화면도 키보드 포커스 표시와 모바일에서의 줄바꿈을 확인합니다.

## 코드와 Git 규칙

- Java 패키지는 소문자, 클래스는 `UpperCamelCase`, 메서드와 변수는 `lowerCamelCase`, 상수는 `UPPER_SNAKE_CASE`를 사용합니다. Java 소스는 UTF-8과 공백 4칸 들여쓰기를 사용합니다.
- JSP와 정적 파일 이름은 `performance-list.jsp`처럼 소문자와 하이픈으로 작성합니다. JSP의 조건과 반복은 JSTL을 사용하고 값은 EL로 표시합니다.
- 최신 `main`에서 `feat/<이슈번호>-<작업명>` 또는 `fix/<이슈번호>-<작업명>` 브랜치를 만들고 `main`으로 PR을 엽니다. 명명과 푸시 절차는 [GitHub 협업 가이드](github.md)를 따릅니다.
- 커밋 제목은 `<유형>: <변경 요약>` 형식을 사용합니다. 기능은 `feat`, 버그 수정은 `fix`, 문서는 `docs`, 개발 환경 설정은 `chore`를 사용합니다. 예시로 `chore: Maven WAR 프로젝트 초기화`가 있습니다.
- Maven 산출물(`target/`), 개인 IDE 설정, 로컬 환경변수와 비밀정보는 Git에서 제외합니다. 공유용 설정 예시에는 샘플 값만 넣습니다.
