<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container" id="dashboardContent">
    <!-- SKELETON LOADER -->
    <div class="skeleton-container" id="skeletonDashboard">
        <div class="skeleton-card">
            <div class="skeleton-title" style="width: 40%; margin-bottom: 15px;"></div>
            <div class="skeleton-text" style="width: 60%;"></div>
            <div class="skeleton-text" style="width: 80%;"></div>
        </div>
        <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(160px,1fr)); gap:16px; margin-bottom:25px;">
            <div class="skeleton-stat"></div>
            <div class="skeleton-stat"></div>
            <div class="skeleton-stat"></div>
            <div class="skeleton-stat"></div>
        </div>
        <div class="skeleton-card">
            <div class="skeleton-title" style="width: 30%; margin-bottom: 15px;"></div>
            <div class="skeleton-text" style="width: 100%; height: 80px;"></div>
        </div>
    </div>

    <!-- CONTENU RÉEL -->
    <div class="content-loaded" id="realContent" style="display: none;">
        <c:if test="${not empty messageSucces}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${messageSucces}
            </div>
        </c:if>

        <!-- Bannière de bienvenue -->
        <div class="welcome-banner">
            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap;">
                <div>
                    <h2 style="font-size:26px; margin-bottom:8px;">
                        <i class="fas fa-user-circle"></i> Bonjour, ${sessionScope.utilisateur.nomPat} !
                    </h2>
                    <p style="opacity:0.9; font-size:14px;">Bienvenue sur votre espace santé</p>
                    <p style="opacity:0.7; font-size:12px; margin-top:8px;"><i class="fas fa-envelope"></i> ${sessionScope.utilisateur.email}</p>
                </div>
                <div class="welcome-stats">
                    <div class="welcome-stat-number">${nbRdvTotal}</div>
                    <div class="welcome-stat-label">Rendez-vous total</div>
                </div>
            </div>
        </div>

        <!-- Statistiques clés -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-calendar-alt"></i></div>
                <div class="stat-number">${rdvAVenir}</div>
                <div class="stat-label">Rendez-vous à venir</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background: linear-gradient(135deg, #34a853, #1e7e4a);"><i class="fas fa-check-circle"></i></div>
                <div class="stat-number" style="color:#34a853;">${rdvPasses}</div>
                <div class="stat-label">Consultations effectuées</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon"><i class="fas fa-user-md"></i></div>
                <div class="stat-number">${nbMedecinsConsultes}</div>
                <div class="stat-label">Médecins consultés</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background: linear-gradient(135deg, #fbbc04, #e67e22);"><i class="fas fa-star"></i></div>
                <div class="stat-number">${tauxAssiduite}%</div>
                <div class="stat-label">Taux d'assiduité</div>
            </div>
        </div>

        <!-- Prochain rendez-vous -->
        <div class="card" style="margin-bottom:25px; border-left:4px solid #1a73e8;">
            <h3 class="card-title" style="display:flex; align-items:center; gap:8px;">
                <i class="fas fa-clock"></i> Prochain rendez-vous
                <c:if test="${empty prochainRdv}">
                    <span style="font-size:12px; font-weight:normal; color:var(--text-muted); margin-left:10px;">Aucun RDV programmé</span>
                </c:if>
            </h3>

            <c:choose>
                <c:when test="${not empty prochainRdv}">
                    <div class="next-appointment">
                        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:15px;">
                            <div>
                                <div class="rdv-doctor-name">
                                    <i class="fas fa-user-md"></i> Dr. ${prochainRdv.medecin.nommed}
                                </div>
                                <div style="margin-top:8px;">
                                    <span class="badge badge-success"><i class="fas fa-stethoscope"></i> ${prochainRdv.medecin.specialite}</span>
                                    <span class="rdv-location"><i class="fas fa-map-marker-alt"></i> ${prochainRdv.medecin.lieu}</span>
                                </div>
                                <div style="margin-top:12px;">
                                    <div class="rdv-date">
                                        <i class="far fa-calendar-alt"></i> ${prochainRdv.dateFormatee}
                                    </div>
                                    <div class="rdv-price">
                                        <i class="fas fa-money-bill-wave"></i> Taux horaire: ${prochainRdv.medecin.tauxHoraire} Ar/h
                                    </div>
                                </div>
                            </div>
                            <div style="display:flex; gap:10px;">
                                <a href="${pageContext.request.contextPath}/rdv?action=edit&id=${prochainRdv.idrdv}"
                                   class="btn btn-warning" style="padding:8px 16px;">
                                    <i class="fas fa-edit"></i> Modifier
                                </a>
                                <a href="${pageContext.request.contextPath}/rdv?action=annuler&id=${prochainRdv.idrdv}"
                                   class="btn btn-danger" style="padding:8px 16px;"
                                   onclick="return confirm('Annuler ce rendez-vous ?')">
                                    <i class="fas fa-times"></i> Annuler
                                </a>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fas fa-calendar-times"></i>
                        <p>Vous n'avez aucun rendez-vous programmé</p>
                        <a href="${pageContext.request.contextPath}/search" class="btn btn-primary">
                            <i class="fas fa-search"></i> Trouver un médecin
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Deux colonnes -->
        <div class="two-columns">
            <div class="card">
                <h3 class="card-title"><i class="fas fa-history"></i> Dernières consultations</h3>
                <c:choose>
                    <c:when test="${not empty derniersRdvs}">
                        <div class="consultations-list">
                            <c:forEach items="${derniersRdvs}" var="r">
                                <div class="consultation-item">
                                    <div>
                                        <div class="consultation-doctor">
                                            <i class="fas fa-user-md"></i> Dr. ${r.medecin.nommed}
                                        </div>
                                        <div class="consultation-specialty">
                                            <i class="fas fa-stethoscope"></i> ${r.medecin.specialite}
                                        </div>
                                    </div>
                                    <div class="consultation-right">
                                        <div class="consultation-date">
                                            <i class="far fa-calendar-alt"></i> ${r.dateFormatee}
                                        </div>
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
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                        <div class="view-all-link">
                            <a href="${pageContext.request.contextPath}/rdv?action=liste" class="btn btn-secondary">
                                <i class="fas fa-list"></i> Voir tous mes RDV →
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state-small">
                            <i class="fas fa-folder-open"></i>
                            <p>Aucune consultation passée</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div style="display:flex; flex-direction:column; gap:20px;">
                <div class="card">
                    <h3 class="card-title"><i class="fas fa-bolt"></i> Actions rapides</h3>
                    <div class="actions-grid">
                        <a href="${pageContext.request.contextPath}/search" class="btn btn-primary">
                            <i class="fas fa-search"></i> Nouveau RDV
                        </a>
                        <a href="${pageContext.request.contextPath}/rdv?action=liste" class="btn btn-success">
                            <i class="fas fa-calendar-alt"></i> Mes RDV
                        </a>
                        <a href="${pageContext.request.contextPath}/patient?action=edit&id=${sessionScope.utilisateur.idpat}" class="btn btn-warning">
                            <i class="fas fa-user-edit"></i> Mon profil
                        </a>
                        <a href="${pageContext.request.contextPath}/patient?action=top5" class="btn btn-danger">
                            <i class="fas fa-chart-line"></i> Top médecins
                        </a>
                    </div>
                </div>
                <div class="card health-tip">
                    <h3 class="card-title"><i class="fas fa-heartbeat"></i> Conseil santé</h3>
                    <div class="health-tip-content">
                        <i class="fas fa-heart"></i>
                        <div class="health-tip-text">
                            <strong>Prenez soin de vous</strong>
                            <p>Une visite médicale régulière est la clé d'une bonne santé</p>
                        </div>
                    </div>
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

<style>
    /* Bannière de bienvenue */
    .welcome-banner {
        background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
        border-radius: 16px;
        padding: 30px;
        margin-bottom: 25px;
        color: white;
    }

    .welcome-stats {
        text-align: center;
        background: rgba(255,255,255,0.15);
        padding: 12px 24px;
        border-radius: 12px;
    }

    .welcome-stat-number {
        font-size: 32px;
        font-weight: bold;
    }

    .welcome-stat-label {
        font-size: 12px;
        opacity: 0.85;
    }

    /* Grille des statistiques */
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
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

    /* Prochain rendez-vous */
    .next-appointment {
        background: var(--hover-bg);
        border-radius: 12px;
        padding: 20px;
    }

    .rdv-doctor-name {
        font-size: 18px;
        font-weight: bold;
        color: #1a73e8;
    }

    .rdv-location {
        color: var(--text-secondary);
        font-size: 13px;
        margin-left: 10px;
    }

    .rdv-date, .rdv-price {
        font-size: 14px;
        margin-top: 5px;
    }

    .empty-state {
        text-align: center;
        padding: 40px;
    }

    .empty-state i {
        font-size: 48px;
        color: var(--text-muted);
        margin-bottom: 15px;
    }

    .empty-state p {
        color: var(--text-secondary);
        margin-bottom: 15px;
    }

    .empty-state-small {
        text-align: center;
        padding: 30px;
    }

    .empty-state-small i {
        font-size: 40px;
        color: var(--text-muted);
        margin-bottom: 10px;
    }

    /* Liste des consultations */
    .consultations-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .consultation-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px solid var(--border-light);
    }

    .consultation-doctor {
        font-weight: 600;
    }

    .consultation-specialty {
        font-size: 12px;
        color: var(--text-muted);
    }

    .consultation-right {
        text-align: right;
    }

    .consultation-date {
        font-size: 13px;
        color: var(--text-secondary);
        margin-bottom: 5px;
    }

    .badge-status {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 2px 8px;
        border-radius: 20px;
        font-size: 10px;
    }

    .badge-status.confirmed {
        background: #e6f4ea;
        color: #137333;
    }

    .badge-status.cancelled {
        background: #fce8e6;
        color: #c5221f;
    }

    .view-all-link {
        margin-top: 15px;
        text-align: center;
    }

    /* Actions rapides */
    .actions-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
    }

    .actions-grid .btn {
        text-align: center;
        justify-content: center;
    }

    /* Conseil santé */
    .health-tip {
        background: linear-gradient(135deg, var(--hover-bg), var(--bg-card));
    }

    .health-tip-content {
        display: flex;
        align-items: center;
        gap: 15px;
        padding: 10px;
    }

    .health-tip-content i {
        font-size: 40px;
        color: #ea4335;
    }

    .health-tip-text strong {
        display: block;
        margin-bottom: 5px;
    }

    .health-tip-text p {
        font-size: 12px;
        color: var(--text-secondary);
        margin: 0;
    }

    /* Deux colonnes */
    .two-columns {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 20px;
    }

    @media (max-width: 768px) {
        .two-columns {
            grid-template-columns: 1fr;
        }
        .stats-grid {
            grid-template-columns: repeat(2, 1fr);
        }
        .actions-grid {
            grid-template-columns: 1fr;
        }
        .welcome-banner {
            padding: 20px;
        }
        .welcome-stat-number {
            font-size: 24px;
        }
    }

    .badge-success {
        background: #e6f4ea;
        color: #137333;
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 12px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
</style>

</body>
</html>