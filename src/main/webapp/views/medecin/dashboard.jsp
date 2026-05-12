<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<!-- Ajout de FontAwesome pour les icônes professionnelles -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<style>
    :root {
        --primary: #0d6efd;
        --primary-dark: #0a58ca;
        --secondary: #6c757d;
        --success: #198754;
        --warning: #ffc107;
        --danger: #dc3545;
        --info: #0dcaf0;
        --dark: #212529;
        --light: #f8f9fa;
        --white: #ffffff;
        --gray-100: #f8f9fa;
        --gray-200: #e9ecef;
        --gray-300: #dee2e6;
        --gray-400: #ced4da;
        --gray-500: #adb5bd;
        --gray-600: #6c757d;
        --gray-700: #495057;
        --gray-800: #343a40;
        --gray-900: #212529;
        --shadow-sm: 0 0.125rem 0.25rem rgba(0,0,0,0.075);
        --shadow: 0 0.5rem 1rem rgba(0,0,0,0.08);
        --shadow-lg: 0 1rem 3rem rgba(0,0,0,0.1);
        --border-radius: 0.75rem;
        --border-radius-lg: 1rem;
        --transition: all 0.2s ease-in-out;
    }

    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        background: linear-gradient(135deg, #f5f7fa 0%, #e9ecef 100%);
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }

    .container {
        max-width: 1400px;
        margin: 2rem auto;
        padding: 0 1.5rem;
    }

    /* Cartes modernes */
    .card {
        background: var(--white);
        border-radius: var(--border-radius);
        box-shadow: var(--shadow);
        padding: 1.5rem;
        transition: var(--transition);
        border: 1px solid rgba(0,0,0,0.05);
    }

    .card:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-lg);
    }

    .card-title {
        font-size: 1.25rem;
        font-weight: 600;
        margin-bottom: 1.25rem;
        color: var(--gray-800);
        display: flex;
        align-items: center;
        gap: 0.5rem;
        border-left: 3px solid var(--primary);
        padding-left: 0.75rem;
    }

    .card-title i {
        color: var(--primary);
        font-size: 1.1rem;
    }

    /* Bannière de bienvenue */
    .welcome-banner {
        background: linear-gradient(135deg, #1a56db 0%, #0d3b8a 100%);
        border-radius: var(--border-radius-lg);
        padding: 2rem;
        margin-bottom: 2rem;
        color: white;
        position: relative;
        overflow: hidden;
    }

    .welcome-banner::before {
        content: '';
        position: absolute;
        top: -50%;
        right: -10%;
        width: 300px;
        height: 300px;
        background: rgba(255,255,255,0.05);
        border-radius: 50%;
        pointer-events: none;
    }

    .welcome-banner::after {
        content: '';
        position: absolute;
        bottom: -30%;
        left: -5%;
        width: 200px;
        height: 200px;
        background: rgba(255,255,255,0.03);
        border-radius: 50%;
        pointer-events: none;
    }

    .doctor-info h2 {
        font-size: 1.75rem;
        font-weight: 600;
        margin-bottom: 0.5rem;
    }

    .doctor-stats {
        background: rgba(255,255,255,0.15);
        backdrop-filter: blur(10px);
        border-radius: var(--border-radius);
        padding: 1rem 1.5rem;
        text-align: center;
        min-width: 150px;
    }

    .doctor-stats .stat-number {
        font-size: 2rem;
        font-weight: 700;
        line-height: 1;
    }

    /* Statistiques clés */
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 1.25rem;
        margin-bottom: 2rem;
    }

    .stat-card {
        background: var(--white);
        border-radius: var(--border-radius);
        padding: 1.25rem;
        text-align: center;
        transition: var(--transition);
        border: 1px solid var(--gray-200);
        box-shadow: var(--shadow-sm);
    }

    .stat-card:hover {
        transform: translateY(-3px);
        box-shadow: var(--shadow);
        border-color: var(--primary);
    }

    .stat-icon {
        width: 50px;
        height: 50px;
        background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
        border-radius: 1rem;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 0.75rem;
        color: white;
        font-size: 1.5rem;
    }

    .stat-number {
        font-size: 1.75rem;
        font-weight: 700;
        color: var(--gray-800);
        margin-bottom: 0.25rem;
    }

    .stat-label {
        font-size: 0.85rem;
        color: var(--gray-600);
        font-weight: 500;
    }

    /* Badges et alertes */
    .alert {
        padding: 1rem 1.25rem;
        border-radius: var(--border-radius);
        margin-bottom: 1.5rem;
        background: #d1e7dd;
        border-left: 4px solid var(--success);
        color: #0f5132;
    }

    .btn {
        padding: 0.5rem 1rem;
        border-radius: 0.5rem;
        font-weight: 500;
        font-size: 0.875rem;
        transition: var(--transition);
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        text-decoration: none;
    }

    .btn-primary {
        background: var(--primary);
        color: white;
    }

    .btn-primary:hover {
        background: var(--primary-dark);
        transform: translateY(-1px);
    }

    .btn-warning {
        background: var(--warning);
        color: #000;
    }

    .btn-danger {
        background: var(--danger);
        color: white;
    }

    .btn-sm {
        padding: 0.375rem 0.75rem;
        font-size: 0.75rem;
    }

    /* Prochain RDV */
    .next-appointment {
        background: var(--gray-100);
        border-radius: var(--border-radius);
        padding: 1.25rem;
        border-left: 4px solid var(--primary);
    }

    /* Liste patients */
    .patient-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0.75rem 0;
        border-bottom: 1px solid var(--gray-200);
        transition: var(--transition);
    }

    .patient-item:hover {
        background: var(--gray-100);
        padding-left: 0.5rem;
    }

    .patient-name {
        font-weight: 600;
        color: var(--gray-800);
    }

    .patient-email {
        font-size: 0.75rem;
        color: var(--gray-500);
    }

    .patient-date {
        font-size: 0.75rem;
        background: var(--gray-200);
        padding: 0.25rem 0.75rem;
        border-radius: 1rem;
        color: var(--primary);
    }

    /* Réalisations */
    .achievements-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 1rem;
        justify-content: center;
    }

    .achievement-item {
        text-align: center;
        width: 85px;
    }

    .achievement-icon {
        width: 60px;
        height: 60px;
        background: var(--gray-200);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 0.5rem;
        transition: var(--transition);
    }

    .achievement-item.active .achievement-icon {
        background: linear-gradient(135deg, var(--primary), var(--primary-dark));
        box-shadow: 0 4px 12px rgba(13,110,253,0.3);
    }

    .achievement-item.active .achievement-icon i {
        color: white;
    }

    .achievement-icon i {
        font-size: 1.5rem;
        color: var(--gray-500);
    }

    .achievement-label {
        font-size: 0.7rem;
        font-weight: 500;
        color: var(--gray-600);
    }

    .achievement-item.active .achievement-label {
        color: var(--primary);
        font-weight: 600;
    }

    /* Horaires */
    .schedule-item {
        display: flex;
        justify-content: space-between;
        padding: 0.75rem 0;
        border-bottom: 1px solid var(--gray-200);
    }

    .schedule-item:last-child {
        border-bottom: none;
    }

    /* Skeleton loader */
    .skeleton-container {
        animation: pulse 1.5s ease-in-out infinite;
    }

    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.6; }
    }

    .skeleton-card {
        background: var(--white);
        border-radius: var(--border-radius);
        padding: 1.5rem;
        margin-bottom: 1rem;
    }

    .skeleton-title {
        height: 24px;
        background: var(--gray-300);
        border-radius: 0.5rem;
        margin-bottom: 1rem;
    }

    .skeleton-text {
        height: 16px;
        background: var(--gray-300);
        border-radius: 0.25rem;
        margin-bottom: 0.75rem;
    }

    .skeleton-stat {
        height: 100px;
        background: var(--gray-300);
        border-radius: var(--border-radius);
    }

    /* Grille responsive */
    .two-columns {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 1.5rem;
    }

    @media (max-width: 768px) {
        .two-columns {
            grid-template-columns: 1fr;
        }
        .container {
            padding: 0 1rem;
            margin: 1rem auto;
        }
    }

    /* Badge de spécialité */
    .specialty-badge {
        background: rgba(255,255,255,0.2);
        padding: 0.25rem 0.75rem;
        border-radius: 1rem;
        font-size: 0.8rem;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
    }
