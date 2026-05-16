<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<style>
    .profile-header {
        background: linear-gradient(135deg, #1a56db 0%, #0d3b8a 100%);
        border-radius: 1rem;
        padding: 2rem;
        margin-bottom: 2rem;
        color: white;
        position: relative;
        overflow: hidden;
    }
    .profile-header::before {
        content: '';
        position: absolute;
        top: -50%;
        right: -10%;
        width: 300px;
        height: 300px;
        background: rgba(255,255,255,0.05);
        border-radius: 50%;
    }
    .profile-avatar {
        width: 120px;
        height: 120px;
        background: rgba(255,255,255,0.2);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 1rem;
        overflow: hidden;
        border: 3px solid rgba(255,255,255,0.5);
    }
    .profile-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    .profile-avatar i {
        font-size: 3rem;
    }
    .profile-section {
        background: white;
        border-radius: 1rem;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
        box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,0.075);
    }
    .profile-section h3 {
        color: #1a73e8;
        font-size: 1.25rem;
        margin-bottom: 1rem;
        padding-bottom: 0.5rem;
        border-bottom: 2px solid #e9ecef;
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }
    .profile-section i {
        color: #1a73e8;
    }
    .badge-specialty {
        background: rgba(255,255,255,0.2);
        padding: 0.25rem 1rem;
        border-radius: 2rem;
        font-size: 0.875rem;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
    }
    .info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 1rem;
        margin-bottom: 1.5rem;
    }
    .info-card {
        background: #f8f9fa;
        border-radius: 0.75rem;
        padding: 1rem;
        text-align: center;
    }
    .info-card i {
        font-size: 1.5rem;
        color: #1a73e8;
        margin-bottom: 0.5rem;
    }
    .info-card .label {
        font-size: 0.75rem;
        color: #6c757d;
        text-transform: uppercase;
    }
    .info-card .value {
        font-size: 1.1rem;
        font-weight: 600;
        color: #212529;
    }
    .btn-rdv {
        background: #1a73e8;
        color: white;
        padding: 0.75rem 1.5rem;
        border-radius: 0.5rem;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        transition: all 0.2s ease;
    }
    .btn-rdv:hover {
        background: #0d47a1;
        transform: translateY(-2px);
        color: white;
    }
    .profile-content {
        max-width: 800px;
        margin: 0 auto;
    }
    .text-content {
        line-height: 1.6;
        color: #495057;
    }
    .whitespace-pre {
        white-space: pre-wrap;
    }
</style>

<div class="container">
    <c:choose>
        <c:when test="${empty medecin}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> Médecin non trouvé.
            </div>
            <a href="${pageContext.request.contextPath}/search" class="btn btn-primary">
                <i class="fas fa-arrow-left"></i> Retour à la recherche
            </a>
        </c:when>
        <c:otherwise>
            <!-- En-tête du profil -->
            <div class="profile-header">
                <div class="profile-content" style="max-width:800px; margin:0 auto; text-align: center;">
                    <!-- Photo de profil -->
                    <div class="profile-avatar" style="margin: 0 auto 1rem auto;">
                        <c:choose>
                            <c:when test="${not empty medecin.photoProfile}">
                                <img src="${medecin.photoProfile}" alt="Photo du Dr. ${medecin.nommed}">
                            </c:when>
                            <c:otherwise>
                                <i class="fas fa-user-md"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <h1 style="font-size: 2rem; margin-bottom: 0.5rem;">
                        Dr. ${medecin.nommed}
                    </h1>
                    <div style="display: flex; gap: 0.75rem; flex-wrap: wrap; justify-content: center; margin-bottom: 1rem;">
                        <span class="badge-specialty">
                            <i class="fas fa-stethoscope"></i> ${medecin.specialite}
                        </span>
                        <span class="badge-specialty">
                            <i class="fas fa-map-marker-alt"></i> ${medecin.lieu}
                        </span>
                        <span class="badge-specialty">
                            <i class="fas fa-envelope"></i> ${medecin.email}
                        </span>
                    </div>
                    <div style="display: flex; gap: 1rem; margin-top: 1rem; flex-wrap: wrap; justify-content: center;">
                        <a href="${pageContext.request.contextPath}/rdv?action=form&idmed=${medecin.idmed}" class="btn-rdv">
                            <i class="fas fa-calendar-plus"></i> Prendre rendez-vous
                        </a>
                        <a href="${pageContext.request.contextPath}/rdv?action=horaires&idmed=${medecin.idmed}" class="btn-rdv" style="background: #34a853;">
                            <i class="fas fa-clock"></i> Voir les horaires
                        </a>
                    </div>
                </div>
            </div>

            <div class="profile-content">
                <!-- Informations pratiques -->
                <div class="info-grid">
                    <div class="info-card">
                        <i class="fas fa-money-bill-wave"></i>
                        <div class="label">Taux horaire</div>
                        <div class="value">${medecin.tauxHoraire} Ar/h</div>
                    </div>
                    <div class="info-card">
                        <i class="fas fa-phone-alt"></i>
                        <div class="label">Téléphone</div>
                        <div class="value">${not empty medecin.telephone ? medecin.telephone : 'Non renseigné'}</div>
                    </div>
                    <div class="info-card">
                        <i class="fas fa-building"></i>
                        <div class="label">Cabinet</div>
                        <div class="value">${medecin.lieu}</div>
                    </div>
                </div>

                <!-- Biographie -->
                <div class="profile-section">
                    <h3><i class="fas fa-user-circle"></i> À propos</h3>
                    <div class="text-content whitespace-pre">
                        <c:choose>
                            <c:when test="${not empty medecin.bio}">
                                ${fn:escapeXml(medecin.bio)}
                            </c:when>
                            <c:otherwise>
                                <p style="color: #6c757d; font-style: italic;">Aucune biographie renseignée pour le moment.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Diplômes -->
                <div class="profile-section">
                    <h3><i class="fas fa-graduation-cap"></i> Diplômes et formations</h3>
                    <div class="text-content whitespace-pre">
                        <c:choose>
                            <c:when test="${not empty medecin.diplomes}">
                                ${fn:escapeXml(medecin.diplomes)}
                            </c:when>
                            <c:otherwise>
                                <p style="color: #6c757d; font-style: italic;">Aucun diplôme renseigné.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Expérience -->
                <div class="profile-section">
                    <h3><i class="fas fa-briefcase"></i> Expérience professionnelle</h3>
                    <div class="text-content whitespace-pre">
                        <c:choose>
                            <c:when test="${not empty medecin.experience}">
                                ${fn:escapeXml(medecin.experience)}
                            </c:when>
                            <c:otherwise>
                                <p style="color: #6c757d; font-style: italic;">Aucune expérience renseignée.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Bouton retour -->
                <div style="text-align: center; margin-top: 1rem;">
                    <a href="${pageContext.request.contextPath}/search" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Retour à la recherche
                    </a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

</body>
</html>