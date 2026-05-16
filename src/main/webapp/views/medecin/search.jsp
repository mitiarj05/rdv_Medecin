<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <h2 class="card-title">Trouver un médecin</h2>

        <%-- Barre de recherche --%>
        <form action="${pageContext.request.contextPath}/search" method="get"
              style="display:flex; gap:10px; margin-bottom:24px; flex-wrap:wrap;">

            <input type="text" name="q"
                   value="${motCle}"
                   placeholder="Rechercher par nom..."
                   style="flex:2; min-width:200px; padding:10px 14px; border:1px solid #ddd; border-radius:8px; font-size:14px;">

            <select name="specialite"
                    style="flex:1; min-width:160px; padding:10px 14px; border:1px solid #ddd; border-radius:8px; font-size:14px;">
                <option value="">Toutes spécialités</option>
                <c:forEach var="sp" items="${specialites}">
                    <option value="${sp}" ${filtreSpecialite == sp ? 'selected' : ''}>${sp}</option>
                </c:forEach>
            </select>

            <button type="submit" class="btn btn-primary">Rechercher</button>
            <a href="${pageContext.request.contextPath}/search" class="btn btn-secondary">Réinitialiser</a>
        </form>

        <%-- Résultats --%>
        <c:choose>
            <c:when test="${empty resultats}">
                <p style="text-align:center; color:#888; padding:40px;">
                    Aucun médecin trouvé pour cette recherche.
                </p>
            </c:when>
            <c:otherwise>
                <p style="color:#666; font-size:13px; margin-bottom:16px;">
                    ${resultats.size()} médecin(s) trouvé(s)
                </p>
                <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(280px,1fr)); gap:16px;">
                    <c:forEach var="m" items="${resultats}">
                        <div class="card" style="margin-bottom:0; border:1px solid #e8f0fe;">
                            <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                                <div>
                                    <h3 style="color:#1a73e8; font-size:16px; margin-bottom:4px;">
                                        Dr. ${m.nommed}
                                    </h3>
                                    <span class="badge badge-success">${m.specialite}</span>
                                </div>
                                <span style="color:#888; font-size:13px;">${m.lieu}</span>
                            </div>
                            <div style="margin-top:12px; padding-top:12px; border-top:1px solid #f0f4f8;">
                                <p style="font-size:13px; color:#555;">
                                    Taux : <strong>${m.tauxHoraire} Ar/h</strong>
                                </p>
                                <p style="font-size:13px; color:#555; margin-top:4px;">
                                    ${m.email}
                                </p>
                            </div>
                            <div style="margin-top:14px; display:flex; gap:8px; flex-wrap:wrap;">
                                <!-- LIEN VERS LE PROFIL PUBLIC -->
                                <a href="${pageContext.request.contextPath}/search?action=profile&id=${m.idmed}"
                                   class="btn btn-info" style="flex:1; text-align:center; font-size:13px; background:#17a2b8; color:white; text-decoration:none; padding:8px; border-radius:6px;">
                                    <i class="fas fa-user-md"></i> Voir profil
                                </a>
                                
                                <!-- LIEN VERS LES CRÉNEAUX -->
                                <a href="${pageContext.request.contextPath}/rdv?action=horaires&idmed=${m.idmed}"
                                   class="btn btn-primary" style="flex:1; text-align:center; font-size:13px; background:#1a73e8; color:white; text-decoration:none; padding:8px; border-radius:6px;">
                                    <i class="fas fa-clock"></i> Créneaux
                                </a>
                                
                                <!-- LIEN VERS LE FORMULAIRE DE RDV -->
                                <a href="${pageContext.request.contextPath}/rdv?action=form&idmed=${m.idmed}"
                                   class="btn btn-success" style="flex:1; text-align:center; font-size:13px; background:#34a853; color:white; text-decoration:none; padding:8px; border-radius:6px;">
                                    <i class="fas fa-calendar-plus"></i> RDV
                                </a>
                                
                                <!-- ===== NOUVEAU BOUTON : VOIR LA CARTE POUR CE MÉDECIN ===== -->
                                <c:choose>
                                    <c:when test="${not empty m.latitude and not empty m.longitude}">
                                        <button onclick="openDoctorMap(${m.latitude}, ${m.longitude}, '${fn:escapeXml(m.nommed)}', '${fn:escapeXml(m.specialite)}', '${fn:escapeXml(m.lieu)}')" 
                                                class="btn btn-warning" style="flex:1; text-align:center; font-size:13px; background:#fbbc04; color:#333; text-decoration:none; padding:8px; border-radius:6px; border:none; cursor:pointer;">
                                            <i class="fas fa-map-marker-alt"></i> Voir carte
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <button disabled 
                                                class="btn btn-secondary" style="flex:1; text-align:center; font-size:13px; background:#6c757d; color:white; padding:8px; border-radius:6px; cursor:not-allowed;">
                                            <i class="fas fa-map-marker-alt"></i> Position non dispo
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- MODAL POUR LA CARTE DU MÉDECIN -->
<div id="doctorMapModal" class="doctor-map-modal" style="display:none;">
    <div class="doctor-map-modal-content">
        <div class="doctor-map-modal-header">
            <h3 id="doctorMapTitle"><i class="fas fa-map-marker-alt"></i> Emplacement du médecin</h3>
            <span class="doctor-map-close" onclick="closeDoctorMap()">&times;</span>
        </div>
        <div class="doctor-map-modal-body">
            <div id="doctorMap" style="height: 400px; width: 100%; border-radius: 12px;"></div>
            <div id="doctorMapInfo" style="margin-top: 15px; padding: 10px; background: #f8f9fa; border-radius: 8px;">
                <p id="doctorMapDetails"></p>
            </div>
        </div>
        <div class="doctor-map-modal-footer">
            <button onclick="closeDoctorMap()" class="btn btn-secondary">Fermer</button>
            <a href="#" id="directionsLink" class="btn btn-primary" target="_blank">
                <i class="fas fa-directions"></i> Itinéraire
            </a>
        </div>
    </div>
