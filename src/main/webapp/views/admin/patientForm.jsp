<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card" style="max-width:560px; margin:0 auto;">
        <h2 class="card-title">
            <c:choose>
                <c:when test="${not empty patient}">✏️ Modifier le patient</c:when>
                <c:otherwise>👤 Nouveau patient</c:otherwise>
            </c:choose>
        </h2>

        <c:if test="${not empty erreur}">
            <div class="alert alert-danger">${erreur}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/admin" method="post">
            <input type="hidden" name="action" value="enregistrerPatient">
            <input type="hidden" name="idpat" value="${patient.idpat}">

            <div class="form-group">
                <label>Nom complet</label>
                <input type="text" name="nom_pat" value="${patient.nomPat}" required>
            </div>

            <div class="form-group">
                <label>Date de naissance</label>
                <input type="date" name="datenais" value="${patient.datenais}" required>
            </div>

            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" value="${patient.email}" required>
            </div>

            <c:if test="${empty patient}">
                <div class="form-group">
                    <label>Mot de passe temporaire</label>
                    <input type="password" name="password" required>
                    <small style="color: #666;">Le patient pourra modifier son mot de passe après connexion</small>
                </div>
            </c:if>

            <div style="display:flex; gap:10px; margin-top:20px;">
                <button type="submit" class="btn btn-primary" style="flex:1;">
                    <c:choose>
                        <c:when test="${not empty patient}">Enregistrer les modifications</c:when>
                        <c:otherwise>Créer le patient</c:otherwise>
                    </c:choose>
                </button>
                <a href="${pageContext.request.contextPath}/admin?action=patients" class="btn btn-secondary" style="flex:1; text-align:center;">Annuler</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>