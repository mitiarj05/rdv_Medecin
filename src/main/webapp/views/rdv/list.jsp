<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:10px;">
            <h2 class="card-title" style="margin-bottom:0; border:none;">
                <i class="fas fa-calendar-alt"></i> Mes rendez-vous
            </h2>
            <c:if test="${sessionScope.role == 'patient'}">
                <a href="${pageContext.request.contextPath}/search" class="btn btn-primary">
                    <i class="fas fa-plus-circle"></i> Prendre un RDV
                </a>
            </c:if>
        </div>

        <c:if test="${not empty erreur}">
            <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${erreur}</div>
        </c:if>
        <c:if test="${not empty succes}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${succes}</div>
        </c:if>

        <!-- Légende -->
        <div class="legend-container">
            <span><i class="fas fa-check-circle" style="color:#34a853;"></i> Confirmé → Modifier ou Annuler</span>
            <span><i class="fas fa-times-circle" style="color:#ea4335;"></i> Annulé → Modifier ou Supprimer</span>
        </div>

        <c:choose>
            <c:when test="${empty rdvs}">
                <div style="text-align:center; padding:50px;">
                    <i class="fas fa-calendar-times" style="font-size:48px; color:var(--text-muted); margin-bottom:15px;"></i>
                    <p style="color:var(--text-secondary);">Aucun rendez-vous pour le moment.</p>
                    <c:if test="${sessionScope.role == 'patient'}">
                        <a href="${pageContext.request.contextPath}/search" class="btn btn-primary">
                            <i class="fas fa-search"></i> Trouver un médecin
                        </a>
                    </c:if>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x:auto;">
                    <table class="rdv-table">
                        <thead>
                            <tr>
                                <c:choose>
                                    <c:when test="${sessionScope.role == 'medecin'}">
                                        <th><i class="fas fa-user"></i> Patient</th>
                                        <th><i class="fas fa-envelope"></i> Email</th>
                                    </c:when>
                                    <c:otherwise>
                                        <th><i class="fas fa-user-md"></i> Médecin</th>
                                        <th><i class="fas fa-stethoscope"></i> Spécialité</th>
                                    </c:otherwise>
                                </c:choose>
                                <th><i class="fas fa-clock"></i> Date et heure</th>
                                <th><i class="fas fa-map-marker-alt"></i> Lieu</th>
                                <th><i class="fas fa-info-circle"></i> Statut</th>
                                <th><i class="fas fa-cogs"></i> Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${rdvs}">
                                <c:choose>
                                    <c:when test="${sessionScope.role == 'medecin'}">
                                        <!-- Ligne pour le médecin -->
                                        <tr>
                                            <td>
                                                <div class="patient-info">
                                                    <div class="avatar">${fn:substring(r.patient.nomPat, 0, 1)}</div>
                                                    <strong>${r.patient.nomPat}</strong>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="info-cell">
                                                    <i class="fas fa-envelope"></i>
                                                    <span>${r.patient.email}</span>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="info-cell">
                                                    <i class="fas fa-calendar-alt"></i>
                                                    <span>${r.dateFormatee}</span>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="info-cell">
                                                    <i class="fas fa-map-marker-alt"></i>
                                                    <span>${r.medecin.lieu}</span>
                                                </div>
                                            </td>
                                            <td style="text-align:center;">
                                                <c:choose>
                                                    <c:when test="${r.statut == 'CONFIRME'}">
                                                        <span class="badge-status confirmed"><i class="fas fa-check-circle"></i> Confirmé</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-status cancelled"><i class="fas fa-times-circle"></i> Annulé</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align:center;">
                                                <c:choose>
                                                    <c:when test="${r.statut == 'CONFIRME'}">
                                                        <a href="${pageContext.request.contextPath}/rdv?action=edit&id=${r.idrdv}" class="btn btn-warning btn-sm">
                                                            <i class="fas fa-edit"></i> Modifier
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/rdv?action=annuler&id=${r.idrdv}" class="btn btn-danger btn-sm"
                                                           onclick="return confirm('Annuler ce rendez-vous ? Un email sera envoyé.')">
                                                            <i class="fas fa-times"></i> Annuler
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/rdv?action=edit&id=${r.idrdv}" class="btn btn-warning btn-sm">
                                                            <i class="fas fa-edit"></i> Modifier
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/rdv?action=supprimer&id=${r.idrdv}" class="btn btn-secondary btn-sm"
                                                           onclick="return confirm('Supprimer définitivement ce RDV ?')">
                                                            <i class="fas fa-trash-alt"></i> Supprimer
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- Ligne pour le patient -->
                                        <tr>
                                            <td>
                                                <div class="patient-info">
                                                    <div class="avatar doctor-avatar">${fn:substring(r.medecin.nommed, 0, 1)}</div>
                                                    <strong>Dr. ${r.medecin.nommed}</strong>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="info-cell">
                                                    <i class="fas fa-stethoscope"></i>
                                                    <span>${r.medecin.specialite != null ? r.medecin.specialite : 'Non spécifiée'}</span>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="info-cell">
                                                    <i class="fas fa-calendar-alt"></i>
                                                    <span>${r.dateFormatee}</span>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="info-cell">
                                                    <i class="fas fa-map-marker-alt"></i>
                                                    <span>${r.medecin.lieu}</span>
                                                </div>
                                            </td>
                                            <td style="text-align:center;">
                                                <c:choose>
                                                    <c:when test="${r.statut == 'CONFIRME'}">
                                                        <span class="badge-status confirmed"><i class="fas fa-check-circle"></i> Confirmé</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-status cancelled"><i class="fas fa-times-circle"></i> Annulé</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align:center;">
                                                <c:choose>
                                                    <c:when test="${r.statut == 'CONFIRME'}">
                                                        <a href="${pageContext.request.contextPath}/rdv?action=edit&id=${r.idrdv}" class="btn btn-warning btn-sm">
                                                            <i class="fas fa-edit"></i> Modifier
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/rdv?action=annuler&id=${r.idrdv}" class="btn btn-danger btn-sm"
                                                           onclick="return confirm('Annuler ce rendez-vous ? Un email sera envoyé.')">
                                                            <i class="fas fa-times"></i> Annuler
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/rdv?action=edit&id=${r.idrdv}" class="btn btn-warning btn-sm">
                                                            <i class="fas fa-edit"></i> Modifier
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/rdv?action=supprimer&id=${r.idrdv}" class="btn btn-secondary btn-sm"
                                                           onclick="return confirm('Supprimer définitivement ce RDV ?')">
                                                            <i class="fas fa-trash-alt"></i> Supprimer
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<style>
    .rdv-table {
        width: 100%;
        border-collapse: collapse;
    }
    .rdv-table th {
        text-align: left;
        padding: 14px;
        background: var(--hover-bg);
        color: #1a73e8;
        font-weight: 600;
        font-size: 14px;
    }
    .rdv-table td {
        padding: 14px;
        border-bottom: 1px solid var(--border-light);
        vertical-align: middle;
    }
    .rdv-table tr:hover {
        background: var(--hover-bg);
    }

    .patient-info {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .avatar {
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
    .doctor-avatar {
        background: linear-gradient(135deg, #34a853, #1e7e4a);
    }
    .rdv-table tr:hover .avatar {
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

    .badge-status {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 5px 12px;
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

    .legend-container {
        display: flex;
        gap: 25px;
        margin-bottom: 16px;
        font-size: 12px;
        color: var(--text-secondary);
        flex-wrap: wrap;
        padding: 8px 0;
    }
    .legend-container i {
        margin-right: 4px;
    }

    .btn-sm {
        padding: 6px 12px;
        font-size: 12px;
        margin: 0 3px;
        text-decoration: none;
        display: inline-block;
        border-radius: 6px;
    }

    @media (max-width: 768px) {
        .rdv-table th, .rdv-table td {
            padding: 10px;
            font-size: 12px;
        }
        .avatar {
            width: 30px;
            height: 30px;
            font-size: 12px;
        }
        .info-cell i {
            width: 16px;
            font-size: 12px;
        }
        .btn-sm {
            padding: 4px 8px;
            font-size: 10px;
        }
    }
</style>

</body>
</html>