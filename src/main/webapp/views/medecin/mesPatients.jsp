<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:10px;">
            <h2 class="card-title" style="margin-bottom:0; border:none;">
                <i class="fas fa-heartbeat"></i> Mes patients
            </h2>
            <div>
                <span class="total-badge">
                    <i class="fas fa-users"></i> Total:
                    <c:choose>
                        <c:when test="${not empty patientsDuMedecin}">
                            ${fn:length(patientsDuMedecin)}
                        </c:when>
                        <c:otherwise>0</c:otherwise>
                    </c:choose>
                    patients
                </span>
            </div>
        </div>

        <c:if test="${not empty erreur}">
            <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${erreur}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${success}</div>
        </c:if>

        <!-- Explication -->
        <div class="info-box">
            <i class="fas fa-info-circle"></i>
            <strong>Information :</strong> Le bouton "Retirer" supprime ce patient de VOTRE liste de patients,
            mais ne supprime pas son compte définitivement. Le patient peut toujours consulter d'autres médecins.
        </div>

        <c:choose>
            <c:when test="${empty patientsDuMedecin or fn:length(patientsDuMedecin) == 0}">
                <div style="text-align:center; padding:50px;">
                    <i class="fas fa-user-slash" style="font-size:48px; color:var(--text-muted); margin-bottom:15px;"></i>
                    <p style="color:var(--text-secondary);">Vous n'avez pas encore de patients.</p>
                    <p style="font-size:13px; color:var(--text-muted);">Les patients prendront rendez-vous avec vous via la plateforme.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x:auto;">
                    <table class="patients-table">
                        <thead>
                            <tr>
                                <th><i class="fas fa-user"></i> Patient</th>
                                <th><i class="fas fa-envelope"></i> Email</th>
                                <th><i class="fas fa-calendar-alt"></i> Date de naissance</th>
                                <th style="text-align:center;"><i class="fas fa-calendar-check"></i> Nb RDV</th>
                                <th><i class="fas fa-clock"></i> Dernier RDV</th>
                                <th style="text-align:center;"><i class="fas fa-cogs"></i> Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="patient" items="${patientsDuMedecin}">
                                <tr>
                                    <td>
                                        <div class="patient-info">
                                            <div class="patient-avatar">${fn:substring(patient.nomPat, 0, 1)}</div>
                                            <strong>${patient.nomPat}</strong>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="info-cell">
                                            <i class="fas fa-envelope"></i>
                                            <span>${patient.email}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="info-cell">
                                            <i class="fas fa-calendar-alt"></i>
                                            <span>${patient.datenais}</span>
                                        </div>
                                    </td>
                                    <td style="text-align:center;">
                                        <div class="rdv-count">${patient.nbRendezVous}</div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty patient.dernierRdv}">
                                                <div class="info-cell">
                                                    <i class="fas fa-clock"></i>
                                                    <span>${patient.dernierRdv}</span>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: var(--text-muted);">Aucun RDV</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align:center;">
                                        <a href="${pageContext.request.contextPath}/medecin?action=retirerPatient&idPatient=${patient.idpat}"
                                           class="btn btn-danger btn-sm"
                                           onclick="return confirm('Retirer ${patient.nomPat} de votre liste de patients ?\n\n⚠️ Cela ne supprime PAS son compte, juste son association avec vous.');">
                                            <i class="fas fa-user-minus"></i> Retirer
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

<style>
    .patients-table {
        width: 100%;
        border-collapse: collapse;
    }
    .patients-table th {
        text-align: left;
        padding: 14px;
        background: var(--hover-bg);
        color: #1a73e8;
        font-weight: 600;
        font-size: 14px;
    }
    .patients-table td {
        padding: 14px;
        border-bottom: 1px solid var(--border-light);
        vertical-align: middle;
    }
    .patients-table tr:hover {
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
    .patients-table tr:hover .patient-avatar {
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

    .rdv-count {
        background: linear-gradient(135deg, #1a73e8, #0d47a1);
        color: white;
        padding: 5px 12px;
        border-radius: 20px;
        font-size: 13px;
        font-weight: bold;
        display: inline-block;
        text-align: center;
        min-width: 40px;
    }

    .total-badge {
        background: #e6f4ea;
        color: #137333;
        padding: 6px 15px;
        border-radius: 20px;
        font-size: 13px;
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    .info-box {
        background: #e7f3ff;
        padding: 12px 16px;
        border-radius: 10px;
        margin-bottom: 20px;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 10px;
        color: #1a73e8;
    }

    .btn-sm {
        padding: 6px 12px;
        font-size: 12px;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        border-radius: 6px;
        background-color: #dc3545;
        color: white;
        border: none;
        cursor: pointer;
    }
    .btn-sm:hover {
        background-color: #c82333;
        transform: translateY(-1px);
    }

    @media (max-width: 768px) {
        .patients-table th, .patients-table td {
            padding: 10px;
            font-size: 12px;
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
        .rdv-count {
            padding: 3px 8px;
            font-size: 11px;
        }
        .btn-sm {
            padding: 4px 8px;
            font-size: 10px;
        }
    }
</style>

</body>
</html>