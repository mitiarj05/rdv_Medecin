<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <!-- En-tête du calendrier -->
    <div class="card" style="margin-bottom:20px;">
        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:15px;">
            <h2 class="card-title" style="margin-bottom:0; border:none;">
                <i class="fas fa-calendar-alt"></i>
                <c:choose>
                    <c:when test="${sessionScope.role == 'admin'}">
                        Calendrier général - Tous les rendez-vous
                    </c:when>
                    <c:otherwise>
                        Calendrier des rendez-vous
                    </c:otherwise>
                </c:choose>
            </h2>
            <div style="display:flex; gap:10px;">
                <a href="${pageContext.request.contextPath}/calendar?year=${year}&month=${month-1}" class="btn btn-secondary">
                    <i class="fas fa-chevron-left"></i> Mois précédent
                </a>
                <a href="${pageContext.request.contextPath}/calendar?year=<%= java.time.LocalDate.now().getYear() %>&month=<%= java.time.LocalDate.now().getMonthValue() %>" class="btn btn-primary">
                    <i class="fas fa-calendar-day"></i> Aujourd'hui
                </a>
                <a href="${pageContext.request.contextPath}/calendar?year=${year}&month=${month+1}" class="btn btn-secondary">
                    Mois suivant <i class="fas fa-chevron-right"></i>
                </a>
            </div>
        </div>
    </div>

    <!-- Statistiques du mois - Style identique au dashboard -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-calendar-alt"></i></div>
            <div class="stat-number">${stats.totalRdvs}</div>
            <div class="stat-label">Total rendez-vous</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: linear-gradient(135deg, #34a853, #1e7e4a);"><i class="fas fa-check-circle"></i></div>
            <div class="stat-number" style="color:#34a853;">${stats.totalConfirmes}</div>
            <div class="stat-label">Confirmés</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: linear-gradient(135deg, #ea4335, #c5221f);"><i class="fas fa-times-circle"></i></div>
            <div class="stat-number" style="color:#ea4335;">${stats.totalAnnules}</div>
            <div class="stat-label">Annulés</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon"><i class="fas fa-chart-line"></i></div>
            <div class="stat-number">${stats.tauxOccupation}%</div>
            <div class="stat-label">Taux d'occupation</div>
        </div>
    </div>

    <!-- Calendrier -->
    <div class="card">
        <h3 class="card-title" style="text-align:center;">
            <i class="fas fa-calendar-alt"></i> ${monthName} ${year}
        </h3>

        <!-- Jours de la semaine -->
        <div class="weekdays">
            <div><i class="fas fa-sun"></i> Lundi</div>
            <div><i class="fas fa-calendar-alt"></i> Mardi</div>
            <div><i class="fas fa-calendar-alt"></i> Mercredi</div>
            <div><i class="fas fa-calendar-alt"></i> Jeudi</div>
            <div><i class="fas fa-calendar-alt"></i> Vendredi</div>
            <div><i class="fas fa-calendar-week"></i> Samedi</div>
            <div><i class="fas fa-moon"></i> Dimanche</div>
        </div>

        <!-- Grille des jours -->
        <div class="calendar-grid">
            <c:forEach begin="0" end="${startOffset-1}" var="i">
                <div class="calendar-empty"></div>
            </c:forEach>

            <c:forEach begin="1" end="${daysInMonth}" var="day">
                <c:set var="today" value="<%= java.time.LocalDate.now() %>" />
                <c:set var="isToday" value="${year == today.year && month == today.monthValue && day == today.dayOfMonth}" />

                <div class="calendar-day ${isToday ? 'today' : ''}"
                     data-day="${day}"
                     onclick="openDayModal(${year}, ${month}, ${day})">

                    <div class="day-number ${isToday ? 'today-number' : ''}">${day}</div>

                    <div class="rdv-list">
                        <c:set var="dayRdvs" value="${rdvsByDay[day]}" />
                        <c:if test="${not empty dayRdvs}">
                            <c:forEach items="${dayRdvs}" var="rdv">
                                <c:choose>
                                    <c:when test="${rdv.statut == 'CONFIRME'}">
                                        <div class="rdv-badge confirmed">
                                            <i class="fas fa-clock"></i> ${rdv.heure}
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="rdv-badge cancelled">
                                            <i class="fas fa-clock"></i> ${rdv.heure}
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </c:if>
                    </div>
                </div>
            </c:forEach>
        </div>

        <!-- Légende -->
        <div class="legend">
            <div><span class="legend-badge confirmed-badge"></span> Rendez-vous confirmé</div>
            <div><span class="legend-badge cancelled-badge"></span> Rendez-vous annulé</div>
            <div><span class="legend-badge today-badge"></span> Aujourd'hui</div>
        </div>
    </div>
</div>

<!-- Modal pour afficher les détails du jour -->
<div id="dayModal" class="modal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:2000; align-items:center; justify-content:center;">
    <div class="modal-content" style="background:var(--bg-card); border-radius:16px; max-width:600px; width:90%; max-height:80%; overflow-y:auto; animation: fadeInUp 0.3s ease;">
        <div style="padding:20px;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                <h3 id="modalTitle" style="color:#1a73e8;"><i class="fas fa-calendar-day"></i> </h3>
                <button onclick="closeModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:var(--text-secondary);"><i class="fas fa-times"></i></button>
            </div>
            <div id="modalBody" style="max-height:400px; overflow-y:auto;">
                <!-- Contenu dynamique -->
            </div>
            <div style="margin-top:20px; text-align:center;">
                <button onclick="closeModal()" class="btn btn-secondary"><i class="fas fa-door-closed"></i> Fermer</button>
            </div>
        </div>
    </div>
</div>

<style>
    /* Statistiques - identique au dashboard médecin */
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

    /* Calendrier */
    .weekdays {
        display: grid;
        grid-template-columns: repeat(7, 1fr);
        gap: 8px;
        margin-bottom: 12px;
        text-align: center;
    }

    .weekdays div {
        padding: 12px;
        font-weight: 600;
        background: var(--hover-bg);
        border-radius: 12px;
        color: #1a73e8;
        font-size: 14px;
    }

    .weekdays div i {
        margin-right: 6px;
        font-size: 12px;
    }

    .calendar-grid {
        display: grid;
        grid-template-columns: repeat(7, 1fr);
        gap: 8px;
    }

    .calendar-day {
        background: var(--bg-card);
        border-radius: 12px;
        padding: 10px;
        min-height: 100px;
        border: 1px solid var(--border-color);
        transition: all 0.2s ease;
        cursor: pointer;
    }

    .calendar-day:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px var(--shadow-hover);
        border-color: #1a73e8;
    }

    .calendar-day.today {
        border: 2px solid #1a73e8;
        background: linear-gradient(135deg, #e8f0fe, #d4e4fc);
    }

    body.dark-mode .calendar-day.today {
        background: linear-gradient(135deg, #1a2744, #0f1a2e);
    }

    .day-number {
        font-weight: bold;
        font-size: 16px;
        margin-bottom: 8px;
        color: var(--text-primary);
    }

    .day-number.today-number {
        color: #1a73e8;
    }

    .calendar-empty {
        background: var(--border-light);
        border-radius: 12px;
        min-height: 100px;
    }

    .rdv-list {
        max-height: 65px;
        overflow-y: auto;
    }

    .rdv-badge {
        font-size: 10px;
        padding: 3px 6px;
        border-radius: 6px;
        margin-bottom: 3px;
        display: flex;
        align-items: center;
        gap: 4px;
    }

    .rdv-badge.confirmed {
        background: #e6f4ea;
        color: #137333;
    }

    .rdv-badge.cancelled {
        background: #fce8e6;
        color: #c5221f;
    }

    .legend {
        margin-top: 20px;
        padding-top: 15px;
        border-top: 1px solid var(--border-color);
        display: flex;
        gap: 25px;
        flex-wrap: wrap;
        justify-content: center;
    }

    .legend div {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 12px;
    }

    .legend-badge {
        width: 16px;
        height: 16px;
        border-radius: 4px;
    }

    .confirmed-badge {
        background: #e6f4ea;
        border: 1px solid #137333;
    }

    .cancelled-badge {
        background: #fce8e6;
        border: 1px solid #c5221f;
    }

    .today-badge {
        background: var(--bg-card);
        border: 2px solid #1a73e8;
    }

    .rdv-list::-webkit-scrollbar {
        width: 4px;
    }

    .rdv-list::-webkit-scrollbar-track {
        background: var(--border-light);
        border-radius: 4px;
    }

    .rdv-list::-webkit-scrollbar-thumb {
        background: #1a73e8;
        border-radius: 4px;
    }

    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .modal-content {
        animation: fadeInUp 0.3s ease;
    }

    /* Styles pour le modal */
    .rdv-detail-card {
        background: var(--hover-bg);
        border-radius: 12px;
        padding: 15px;
        transition: all 0.2s ease;
        margin-bottom: 12px;
    }

    .rdv-detail-card:hover {
        transform: translateX(5px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }

    .rdv-time {
        font-size: 18px;
        font-weight: bold;
        color: #1a73e8;
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 12px;
    }

    .rdv-info {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .rdv-info-item {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 13px;
    }

    .rdv-info-item i {
        width: 20px;
        color: #1a73e8;
    }

    .badge-status {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
    }

    @media (max-width: 768px) {
        .weekdays div {
            font-size: 11px;
            padding: 8px;
        }
        .weekdays div i {
            display: none;
        }
        .calendar-day {
            min-height: 70px;
            padding: 6px;
        }
        .day-number {
            font-size: 12px;
        }
        .rdv-badge {
            font-size: 8px;
            padding: 2px 4px;
        }
    }
</style>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    const userRole = '${sessionScope.role}';
    let currentRdvsData = {};

    <c:forEach items="${rdvsByDay}" var="entry">
        currentRdvsData[${entry.key}] = [
            <c:forEach items="${entry.value}" var="rdv" varStatus="status">
                {
                    idrdv: '${rdv.idrdv}',
                    heure: '${rdv.heure}',
                    statut: '${rdv.statut}',
                    nom: '${rdv.nom}',
                    email: '${rdv.email}',
                    specialite: '${rdv.specialite}',
                    lieu: '${rdv.lieu}',
                    medecinNom: '${rdv.medecinNom}',
                    medecinSpecialite: '${rdv.medecinSpecialite}'
                }${not status.last ? ',' : ''}
            </c:forEach>
        ];
    </c:forEach>

    function openDayModal(year, month, day) {
        const modal = document.getElementById('dayModal');
        const modalTitle = document.getElementById('modalTitle');
        const modalBody = document.getElementById('modalBody');

        const date = new Date(year, month - 1, day);
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
        modalTitle.innerHTML = '<i class="fas fa-calendar-day"></i> ' + date.toLocaleDateString('fr-FR', options);

        const rdvs = currentRdvsData[day] || [];

        if (rdvs.length === 0) {
            modalBody.innerHTML = `
                <div style="text-align:center; padding:40px;">
                    <i class="fas fa-calendar-times" style="font-size:48px; color:var(--text-muted); margin-bottom:15px;"></i>
                    <p style="color:var(--text-secondary);">Aucun rendez-vous ce jour</p>
                </div>
            `;
        } else {
            let html = '<div style="display:flex; flex-direction:column; gap:12px;">';
            for (let i = 0; i < rdvs.length; i++) {
                const rdv = rdvs[i];
                const statusText = rdv.statut == 'CONFIRME' ? 'Confirmé' : 'Annulé';
                const statusColor = rdv.statut == 'CONFIRME' ? '#34a853' : '#ea4335';
                const statusIcon = rdv.statut == 'CONFIRME' ? 'fa-check-circle' : 'fa-times-circle';

                // ========== ADMIN : Affichage complet (Patient + Médecin) ==========
                if (userRole === 'admin') {
                    html += `
                        <div class="rdv-detail-card">
                            <div class="rdv-time">
                                <i class="fas fa-clock"></i> ` + rdv.heure + `
                                <span class="badge-status" style="background:` + statusColor + `20; color:` + statusColor + `; margin-left:auto;">
                                    <i class="fas ` + statusIcon + `"></i> ` + statusText + `
                                </span>
                            </div>
                            <div class="rdv-info">
                                <div class="rdv-info-item"><i class="fas fa-user"></i> <strong>Patient:</strong> ` + rdv.nom + `</div>
                                <div class="rdv-info-item"><i class="fas fa-envelope"></i> ` + (rdv.email || 'Non renseigné') + `</div>
                                <div class="rdv-info-item"><i class="fas fa-user-md"></i> <strong>Médecin:</strong> ` + (rdv.medecinNom || 'Non spécifié') + `</div>
                                <div class="rdv-info-item"><i class="fas fa-stethoscope"></i> ` + (rdv.medecinSpecialite || 'Non spécifiée') + `</div>
                                <div class="rdv-info-item"><i class="fas fa-map-marker-alt"></i> ` + (rdv.lieu || 'Non spécifié') + `</div>
                            </div>
                        </div>
                    `;
                }
                // ========== MÉDECIN : Affichage patient uniquement ==========
                else if (userRole === 'medecin') {
                    html += `
                        <div class="rdv-detail-card">
                            <div class="rdv-time">
                                <i class="fas fa-clock"></i> ` + rdv.heure + `
                                <span class="badge-status" style="background:` + statusColor + `20; color:` + statusColor + `; margin-left:auto;">
                                    <i class="fas ` + statusIcon + `"></i> ` + statusText + `
                                </span>
                            </div>
                            <div class="rdv-info">
                                <div class="rdv-info-item"><i class="fas fa-user"></i> <strong>Patient:</strong> ` + rdv.nom + `</div>
                                <div class="rdv-info-item"><i class="fas fa-envelope"></i> ` + (rdv.email || 'Non renseigné') + `</div>
                            </div>
                        </div>
                    `;
                }
                // ========== PATIENT : Affichage médecin uniquement ==========
                else {
                    html += `
                        <div class="rdv-detail-card">
                            <div class="rdv-time">
                                <i class="fas fa-clock"></i> ` + rdv.heure + `
                                <span class="badge-status" style="background:` + statusColor + `20; color:` + statusColor + `; margin-left:auto;">
                                    <i class="fas ` + statusIcon + `"></i> ` + statusText + `
                                </span>
                            </div>
                            <div class="rdv-info">
                                <div class="rdv-info-item"><i class="fas fa-user-md"></i> <strong>Médecin:</strong> ` + rdv.nom + `</div>
                                <div class="rdv-info-item"><i class="fas fa-stethoscope"></i> ` + (rdv.specialite || 'Non spécifiée') + `</div>
                                <div class="rdv-info-item"><i class="fas fa-map-marker-alt"></i> ` + (rdv.lieu || 'Non spécifié') + `</div>
                            </div>
                        </div>
                    `;
                }
            }
            html += '</div>';
            modalBody.innerHTML = html;
        }

        modal.style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('dayModal').style.display = 'none';
    }

    window.onclick = function(event) {
        const modal = document.getElementById('dayModal');
        if (event.target === modal) {
            closeModal();
        }
    }
</script>

</body>
</html>