</div>

<style>
    /* Styles pour le modal de la carte médecin */
    .doctor-map-modal {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.6);
        z-index: 2000;
        display: flex;
        align-items: center;
        justify-content: center;
        backdrop-filter: blur(3px);
    }
    
    .doctor-map-modal-content {
        background: var(--bg-card);
        border-radius: 16px;
        width: 90%;
        max-width: 700px;
        max-height: 90vh;
        overflow: hidden;
        animation: fadeInUp 0.3s ease;
        box-shadow: 0 20px 40px rgba(0,0,0,0.3);
    }
    
    .doctor-map-modal-header {
        padding: 15px 20px;
        background: linear-gradient(135deg, #1a73e8, #0d47a1);
        color: white;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .doctor-map-modal-header h3 {
        margin: 0;
        font-size: 18px;
    }
    
    .doctor-map-close {
        font-size: 28px;
        font-weight: bold;
        cursor: pointer;
        transition: transform 0.2s;
    }
    
    .doctor-map-close:hover {
        transform: scale(1.1);
    }
    
    .doctor-map-modal-body {
        padding: 20px;
    }
    
    .doctor-map-modal-footer {
        padding: 15px 20px;
        border-top: 1px solid var(--border-color);
        display: flex;
        justify-content: flex-end;
        gap: 10px;
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .btn-warning {
        background: #fbbc04;
        color: #333;
    }
    
    .btn-warning:hover {
        background: #e6a800;
        transform: translateY(-2px);
    }
</style>

<!-- Leaflet CSS et JS pour le modal -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<script>
    let doctorMapInstance = null;
    let currentDoctorLat = null;
    let currentDoctorLon = null;
    
    function openDoctorMap(lat, lon, nom, specialite, lieu) {
        currentDoctorLat = lat;
        currentDoctorLon = lon;
        
        // Afficher le modal
        document.getElementById('doctorMapModal').style.display = 'flex';
        
        // Mettre à jour le titre et les infos
        document.getElementById('doctorMapTitle').innerHTML = '<i class="fas fa-map-marker-alt"></i> Dr. ' + nom;
        document.getElementById('doctorMapDetails').innerHTML = 
            '<strong>' + specialite + '</strong><br>' +
            '<i class="fas fa-map-marker-alt"></i> ' + lieu + '<br>' +
            '<i class="fas fa-location-dot"></i> Coordonnées : ' + lat.toFixed(4) + ', ' + lon.toFixed(4);
        
        // Mettre à jour le lien d'itinéraire
        const directionsLink = document.getElementById('directionsLink');
        directionsLink.href = 'https://www.google.com/maps/dir/?api=1&destination=' + lat + ',' + lon;
        
        // Initialiser ou réinitialiser la carte après un court délai
        setTimeout(function() {
            initDoctorMap(lat, lon, nom, specialite, lieu);
        }, 100);
    }
    
    function initDoctorMap(lat, lon, nom, specialite, lieu) {
        const mapContainer = document.getElementById('doctorMap');
        
        // Si une carte existe déjà, la détruire
        if (doctorMapInstance) {
            doctorMapInstance.remove();
        }
        
        // Créer une nouvelle carte
        doctorMapInstance = L.map('doctorMap').setView([lat, lon], 15);
        
        // Ajouter les tuiles
        L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>',
            subdomains: 'abcd',
            maxZoom: 19
        }).addTo(doctorMapInstance);
        
        // Créer une icône personnalisée pour le médecin
        var doctorIcon = L.divIcon({
            className: 'doctor-marker',
            html: '<div style="background: #1a73e8; border: 3px solid white; border-radius: 50%; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; box-shadow: 0 2px 10px rgba(0,0,0,0.2);"><i class="fas fa-user-md" style="color: white; font-size: 18px;"></i></div>',
            iconSize: [40, 40],
            popupAnchor: [0, -20]
        });
        
        // Ajouter le marqueur
        var marker = L.marker([lat, lon], { icon: doctorIcon }).addTo(doctorMapInstance);
        
        // Ajouter une popup
        marker.bindPopup('<strong>Dr. ' + nom + '</strong><br>' + specialite + '<br><i class="fas fa-map-marker-alt"></i> ' + lieu).openPopup();
        
        // Ajouter un cercle de rayon
        L.circle([lat, lon], {
            color: '#1a73e8',
            fillColor: '#1a73e8',
            fillOpacity: 0.1,
            radius: 500
        }).addTo(doctorMapInstance);
    }
    
    function closeDoctorMap() {
        document.getElementById('doctorMapModal').style.display = 'none';
        if (doctorMapInstance) {
            doctorMapInstance.remove();
            doctorMapInstance = null;
        }
    }
    
    // Fermer le modal si on clique en dehors
    window.onclick = function(event) {
        const modal = document.getElementById('doctorMapModal');
        if (event.target === modal) {
            closeDoctorMap();
        }
    }
    
    // Empêcher la propagation des clics sur le contenu du modal
    document.querySelector('.doctor-map-modal-content').addEventListener('click', function(e) {
        e.stopPropagation();
    });
</script>

<style>
    .doctor-marker {
        background: transparent;
        border: none;
    }
    .btn-warning {
        background: #fbbc04;
        color: #333;
        border: none;
        cursor: pointer;
    }
    .btn-warning:hover:not(:disabled) {
        background: #e6a800;
        transform: translateY(-2px);
    }
    .badge {
        display: inline-block;
        padding: 0.25rem 0.5rem;
        font-size: 0.75rem;
        font-weight: 600;
        line-height: 1;
        text-align: center;
        white-space: nowrap;
        vertical-align: baseline;
        border-radius: 0.375rem;
    }
    .badge-success {
        background-color: #d1e7dd;
        color: #0f5132;
    }
</style>

</body>
</html>