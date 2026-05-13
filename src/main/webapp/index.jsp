<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:choose>
    <c:when test="${sessionScope.role == 'medecin'}">
        <c:redirect url="medecin?action=dashboard"/>
    </c:when>
    <c:when test="${sessionScope.role == 'patient'}">
        <c:redirect url="patient?action=dashboard"/>
    </c:when>
    <c:otherwise>
        <c:redirect url="views/shared/login.jsp"/>
    </c:otherwise>
</c:choose>