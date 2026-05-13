<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <h2 class="card-title" style="margin-bottom:0;">
                <i class="fas fa-users"></i> Liste des patients
            </h2>
            <a href="${pageContext.request.contextPath}/admin?action=formPatient" class="btn btn-primary">
                ➕ Ajouter un patient
            </a>
        </div>

        <c:if test="${not empty messageSucces}">
            <div class="alert alert-success">${messageSucces}</div>
            <% session.removeAttribute("messageSucces"); %>
        </c:if>
        <c:if test="${not empty erreur}">
            <div class="alert alert-danger">${erreur}</div>
            <% session.removeAttribute("erreur"); %>
        </c:if>

        <!-- Barre de recherche -->
        <div style="margin-bottom:20px;">
            <input type="text" id="searchPatient" placeholder="🔍 Rechercher un patient..."
                   style="width:100%; padding:10px 15px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-card); color:var(--text-primary);">
        </div>

        <c:choose>
            <c:when test="${empty patients}">
                <div style="text-align:center; padding:50px;">
                    <p>Aucun patient enregistré.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x:auto;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Nom</th>
                                <th>Date de naissance</th>
                                <th>Email</th>
                                <th style="text-align:center;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${patients}">
                                <tr class="patient-row" data-name="${fn:toLowerCase(p.nomPat)}">
                                    <td><strong>${p.nomPat}</strong></td>
                                    <td>${p.datenais}</td>
                                    <td>${p.email}</td>
                                    <td style="text-align:center;">
                                        <a href="${pageContext.request.contextPath}/admin?action=editPatient&id=${p.idpat}"
                                           class="btn btn-warning btn-sm">✏️ Modifier</a>
                                        <a href="${pageContext.request.contextPath}/admin?action=supprimerPatient&id=${p.idpat}"
                                           class="btn btn-danger btn-sm"
                                           onclick="return confirm('Supprimer définitivement ${p.nomPat} ?\n\n⚠️ Tous ses rendez-vous seront également supprimés !')">
                                            🗑️ Supprimer
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>

        <div style="margin-top:20px; text-align:center;">
            <a href="${pageContext.request.contextPath}/admin?action=dashboard" class="btn btn-secondary">
                ← Retour au dashboard
            </a>
        </div>
    </div>
</div>

<script>
    document.getElementById('searchPatient').addEventListener('keyup', function() {
        let searchTerm = this.value.toLowerCase();
        let rows = document.querySelectorAll('.patient-row');
        rows.forEach(row => {
            let name = row.getAttribute('data-name');
            if (name && name.includes(searchTerm)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
</script>

<style>
    .admin-table { width:100%; border-collapse:collapse; }
    .admin-table th { text-align:left; padding:12px; background:var(--hover-bg); color:#1a73e8; }
    .admin-table td { padding:12px; border-bottom:1px solid var(--border-light); }
    .admin-table tr:hover { background:var(--hover-bg); }
    .btn-sm { padding:5px 10px; font-size:12px; margin:0 2px; text-decoration:none; display:inline-block; border-radius:5px; }
</style>

</body>
</html>