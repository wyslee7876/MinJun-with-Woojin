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

저장소 루트에서 `mvn clean package`를 실행하면 `target/tickethelper.war`가 생성됩니다. 현재 WAR는 디렉터리 구조를 검증하는 초기 산출물입니다. JDK, Tomcat, Servlet·JSTL 및 Oracle JDBC 설정은 #2에서 다루고, 스키마 설계는 #4에서 진행합니다.

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

## 코드와 Git 규칙

- Java 패키지는 소문자, 클래스는 `UpperCamelCase`, 메서드와 변수는 `lowerCamelCase`, 상수는 `UPPER_SNAKE_CASE`를 사용합니다. Java 소스는 UTF-8과 공백 4칸 들여쓰기를 사용합니다.
- JSP와 정적 파일 이름은 `performance-list.jsp`처럼 소문자와 하이픈으로 작성합니다. JSP의 조건과 반복은 JSTL을 사용하고 값은 EL로 표시합니다.
- 최신 `main`에서 `feat/<이슈번호>-<작업명>` 또는 `fix/<이슈번호>-<작업명>` 브랜치를 만들고 `main`으로 PR을 엽니다. 명명과 푸시 절차는 [GitHub 협업 가이드](github.md)를 따릅니다.
- 커밋 제목은 `<유형>: <변경 요약>` 형식을 사용합니다. 기능은 `feat`, 버그 수정은 `fix`, 문서는 `docs`, 개발 환경 설정은 `chore`를 사용합니다. 예시로 `chore: Maven WAR 프로젝트 초기화`가 있습니다.
- Maven 산출물(`target/`), 개인 IDE 설정, 로컬 환경변수와 비밀정보는 Git에서 제외합니다. 공유용 설정 예시에는 샘플 값만 넣습니다.
