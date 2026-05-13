<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <h2 class="card-title">🏆 Top 5 — Médecins les plus consultés</h2>
        <p style="color:#666; font-size:13px; margin-bottom:20px;">
            Découvrez les médecins les plus sollicités par les patients
        </p>

        <c:choose>
            <c:when test="${empty top5}">
                <p style="text-align:center; color:#888; padding:40px;">
                    Aucune donnée disponible pour le moment.
                </p>
            </c:when>
            <c:otherwise>
                <c:forEach var="m" items="${top5}" varStatus="status">
                    <div style="display:flex; align-items:center; gap:16px; padding:16px;
                                border-radius:10px; margin-bottom:12px;
                                background:${status.index == 0 ? '#fef7e0' : status.index == 1 ? '#f0f4f8' : 'white'};
                                border:1px solid ${status.index == 0 ? '#fbbc04' : '#e8f0fe'};
                                transition: transform 0.2s;">

                        <%-- Rang avec médaille --%>
                        <div style="width:50px; height:50px; border-radius:50%;
                                    background:${status.index == 0 ? 'linear-gradient(135deg, #fbbc04, #e6a800)' :
                                               status.index == 1 ? 'linear-gradient(135deg, #b0b0b0, #8a8a8a)' :
                                               'linear-gradient(135deg, #cd7f32, #b8702a)'};
                                    display:flex; align-items:center; justify-content:center;
                                    color:white; font-weight:700; font-size:22px; flex-shrink:0;">
                            ${status.index + 1}
                        </div>

                        <%-- Infos médecin --%>
                        <div style="flex:1;">
                            <h3 style="font-size:18px; color:#1a73e8; margin-bottom:4px;">
                                Dr. ${m.nommed}
                            </h3>
                            <div style="display:flex; flex-wrap:wrap; gap:8px; align-items:center;">
                                <span class="badge badge-success">${m.specialite}</span>
                                <span style="color:#888; font-size:13px;">📍 ${m.lieu}</span>
                            </div>
                            <div style="margin-top:8px;">
                                <span style="color:#555; font-size:13px;">💰 Taux horaire: </span>
                                <strong style="color:#1a73e8;">${m.tauxHoraire} Ar/h</strong>
                            </div>
                        </div>

                        <%-- Bouton prendre RDV --%>
                        <a href="${pageContext.request.contextPath}/rdv?action=form&idmed=${m.idmed}"
                           class="btn btn-primary" style="font-size:14px; white-space:nowrap; padding:10px 20px;">
                            📅 Prendre RDV
                        </a>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>

        <!-- Lien pour voir tous les médecins -->
        <div style="margin-top:25px; text-align:center;">
            <a href="${pageContext.request.contextPath}/search" class="btn btn-secondary">
                🔍 Voir tous les médecins
            </a>
        </div>
    </div>
</div>
</body>
</html>