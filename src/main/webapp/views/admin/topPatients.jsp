<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <h2 class="card-title">
            <i class="fas fa-trophy"></i> Top 5 — Patients les plus actifs
        </h2>
        <p style="color:var(--text-secondary); font-size:13px; margin-bottom:20px;">
            🌟 Classement des patients qui consultent le plus
        </p>

        <c:choose>
            <c:when test="${empty topPatients}">
                <div style="text-align:center; padding:50px;">
                    <div style="font-size:48px; margin-bottom:15px;">🏆</div>
                    <p style="color:var(--text-secondary);">Aucune donnée disponible pour le moment.</p>
                    <p style="font-size:13px; color:var(--text-muted); margin-top:10px;">Les rendez-vous confirmés apparaîtront ici</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="p" items="${topPatients}" varStatus="status">
                    <div class="top5-card" style="display:flex; align-items:center; gap:16px; padding:16px;
                                border-radius:12px; margin-bottom:12px;
                                background:${status.index == 0 ? '#fef7e0' : status.index == 1 ? 'var(--hover-bg)' : 'var(--bg-card)'};
                                border:1px solid ${status.index == 0 ? '#fbbc04' : 'var(--border-color)'};
                                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);">

                        <div class="medal" style="width:55px; height:55px; border-radius:50%;
                                    background:${status.index == 0 ? 'linear-gradient(135deg, #fbbc04, #e6a800)' :
                                               status.index == 1 ? 'linear-gradient(135deg, #b0b0b0, #8a8a8a)' :
                                               'linear-gradient(135deg, #cd7f32, #b8702a)'};
                                    display:flex; align-items:center; justify-content:center;
                                    color:white; font-weight:700; font-size:24px; flex-shrink:0;">
                            ${status.index + 1}
                        </div>

                        <div style="flex:1;">
                            <h3 style="font-size:18px; color:#1a73e8; margin-bottom:4px;">
                                ${p[1]}
                            </h3>
                            <div style="display:flex; flex-wrap:wrap; gap:8px; align-items:center;">
                                <span style="color:var(--text-secondary); font-size:13px;">📧 ${p[2]}</span>
                            </div>
                            <div style="margin-top:8px;">
                                <span style="color:var(--text-secondary); font-size:13px;">📅 Nombre de RDV: </span>
                                <strong style="color:#1a73e8;">${p[3]} consultation(s)</strong>
                            </div>
                        </div>

                        <a href="${pageContext.request.contextPath}/admin?action=editPatient&id=${p[0]}"
                           class="btn btn-primary" style="font-size:14px; white-space:nowrap; padding:10px 20px;">
                            👤 Voir profil
                        </a>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>

        <!-- Lien pour voir tous les patients (redirige vers liste admin) -->
        <div style="margin-top:25px; text-align:center;">
            <a href="${pageContext.request.contextPath}/admin?action=listePatients" class="btn btn-primary">
                🔍 Voir tous les patients
            </a>
        </div>
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
    @keyframes slideIn {
        from { opacity: 0; transform: translateX(-20px); }
        to { opacity: 1; transform: translateX(0); }
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