</style>

<div class="container" id="dashboardContent">
    <!-- SKELETON LOADER -->
    <div class="skeleton-container" id="skeletonDashboard">
        <div class="skeleton-card">
            <div class="skeleton-title" style="width: 40%;"></div>
            <div class="skeleton-text" style="width: 60%;"></div>
            <div class="skeleton-text" style="width: 80%;"></div>
        </div>
        <div class="stats-grid">
            <div class="skeleton-stat"></div>
            <div class="skeleton-stat"></div>
            <div class="skeleton-stat"></div>
            <div class="skeleton-stat"></div>
        </div>
        <div class="skeleton-card">
            <div class="skeleton-title" style="width: 30%;"></div>
            <div class="skeleton-text" style="width: 100%; height: 100px;"></div>
        </div>
    </div>

    <!-- CONTENU RÉEL -->
    <div class="content-loaded" id="realContent" style="display: none;">
        <c:if test="${not empty messageSucces}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${messageSucces}
            </div>
        </c:if>

        <!-- Bannière de bienvenue professionnelle -->
        <div class="welcome-banner">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                <div class="doctor-info">
                    <h2>
                        <i class="fas fa-stethoscope"></i> Bonjour, Dr. ${sessionScope.utilisateur.nommed}
                    </h2>
                    <div style="display: flex; gap: 1rem; flex-wrap: wrap; margin-top: 0.5rem;">
                        <span class="specialty-badge">
                            <i class="fas fa-graduation-cap"></i> ${sessionScope.utilisateur.specialite}
                        </span>
                        <span class="specialty-badge">
                            <i class="fas fa-map-marker-alt"></i> ${sessionScope.utilisateur.lieu}
                        </span>
                        <span class="specialty-badge">
                            <i class="fas fa-envelope"></i> ${sessionScope.utilisateur.email}
                        </span>
                    </div>
                    <div style="margin-top: 0.75rem;">
                        <span class="specialty-badge">
                            <i class="fas fa-money-bill-wave"></i> Taux horaire : ${tauxHoraire} Ar/h
                        </span>
                    </div>
                </div>
                <div class="doctor-stats">
                    <div class="stat-number">${totalPatients}</div>
                    <div style="font-size: 0.8rem; opacity: 0.9;">
                        <i class="fas fa-users"></i> Patients uniques
                    </div>
                </div>
            </div>
        </div>

        <!-- Statistiques clés -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-calendar-day"></i></div>
                <div class="stat-number">${rdvAujourdhui}</div>
                <div class="stat-label">RDV aujourd'hui</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-calendar-week"></i></div>
                <div class="stat-number">${rdvCetteSemaine}</div>
                <div class="stat-label">RDV cette semaine</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-chart-line"></i></div>
                <div class="stat-number">${revenusMois} Ar</div>
                <div class="stat-label">Revenus du mois</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-user-friends"></i></div>
                <div class="stat-number">${totalPatients}</div>
                <div class="stat-label">Patients uniques</div>
            </div>
        </div>

        <!-- Deuxième ligne de stats -->
        <div class="stats-grid" style="grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));">
            <div class="stat-card">
                <div class="stat-icon" style="background: linear-gradient(135deg, #34a853, #1e7e4a);">
                    <i class="fas fa-check-double"></i>
                </div>
                <div class="stat-number">${nbRdvPasses}</div>
                <div class="stat-label">Consultations effectuées</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background: linear-gradient(135deg, #fbbc04, #e67e22);">
                    <i class="fas fa-hourglass-half"></i>
                </div>
                <div class="stat-number">${nbRdvAVenir}</div>
                <div class="stat-label">RDV à venir</div>
            </div>
        </div>

        <!-- Prochain rendez-vous -->
        <div class="card" style="margin-bottom: 1.5rem;">
            <h3 class="card-title">
                <i class="fas fa-clock"></i> Prochain rendez-vous
                <c:if test="${empty prochainRdv}">
                    <span style="font-size: 0.8rem; font-weight: normal; color: var(--gray-500); margin-left: 0.5rem;">Aucun RDV programmé</span>
                </c:if>
            </h3>

            <c:choose>
                <c:when test="${not empty prochainRdv}">
                    <div class="next-appointment">
                        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                            <div>
                                <div style="font-size: 1.1rem; font-weight: 600; color: var(--primary);">
                                    <i class="far fa-calendar-alt"></i> ${prochainRdv.dateFormatee}
                                </div>
                                <div style="margin-top: 0.5rem;">
                                    <i class="fas fa-user-injury"></i> Patient : <strong>${prochainRdv.patient.nomPat}</strong>
                                </div>
                                <div style="font-size: 0.8rem; color: var(--gray-600); margin-top: 0.25rem;">
                                    <i class="fas fa-envelope"></i> ${prochainRdv.patient.email}
                                </div>
                            </div>
                            <div style="display: flex; gap: 0.5rem;">
                                <a href="${pageContext.request.contextPath}/rdv?action=edit&id=${prochainRdv.idrdv}"
                                   class="btn btn-warning btn-sm">
                                    <i class="fas fa-edit"></i> Modifier
                                </a>
                                <a href="${pageContext.request.contextPath}/rdv?action=annuler&id=${prochainRdv.idrdv}"
                                   class="btn btn-danger btn-sm"
                                   onclick="return confirm('Annuler ce rendez-vous ?')">
                                    <i class="fas fa-times"></i> Annuler
                                </a>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="text-align: center; padding: 2rem;">
                        <i class="fas fa-calendar-times" style="font-size: 3rem; color: var(--gray-400); margin-bottom: 1rem;"></i>
                        <p style="color: var(--gray-600);">Aucun rendez-vous programmé</p>
                        <p style="font-size: 0.8rem; color: var(--gray-500);">Les patients prendront rendez-vous avec vous via la plateforme</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Grille des autres infos -->
        <div class="two-columns">
            <!-- Derniers patients -->
            <div class="card">
                <h3 class="card-title">
                    <i class="fas fa-users"></i> Derniers patients
                </h3>
                <c:choose>
                    <c:when test="${not empty derniersPatients}">
                        <div style="display: flex; flex-direction: column;">
                            <c:forEach items="${derniersPatients}" var="p">
                                <div class="patient-item">
                                    <div>
                                        <div class="patient-name">${p.nomPat}</div>
                                        <div class="patient-email">${p.email}</div>
                                    </div>
                                    <div class="patient-date">
                                        <i class="far fa-clock"></i> ${p.dateDernierRdv}
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="text-align: center; padding: 2rem;">
                            <i class="fas fa-user-slash" style="font-size: 3rem; color: var(--gray-400); margin-bottom: 0.5rem;"></i>
                            <p>Aucun patient pour le moment</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Réalisations -->
            <div class="card">
                <h3 class="card-title">
                    <i class="fas fa-trophy"></i> Mes réalisations
                </h3>
                <div class="achievements-grid">
                    <div class="achievement-item ${totalPatients >= 1 ? 'active' : ''}">
                        <div class="achievement-icon">
                            <i class="fas fa-user-check"></i>
                        </div>
                        <div class="achievement-label">Premier patient</div>
                    </div>
                    <div class="achievement-item ${nbRdvPasses >= 10 ? 'active' : ''}">
                        <div class="achievement-icon">
                            <i class="fas fa-medal"></i>
                        </div>
                        <div class="achievement-label">10 RDV</div>
                    </div>
                    <div class="achievement-item ${nbRdvPasses >= 50 ? 'active' : ''}">
                        <div class="achievement-icon">
                            <i class="fas fa-medal"></i>
                        </div>
                        <div class="achievement-label">50 RDV</div>
                    </div>
                    <div class="achievement-item ${nbRdvPasses >= 100 ? 'active' : ''}">
                        <div class="achievement-icon">
                            <i class="fas fa-crown"></i>
                        </div>
                        <div class="achievement-label">100 RDV</div>
                    </div>
                </div>
            </div>

            <!-- Horaires de travail -->
            <div class="card">
                <h3 class="card-title">
                    <i class="fas fa-business-time"></i> Horaires de travail
                </h3>
                <div>
                    <div class="schedule-item">
                        <span><i class="fas fa-sun"></i> Matin</span>
                        <span><strong>08:00 - 12:00</strong></span>
                    </div>
                    <div class="schedule-item">
                        <span><i class="fas fa-moon"></i> Après-midi</span>
                        <span><strong>14:00 - 17:00</strong></span>
                    </div>
                    <div class="schedule-item">
                        <span><i class="fas fa-calendar-alt"></i> Jours de consultation</span>
                        <span><strong>Lundi - Vendredi</strong></span>
                    </div>
                </div>
                <div style="margin-top: 1rem; text-align: center;">
                    <a href="${pageContext.request.contextPath}/medecin?action=edit&id=${sessionScope.idUtilisateur}" class="btn btn-primary btn-sm">
                        <i class="fas fa-pen"></i> Modifier mes informations
                    </a>
                </div>
            </div>

            <!-- Conseil du jour -->
            <div class="card" style="background: linear-gradient(135deg, #e8f0fe, #ffffff);">
                <h3 class="card-title">
                    <i class="fas fa-lightbulb"></i> Conseil du jour
                </h3>
                <div style="text-align: center; padding: 0.5rem;">
                    <i class="fas fa-heartbeat" style="font-size: 3rem; color: var(--primary); margin-bottom: 0.5rem;"></i>
                    <div style="font-weight: 600; margin-bottom: 0.25rem;">Prenez soin de vous</div>
                    <div style="font-size: 0.8rem; color: var(--gray-600);">Un médecin en bonne santé soigne mieux ses patients</div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const skeleton = document.getElementById('skeletonDashboard');
        const realContent = document.getElementById('realContent');

        skeleton.style.display = 'block';
        realContent.style.display = 'none';

        setTimeout(function() {
            skeleton.style.display = 'none';
            realContent.style.display = 'block';
        }, 100);
    });
</script>

</body>
</html>