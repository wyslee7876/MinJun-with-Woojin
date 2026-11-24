<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/views/common/head.jsp"/>
    <title>티켓헬퍼 실행 확인</title>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/header.jsp"/>
    <main id="main-content" class="container site-main" tabindex="-1">
        <section class="card health-card" aria-labelledby="health-title">
            <div class="health-card__status"><span aria-hidden="true">✓</span> 웹 애플리케이션 정상 동작</div>
            <h1 id="health-title"><c:out value="${message}"/></h1>
            <p>Tomcat이 Servlet 요청을 처리하고, JSP가 JSTL을 사용해 응답을 표시했습니다.</p>
            <c:url var="healthUrl" value="/health"/>
            <a class="button button--primary" href="<c:out value="${healthUrl}"/>">다시 확인</a>
        </section>
    </main>
    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
