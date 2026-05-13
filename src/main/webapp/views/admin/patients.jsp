<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:10px;">
            <h2 class="card-title" style="margin-bottom:0; border:none;">
                <i class="fas fa-users"></i> Gestion des patients
            </h2>
            <a href="${pageContext.request.contextPath}/admin?action=formPatient" class="btn btn-primary">
                <i class="fas fa-plus-circle"></i> Ajouter un patient
            </a>
        </div>

        <c:if test="${not empty messageSucces}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${messageSucces}</div>
            <% session.removeAttribute("messageSucces"); %>
        </c:if>
        <c:if test="${not empty erreur}">
            <div class="alert alert-danger"><i class="fas fa-exclamation-triangle"></i> ${erreur}</div>
            <% session.removeAttribute("erreur"); %>
        </c:if>

        <!-- Barre de recherche -->
        <div style="margin-bottom:20px;">
            <div style="position:relative;">
                <i class="fas fa-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:#aaa;"></i>
                <input type="text" id="searchPatient" placeholder="Rechercher un patient..."
                       style="width:100%; padding:10px 15px 10px 40px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-card); color:var(--text-primary);">
            </div>
        </div>

        <c:choose>
            <c:when test="${empty patients}">
                <div style="text-align:center; padding:50px;">
                    <i class="fas fa-users" style="font-size:48px; color:var(--text-muted); margin-bottom:15px;"></i>
                    <p style="color:var(--text-secondary);">Aucun patient enregistré.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x:auto;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th><i class="fas fa-user-circle"></i> Nom</th>
                                <th><i class="fas fa-birthday-cake"></i> Date de naissance</th>
                                <th><i class="fas fa-envelope"></i> Email</th>
                                <th style="text-align:center;"><i class="fas fa-cogs"></i> Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${patients}">
                                <tr class="patient-row" data-name="${fn:toLowerCase(p.nomPat)}">
                                    <td>
                                        <div style="display:flex; align-items:center; gap:10px;">
                                            <div class="patient-avatar" style="width:35px; height:35px; background:linear-gradient(135deg, #1a73e8, #0d47a1); border-radius:50%; display:flex; align-items:center; justify-content:center; color:white; font-weight:bold;">
                                                ${fn:substring(p.nomPat, 0, 1)}
                                            </div>
                                            <strong>${p.nomPat}</strong>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:8px;">
                                            <i class="fas fa-calendar-alt" style="color:#1a73e8;"></i>
                                            <span>${p.datenais}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:8px;">
                                            <i class="fas fa-envelope" style="color:#34a853;"></i>
                                            <span>${p.email}</span>
                                        </div>
                                    </td>
                                    <td style="text-align:center;">
                                        <a href="${pageContext.request.contextPath}/admin?action=editPatient&id=${p.idpat}"
                                           class="btn btn-warning btn-sm"><i class="fas fa-edit"></i> Modifier</a>
                                        <a href="${pageContext.request.contextPath}/admin?action=supprimerPatient&id=${p.idpat}"
                                           class="btn btn-danger btn-sm"
                                           onclick="return confirm('Supprimer définitivement ${p.nomPat} ?\n\n⚠️ Tous ses rendez-vous seront également supprimés !')">
                                            <i class="fas fa-trash-alt"></i> Supprimer
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
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
    .admin-table th { text-align:left; padding:12px; background:var(--hover-bg); color:#1a73e8; font-weight:600; }
    .admin-table td { padding:12px; border-bottom:1px solid var(--border-light); vertical-align:middle; }
    .admin-table tr:hover { background:var(--hover-bg); }

    .patient-avatar {
        transition: transform 0.2s ease;
        flex-shrink: 0;
    }
    .admin-table tr:hover .patient-avatar {
        transform: scale(1.1);
    }

    .btn-sm { padding:5px 10px; font-size:12px; margin:0 2px; text-decoration:none; display:inline-block; border-radius:5px; }

    @media (max-width: 768px) {
        .admin-table th, .admin-table td { padding: 8px; font-size: 12px; }
        .patient-avatar { width: 28px; height: 28px; font-size: 12px; }
    }
</style>

</body>
</html>