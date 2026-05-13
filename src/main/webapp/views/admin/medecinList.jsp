<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <h2 class="card-title" style="margin-bottom:0;">
                <i class="fas fa-users"></i> Liste des médecins
            </h2>
            <a href="${pageContext.request.contextPath}/admin?action=formMedecin" class="btn btn-primary">
                ➕ Ajouter un médecin
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
            <input type="text" id="searchMedecin" placeholder="🔍 Rechercher un médecin..."
                   style="width:100%; padding:10px 15px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-card); color:var(--text-primary);">
        </div>

        <c:choose>
            <c:when test="${empty medecins}">
                <div style="text-align:center; padding:50px;">
                    <p>Aucun médecin enregistré.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x:auto;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Nom</th>
                                <th>Spécialité</th>
                                <th>Lieu</th>
                                <th>Taux horaire</th>
                                <th>Email</th>
                                <th style="text-align:center;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="m" items="${medecins}">
                                <tr class="medecin-row" data-name="${fn:toLowerCase(m.nommed)}">
                                    <td><strong>Dr. ${m.nommed}</strong></td>
                                    <td>${m.specialite}</td>
                                    <td>${m.lieu}</td>
                                    <td>${m.tauxHoraire} Ar</td>
                                    <td>${m.email}</td>
                                    <td style="text-align:center;">
                                        <a href="${pageContext.request.contextPath}/rdv?action=horaires&idmed=${m.idmed}"
                                           class="btn btn-primary btn-sm">
                                            📅 Voir créneaux
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin?action=editMedecin&id=${m.idmed}"
                                           class="btn btn-warning btn-sm">
                                            ✏️ Modifier
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin?action=supprimerMedecin&id=${m.idmed}"
                                           class="btn btn-danger btn-sm"
                                           onclick="return confirm('Supprimer définitivement ${m.nommed} ?\n\n⚠️ Tous ses rendez-vous seront également supprimés !')">
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
    document.getElementById('searchMedecin').addEventListener('keyup', function() {
        let searchTerm = this.value.toLowerCase();
        let rows = document.querySelectorAll('.medecin-row');
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