<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <h2 class="card-title">
            <i class="fas fa-crown"></i> Panneau d'administration
        </h2>

        <c:if test="${not empty messageSucces}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${messageSucces}</div>
            <% session.removeAttribute("messageSucces"); %>
        </c:if>
        <c:if test="${not empty erreur}">
            <div class="alert alert-danger"><i class="fas fa-exclamation-triangle"></i> ${erreur}</div>
            <% session.removeAttribute("erreur"); %>
        </c:if>

        <!-- Statistiques -->
        <div class="stats-grid">
            <div class="stat-card" style="text-align:center;">
                <div class="stat-icon"><i class="fas fa-user-md"></i></div>
                <div class="stat-number">${totalMedecins}</div>
                <div class="stat-label">Médecins</div>
            </div>
            <div class="stat-card" style="text-align:center;">
                <div class="stat-icon"><i class="fas fa-users"></i></div>
                <div class="stat-number">${totalPatients}</div>
                <div class="stat-label">Patients</div>
            </div>
            <div class="stat-card" style="text-align:center;">
                <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                <div class="stat-number">${totalRdvs}</div>
                <div class="stat-label">Total RDV</div>
            </div>
            <div class="stat-card" style="text-align:center;">
                <div class="stat-icon"><i class="fas fa-chart-line"></i></div>
                <div class="stat-number">${rdvsMois}</div>
                <div class="stat-label">RDV ce mois</div>
            </div>
        </div>

        <!-- Actions rapides -->
        <div style="background:var(--hover-bg); border-radius:12px; padding:20px;">
            <h3 style="margin-bottom:15px;"><i class="fas fa-bolt"></i> Actions rapides</h3>
            <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(200px,1fr)); gap:15px;">
                <a href="${pageContext.request.contextPath}/admin?action=formMedecin" class="btn btn-primary" style="text-align:center;">
                    <i class="fas fa-plus-circle"></i> Ajouter un médecin
                </a>
                <a href="${pageContext.request.contextPath}/admin?action=formPatient" class="btn btn-success" style="text-align:center;">
                    <i class="fas fa-plus-circle"></i> Ajouter un patient
                </a>
                <a href="${pageContext.request.contextPath}/admin?action=medecins" class="btn btn-warning" style="text-align:center;">
                    <i class="fas fa-list"></i> Liste des médecins
                </a>
                <a href="${pageContext.request.contextPath}/admin?action=patients" class="btn btn-info" style="text-align:center; background:#17a2b8; color:white;">
                    <i class="fas fa-list"></i> Liste des patients
                </a>
                <a href="${pageContext.request.contextPath}/admin?action=rdvs" class="btn btn-secondary" style="text-align:center;">
                    <i class="fas fa-calendar-alt"></i> Tous les RDV
                </a>
            </div>
        </div>
    </div>
</div>

<style>
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    .stat-card {
        background: var(--bg-card);
        border-radius: 12px;
        padding: 20px;
        text-align: center;
        transition: all 0.2s ease;
        border: 1px solid var(--border-color);
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }
    .stat-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 20px var(--shadow-hover);
        border-color: #1a73e8;
    }
    .stat-icon {
        width: 50px;
        height: 50px;
        background: linear-gradient(135deg, #1a73e8, #0d47a1);
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 12px;
        color: white;
        font-size: 24px;
    }
    .stat-number {
        font-size: 28px;
        font-weight: bold;
        color: #1a73e8;
        margin-bottom: 5px;
    }
    .stat-label {
        font-size: 13px;
        color: var(--text-secondary);
    }
    .btn-info { background: #17a2b8; color: white; }
    .btn-info:hover { background: #138496; }
</style>

</body>
</html>