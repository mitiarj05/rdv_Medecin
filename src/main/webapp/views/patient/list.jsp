<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:10px;">
            <h2 class="card-title" style="margin-bottom:0; border:none;">📋 Liste des patients</h2>
            <div style="display:flex; gap:10px;">
                <div class="search-box" style="position:relative;">
                    <input type="text" id="searchPatient" placeholder="🔍 Rechercher un patient..."
                           style="padding:8px 15px; border-radius:20px; border:1px solid var(--input-border); background:var(--bg-card); color:var(--text-primary); width:200px; transition:all 0.3s ease;">
                </div>
            </div>
        </div>

        <c:if test="${not empty erreur}">
            <div class="alert alert-danger">${erreur}</div>
        </c:if>

        <c:if test="${not empty sessionScope.messageSucces}">
            <div class="alert alert-success">${sessionScope.messageSucces}</div>
            <% session.removeAttribute("messageSucces"); %>
        </c:if>

        <c:choose>
            <c:when test="${empty patients}">
                <div style="text-align:center; padding:50px;">
                    <div style="font-size:48px; margin-bottom:15px;">👥</div>
                    <p style="color:var(--text-secondary);">Aucun patient enregistré.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-container" style="overflow-x:auto;">
                    <table class="patient-table" style="width:100%; border-collapse:collapse;">
                        <thead>
                            <tr>
                                <th style="text-align:left; padding:12px;">Nom</th>
                                <th style="text-align:left; padding:12px;">Date de naissance</th>
                                <th style="text-align:left; padding:12px;">Email</th>
                                <th style="text-align:center; padding:12px;">Âge</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${patients}">
                                <tr class="patient-row" data-name="${fn:toLowerCase(p.nomPat)}" style="border-bottom:1px solid var(--border-light);">
                                    <td style="padding:12px;">
                                        <div style="display:flex; align-items:center; gap:10px;">
                                            <div class="patient-avatar" style="width:35px; height:35px; background:linear-gradient(135deg, #1a73e8, #0d47a1); border-radius:50%; display:flex; align-items:center; justify-content:center; color:white; font-weight:bold;">
                                                ${fn:substring(p.nomPat, 0, 1)}
                                            </div>
                                            <strong>${p.nomPat}</strong>
                                        </div>
                                    </td>
                                    <td style="padding:12px;">${p.datenais}</td>
                                    <td style="padding:12px;">
                                        <a href="mailto:${p.email}" style="color:#1a73e8; text-decoration:none;">${p.email}</a>
                                    </td>
                                    <td style="text-align:center; padding:12px;">
                                        <span class="age-badge" style="background:var(--hover-bg); padding:4px 8px; border-radius:20px; font-size:12px;">
                                            <c:set var="birthYear" value="${fn:substring(p.datenais, 0, 4)}" />
                                            <c:set var="currentYear" value="<%= java.time.Year.now().getValue() %>" />
                                            ${currentYear - birthYear} ans
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Statistiques des patients -->
                <div style="margin-top:20px; padding:15px; background:var(--hover-bg); border-radius:10px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
                    <div>
                        <span style="font-weight:600;">📊 Total patients :</span>
                        <span style="font-size:20px; font-weight:bold; color:#1a73e8; margin-left:8px;">${fn:length(patients)}</span>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<style>
    .patient-table tr {
        transition: all 0.2s ease;
    }

    .patient-table tr:hover {
        background: var(--hover-bg);
    }

    .patient-avatar {
        transition: transform 0.2s ease;
    }

    .patient-row:hover .patient-avatar {
        transform: scale(1.1);
    }

    .search-box input:focus {
        width: 250px;
        outline: none;
        border-color: #1a73e8;
        box-shadow: 0 0 0 3px rgba(26,115,232,0.1);
    }

    .age-badge {
        transition: all 0.2s ease;
    }

    .patient-row:hover .age-badge {
        background: #1a73e8;
        color: white;
    }
</style>

<script>
    // Recherche de patient en temps réel
    document.addEventListener('DOMContentLoaded', function() {
        const searchInput = document.getElementById('searchPatient');
        if (searchInput) {
            searchInput.addEventListener('keyup', function() {
                const searchTerm = this.value.toLowerCase();
                const rows = document.querySelectorAll('.patient-row');
                let visibleCount = 0;
                rows.forEach(row => {
                    const name = row.getAttribute('data-name');
                    if (name && name.includes(searchTerm)) {
                        row.style.display = '';
                        visibleCount++;
                    } else {
                        row.style.display = 'none';
                    }
                });
            });
        }
    });
</script>

</body>
</html>