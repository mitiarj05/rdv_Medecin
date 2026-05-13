<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <h2 class="card-title">🏆 Top 5 — Médecins les plus consultés</h2>

        <c:choose>
            <c:when test="${sessionScope.role == 'medecin'}">
                <p style="color:var(--text-secondary); font-size:13px; margin-bottom:20px; padding:10px; background:var(--hover-bg); border-radius:8px;">
                    📊 Classement des médecins les plus sollicités par les patients
                </p>
            </c:when>
            <c:otherwise>
                <p style="color:var(--text-secondary); font-size:13px; margin-bottom:20px;">
                    🌟 Découvrez les médecins les plus sollicités par les patients
                </p>
            </c:otherwise>
        </c:choose>

        <c:choose>
            <c:when test="${empty top5}">
                <div style="text-align:center; padding:50px;">
                    <div style="font-size:48px; margin-bottom:15px;">🏆</div>
                    <p style="color:var(--text-secondary);">Aucune donnée disponible pour le moment.</p>
                    <p style="font-size:13px; color:var(--text-muted); margin-top:10px;">Les rendez-vous confirmés apparaîtront ici</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="m" items="${top5}" varStatus="status">
                    <div class="top5-card" style="display:flex; align-items:center; gap:16px; padding:16px;
                                border-radius:12px; margin-bottom:12px;
                                background:${status.index == 0 ? '#fef7e0' : status.index == 1 ? 'var(--hover-bg)' : 'var(--bg-card)'};
                                border:1px solid ${status.index == 0 ? '#fbbc04' : 'var(--border-color)'};
                                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                                cursor: pointer;">

                        <!-- Rang avec médaille animée -->
                        <div class="medal" style="width:55px; height:55px; border-radius:50%;
                                    background:${status.index == 0 ? 'linear-gradient(135deg, #fbbc04, #e6a800)' :
                                               status.index == 1 ? 'linear-gradient(135deg, #b0b0b0, #8a8a8a)' :
                                               'linear-gradient(135deg, #cd7f32, #b8702a)'};
                                    display:flex; align-items:center; justify-content:center;
                                    color:white; font-weight:700; font-size:24px; flex-shrink:0;
                                    transition: transform 0.3s ease;">
                            ${status.index + 1}
                        </div>

                        <!-- Infos médecin -->
                        <div style="flex:1;">
                            <h3 style="font-size:18px; color:#1a73e8; margin-bottom:4px;">
                                Dr. ${m.nommed}
                            </h3>
                            <div style="display:flex; flex-wrap:wrap; gap:8px; align-items:center;">
                                <span class="badge badge-success">${m.specialite}</span>
                                <span style="color:var(--text-secondary); font-size:13px;">📍 ${m.lieu}</span>
                            </div>
                            <div style="margin-top:8px;">
                                <span style="color:var(--text-secondary); font-size:13px;">💰 Taux horaire: </span>
                                <strong style="color:#1a73e8;">${m.tauxHoraire} Ar/h</strong>
                            </div>
                        </div>

                        <!-- Badge de consultation (pour médecin) -->
                        <c:choose>
                            <c:when test="${sessionScope.role == 'patient'}">
                                <a href="${pageContext.request.contextPath}/rdv?action=form&idmed=${m.idmed}"
                                   class="btn btn-primary" style="font-size:14px; white-space:nowrap; padding:10px 20px;">
                                    📅 Prendre RDV
                                </a>
                            </c:when>
                            <c:otherwise>
                                <div class="consult-badge" style="font-size:13px; color:#34a853; background:#e6f4ea; padding:8px 16px; border-radius:20px; display:flex; align-items:center; gap:8px; transition:all 0.2s ease;">
                                    <span>⭐</span>
                                    <span>Médecin référent</span>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:forEach>

                <!-- Message de motivation -->
                <c:if test="${sessionScope.role == 'medecin'}">
                    <div style="margin-top:25px; padding:15px; background:var(--hover-bg); border-radius:10px; text-align:center;">
                        <span style="font-size:14px;">💪 Continuez votre excellent travail !</span>
                    </div>
                </c:if>
            </c:otherwise>
        </c:choose>

        <!-- Lien pour voir tous les médecins (seulement pour les patients) -->
        <c:if test="${sessionScope.role == 'patient'}">
            <div style="margin-top:25px; text-align:center;">
                <a href="${pageContext.request.contextPath}/search" class="btn btn-secondary">
                    🔍 Voir tous les médecins
                </a>
            </div>
        </c:if>
    </div>
</div>

<style>
    .top5-card:hover {
        transform: translateX(8px);
        box-shadow: 0 8px 25px var(--shadow-hover);
    }

    .top5-card:hover .medal {
        transform: scale(1.1) rotate(5deg);
    }

    .consult-badge:hover {
        transform: scale(1.05);
        background: #34a853 !important;
        color: white !important;
    }

    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateX(-20px);
        }
        to {
            opacity: 1;
            transform: translateX(0);
        }
    }

    .top5-card {
        animation: slideIn 0.4s ease-out forwards;
    }

    .top5-card:nth-child(1) { animation-delay: 0.1s; }
    .top5-card:nth-child(2) { animation-delay: 0.2s; }
    .top5-card:nth-child(3) { animation-delay: 0.3s; }
    .top5-card:nth-child(4) { animation-delay: 0.4s; }
    .top5-card:nth-child(5) { animation-delay: 0.5s; }
</style>

</body>
</html>