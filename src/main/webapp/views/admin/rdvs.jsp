<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:10px;">
            <h2 class="card-title" style="margin-bottom:0; border:none;">
                <i class="fas fa-calendar-alt"></i> Tous les rendez-vous
            </h2>
        </div>

        <c:if test="${not empty messageSucces}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${messageSucces}</div>
            <% session.removeAttribute("messageSucces"); %>
        </c:if>

        <c:choose>
            <c:when test="${empty rdvs}">
                <div style="text-align:center; padding:50px;">
                    <i class="fas fa-calendar-times" style="font-size:48px; color:var(--text-muted); margin-bottom:15px;"></i>
                    <p style="color:var(--text-secondary);">Aucun rendez-vous enregistré.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x:auto;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th><i class="fas fa-user-circle"></i> Patient</th>
                                <th><i class="fas fa-user-md"></i> Médecin</th>
                                <th><i class="fas fa-clock"></i> Date et heure</th>
                                <th><i class="fas fa-map-marker-alt"></i> Lieu</th>
                                <th><i class="fas fa-info-circle"></i> Statut</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${rdvs}">
                                <tr>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:10px;">
                                            <div class="patient-avatar" style="width:35px; height:35px; background:linear-gradient(135deg, #1a73e8, #0d47a1); border-radius:50%; display:flex; align-items:center; justify-content:center; color:white; font-weight:bold;">
                                                ${fn:substring(r.patient.nomPat, 0, 1)}
                                            </div>
                                            <div>
                                                <strong>${r.patient.nomPat}</strong><br>
                                                <small><i class="fas fa-envelope"></i> ${r.patient.email}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:10px;">
                                            <div class="medecin-avatar" style="width:35px; height:35px; background:linear-gradient(135deg, #34a853, #1e7e4a); border-radius:50%; display:flex; align-items:center; justify-content:center; color:white; font-weight:bold;">
                                                ${fn:substring(r.medecin.nommed, 0, 1)}
                                            </div>
                                            <div>
                                                <strong>Dr. ${r.medecin.nommed}</strong><br>
                                                <small><i class="fas fa-stethoscope"></i> ${r.medecin.specialite}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:8px;">
                                            <i class="fas fa-calendar-day" style="color:#1a73e8;"></i>
                                            <span>${r.dateFormatee}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:8px;">
                                            <i class="fas fa-map-marker-alt" style="color:#ea4335;"></i>
                                            <span>${r.medecin.lieu}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.statut == 'CONFIRME'}">
                                                <span class="badge-status confirmed">
                                                    <i class="fas fa-check-circle"></i> Confirmé
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-status cancelled">
                                                    <i class="fas fa-times-circle"></i> Annulé
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
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

<style>
    .admin-table { width:100%; border-collapse:collapse; }
    .admin-table th { text-align:left; padding:12px; background:var(--hover-bg); color:#1a73e8; font-weight:600; }
    .admin-table td { padding:12px; border-bottom:1px solid var(--border-light); vertical-align:middle; }
    .admin-table tr:hover { background:var(--hover-bg); }

    .patient-avatar, .medecin-avatar {
        transition: transform 0.2s ease;
        flex-shrink: 0;
    }
    .admin-table tr:hover .patient-avatar,
    .admin-table tr:hover .medecin-avatar {
        transform: scale(1.1);
    }

    .badge-status {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 500;
    }
    .badge-status.confirmed {
        background: #e6f4ea;
        color: #137333;
    }
    .badge-status.cancelled {
        background: #fce8e6;
        color: #c5221f;
    }

    .admin-table td strong { font-weight: 600; }
    .admin-table td small { font-size: 11px; color: var(--text-muted); }

    @media (max-width: 768px) {
        .admin-table th, .admin-table td { padding: 8px; font-size: 12px; }
        .patient-avatar, .medecin-avatar { width: 28px; height: 28px; font-size: 12px; }
        .badge-status { padding: 2px 8px; font-size: 10px; }
    }
</style>

</body>
</html>