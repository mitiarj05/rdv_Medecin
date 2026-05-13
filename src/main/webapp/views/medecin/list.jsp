<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:10px;">
            <h2 class="card-title" style="margin-bottom:0; border:none;">
                <i class="fas fa-users"></i> Liste des patients
            </h2>
            <div style="display:flex; gap:10px;">
                <div class="search-box" style="position:relative;">
                    <i class="fas fa-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:#aaa;"></i>
                    <input type="text" id="searchPatient" placeholder="Rechercher un patient..."
                           style="padding:8px 15px 8px 40px; border-radius:20px; border:1px solid var(--input-border); background:var(--bg-card); color:var(--text-primary); width:220px; transition:all 0.3s ease;">
                </div>
            </div>
        </div>

        <c:if test="${not empty erreur}">
            <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${erreur}</div>
        </c:if>

        <c:if test="${not empty sessionScope.messageSucces}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${sessionScope.messageSucces}</div>
            <% session.removeAttribute("messageSucces"); %>
        </c:if>

        <c:choose>
            <c:when test="${empty patients}">
                <div style="text-align:center; padding:50px;">
                    <i class="fas fa-users" style="font-size:48px; color:var(--text-muted); margin-bottom:15px;"></i>
                    <p style="color:var(--text-secondary);">Aucun patient enregistré.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-container" style="overflow-x:auto;">
                    <table class="patient-table">
                        <thead>
                            <tr>
                                <th><i class="fas fa-user"></i> Nom</th>
                                <th><i class="fas fa-calendar-alt"></i> Date de naissance</th>
                                <th><i class="fas fa-envelope"></i> Email</th>
                                <th style="text-align:center;"><i class="fas fa-hourglass-half"></i> Âge</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${patients}">
                                <tr class="patient-row" data-name="${fn:toLowerCase(p.nomPat)}">
                                    <td>
                                        <div class="patient-info">
                                            <div class="patient-avatar">${fn:substring(p.nomPat, 0, 1)}</div>
                                            <strong>${p.nomPat}</strong>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="info-cell">
                                            <i class="fas fa-calendar-alt"></i>
                                            <span>${p.datenais}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="info-cell">
                                            <i class="fas fa-envelope"></i>
                                            <span>${p.email}</span>
                                        </div>
                                    </td>
                                    <td style="text-align:center;">
                                        <div class="age-badge">
                                            <c:set var="birthYear" value="${fn:substring(p.datenais, 0, 4)}" />
                                            <c:set var="currentYear" value="<%= java.time.Year.now().getValue() %>" />
                                            ${currentYear - birthYear} ans
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Statistiques des patients -->
                <div class="stats-footer">
                    <i class="fas fa-chart-simple"></i>
                    <span style="font-weight:600;">Total patients :</span>
                    <span class="total-count">${fn:length(patients)}</span>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<style>
    .patient-table {
        width: 100%;
        border-collapse: collapse;
    }
    .patient-table th {
        text-align: left;
        padding: 14px;
        background: var(--hover-bg);
        color: #1a73e8;
        font-weight: 600;
        font-size: 14px;
    }
    .patient-table td {
        padding: 14px;
        border-bottom: 1px solid var(--border-light);
        vertical-align: middle;
    }
    .patient-table tr:hover {
        background: var(--hover-bg);
    }

    .patient-info {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .patient-avatar {
        width: 36px;
        height: 36px;
        background: linear-gradient(135deg, #1a73e8, #0d47a1);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: bold;
        font-size: 14px;
        transition: transform 0.2s ease;
    }
    .patient-table tr:hover .patient-avatar {
        transform: scale(1.1);
    }

    .info-cell {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .info-cell i {
        width: 20px;
        color: #1a73e8;
        font-size: 14px;
    }
    .info-cell span {
        color: var(--text-primary);
    }

    .age-badge {
        background: linear-gradient(135deg, #1a73e8, #0d47a1);
        color: white;
        padding: 5px 12px;
        border-radius: 20px;
        font-size: 12px;
        display: inline-block;
        font-weight: 500;
    }

    .stats-footer {
        margin-top: 20px;
        padding: 15px;
        background: var(--hover-bg);
        border-radius: 10px;
        display: flex;
        align-items: center;
        gap: 10px;
        flex-wrap: wrap;
    }
    .stats-footer i {
        font-size: 18px;
        color: #1a73e8;
    }
    .total-count {
        font-size: 22px;
        font-weight: bold;
        color: #1a73e8;
        margin-left: 5px;
    }

    .search-box input:focus {
        width: 250px;
        outline: none;
        border-color: #1a73e8;
        box-shadow: 0 0 0 3px rgba(26,115,232,0.1);
    }

    @media (max-width: 768px) {
        .patient-table th, .patient-table td {
            padding: 10px;
            font-size: 13px;
        }
        .patient-avatar {
            width: 30px;
            height: 30px;
            font-size: 12px;
        }
        .info-cell i {
            width: 16px;
            font-size: 12px;
        }
    }
</style>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const searchInput = document.getElementById('searchPatient');
        if (searchInput) {
            searchInput.addEventListener('keyup', function() {
                const searchTerm = this.value.toLowerCase();
                const rows = document.querySelectorAll('.patient-row');
                rows.forEach(row => {
                    const name = row.getAttribute('data-name');
                    if (name && name.includes(searchTerm)) {
                        row.style.display = '';
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