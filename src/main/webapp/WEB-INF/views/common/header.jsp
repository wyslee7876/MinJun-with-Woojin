<%@ page pageEncoding="UTF-8" session="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:url var="brandUrl" value="/health"/>
<a class="skip-link" href="#main-content">본문 바로가기</a>
<header class="site-header">
    <div class="container site-header__inner">
        <a class="brand" href="<c:out value="${brandUrl}"/>">
            <span class="brand__mark" aria-hidden="true">★</span>
            <span>티켓헬퍼</span>
        </a>
        <span class="site-header__description">공연 탐색 · 예매 도우미</span>
    </div>
</header>
