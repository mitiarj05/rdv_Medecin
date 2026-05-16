<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Carte des médecins - RDV Medical</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        #map {
            height: 500px;
            width: 100%;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .doctor-card {
            background: var(--bg-card);
            border-radius: 12px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            transition: transform 0.2s;
            cursor: pointer;
            border: 1px solid var(--border-color);
        }
        
        .doctor-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px var(--shadow-hover);
            border-color: #1a73e8;
        }
        
        .doctor-avatar {
            width: 55px;
            height: 55px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #1a73e8, #0d47a1);
            color: white;
            font-size: 22px;
        }
        
        .distance-badge {
            background: #1a73e8;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 6px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        
        .btn-outline-primary {
            border: 1px solid #1a73e8;
            color: #1a73e8;
            background: transparent;
        }
        
        .btn-outline-primary:hover {
            background: #1a73e8;
            color: white;
        }
        
        .search-box {
            background: var(--bg-card);
            padding: 20px;
            border-radius: 16px;
            margin-bottom: 20px;
            border: 1px solid var(--border-color);
        }
        
        .custom-marker {
            background: #1a73e8;
            border: 3px solid white;
            border-radius: 50%;
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            cursor: pointer;
            transition: transform 0.2s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }
        
        .custom-marker:hover {
            transform: scale(1.15);
            background: #0d47a1;
        }
        
        .current-location-marker {
            background: #ea4335;
        }
        
        .stats-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .result-counter {
            background: linear-gradient(135deg, #1a73e8, #0d47a1);
            color: white;
            padding: 8px 16px;
            border-radius: 30px;
            font-size: 13px;
            font-weight: 500;
        }
        
        .radius-slider {
            display: flex;
            align-items: center;
            gap: 15px;
            background: var(--hover-bg);
            padding: 8px 15px;
            border-radius: 30px;
        }
        
        .radius-slider input {
            width: 150px;
        }
        
        .radius-value {
            background: #1a73e8;
            color: white;
            padding: 2px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .btn-location {
            background: #ea4335;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 30px;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.2s;
        }
        
        .btn-location:hover {
            background: #c5221f;
            transform: translateY(-2px);
        }
        
        .layer-control {
            position: absolute;
            bottom: 20px;
            right: 20px;
            background: var(--bg-card);
            padding: 8px 15px;
            border-radius: 30px;
            z-index: 1000;
            display: flex;
            gap: 8px;
            border: 1px solid var(--border-color);
        }
        
        .layer-control button {
            background: none;
            border: none;
            padding: 5px 12px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 11px;
        }
        
        .layer-control button.active {
            background: #1a73e8;
            color: white;
        }
        
        @media (max-width: 768px) {
            #map { height: 350px; }
            .radius-slider { flex-wrap: wrap; justify-content: center; }
            .layer-control { bottom: 10px; right: 10px; }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="card">
        <h2 class="card-title">
            <i class="fas fa-map-marked-alt"></i> Carte des médecins
        </h2>
        
        <div class="search-box">
            <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 15px;">
                <div style="flex: 3;">
                    <input type="text" id="locationInput" 
                           placeholder="Entrez une adresse, ville ou quartier..." 
                           style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 30px; font-size: 14px;">
                </div>
                <div style="flex: 1;">
                    <select id="specialiteFilter" style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 30px;">
                        <option value="">Toutes spécialités</option>
                        <c:forEach var="sp" items="${specialites}">
                            <option value="${sp}">${sp}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            
            <div style="display: flex; gap: 10px; flex-wrap: wrap; align-items: center; justify-content: space-between;">
                <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                    <!-- BOUTON MA POSITION (GPS) -->
                    <button id="useCurrentLocationBtn" class="btn-location">
                        <i class="fas fa-location-dot"></i> 📍 Ma position
                    </button>
                    
                    <!-- BOUTON RECHERCHER (à partir de l'adresse tapée) -->
                    <button id="searchNearbyBtn" class="btn btn-primary">
                        <i class="fas fa-search"></i> 🔍 Rechercher
                    </button>
                    
                    <button id="resetMapBtn" class="btn btn-secondary">
                        <i class="fas fa-undo-alt"></i> Réinitialiser
                    </button>
                </div>
                
                <div class="radius-slider">
                    <label><i class="fas fa-road"></i> Rayon :</label>
                    <input type="range" id="radiusSlider" min="1" max="50" value="10" step="1">
                    <span class="radius-value" id="radiusValue">10 km</span>
                </div>
            </div>
            
            <!-- Indication d'utilisation -->
            <div style="margin-top: 12px; font-size: 11px; color: var(--text-muted); text-align: center;">
                <i class="fas fa-info-circle"></i> 
                <span id="actionHint">Cliquez sur "📍 Ma position" pour trouver les médecins autour de vous, ou entrez une adresse puis "🔍 Rechercher"</span>
            </div>
        </div>
        
        <div class="stats-bar">
            <div class="result-counter">
                <i class="fas fa-chart-line"></i> <span id="doctorCount">0</span> médecins trouvés
            </div>
            <div id="searchInfo" style="font-size: 12px;">
                <i class="fas fa-info-circle"></i> Cliquez sur un marqueur pour plus d'informations
            </div>
        </div>
        
        <div id="map"></div>
        
        <div class="layer-control">
            <button id="layerStreet" class="active">🗺️ Rue</button>
            <button id="layerSatellite">🛰️ Satellite</button>
            <button id="layerDark">🌙 Nuit</button>
        </div>
        
        <h3><i class="fas fa-chart-line"></i> Médecins à proximité <span id="nearbyCount"></span></h3>
        <div id="nearbyDoctors" style="max-height: 400px; overflow-y: auto;">
            <div style="text-align: center; padding: 40px; color: #666;">
                <i class="fas fa-map-marker-alt" style="font-size: 48px; margin-bottom: 10px;"></i>
                <p>Cliquez sur "📍 Ma position" ou entrez une adresse puis "🔍 Rechercher"</p>
            </div>
        </div>
    </div>
</div>

<script>
    // Initialisation de la carte
    var map = L.map('map').setView([-18.8792, 47.5079], 13);
    
    // Couches de carte
    var streetLayer = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; OpenStreetMap &copy; CARTO',
        subdomains: 'abcd',
        maxZoom: 19
    });
    
    var satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: 'Tiles &copy; Esri'
    });
    
    var darkLayer = L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; OpenStreetMap &copy; CARTO',
        subdomains: 'abcd',
        maxZoom: 19
    });
    
    streetLayer.addTo(map);
    
    function switchLayer(type) {
        map.removeLayer(streetLayer);
        map.removeLayer(satelliteLayer);
        map.removeLayer(darkLayer);
        if (type === 'street') streetLayer.addTo(map);
        else if (type === 'satellite') satelliteLayer.addTo(map);
        else if (type === 'dark') darkLayer.addTo(map);
        
        document.getElementById('layerStreet').classList.remove('active');
        document.getElementById('layerSatellite').classList.remove('active');
        document.getElementById('layerDark').classList.remove('active');
        document.getElementById('layer' + type.charAt(0).toUpperCase() + type.slice(1)).classList.add('active');
    }
    
    document.getElementById('layerStreet').addEventListener('click', function() { switchLayer('street'); });
    document.getElementById('layerSatellite').addEventListener('click', function() { switchLayer('satellite'); });
    document.getElementById('layerDark').addEventListener('click', function() { switchLayer('dark'); });
    
    var markers = {};
    var currentPositionMarker = null;
    var doctors = [];
    var currentLat = -18.8792;
    var currentLon = 47.5079;
    
    // Récupérer les médecins
    <c:forEach var="m" items="${medecins}">
    doctors.push({
        id: '${m.idmed}',
        nom: '${fn:escapeXml(m.nommed)}',
        specialite: '${fn:escapeXml(m.specialite)}',
        lieu: '${fn:escapeXml(m.lieu)}',
        tauxHoraire: ${m.tauxHoraire},
        latitude: ${m.latitude},
        longitude: ${m.longitude},
        photo: '${m.photoProfile != null ? m.photoProfile : ""}'
    });
    </c:forEach>
    
    function addMarkers(filterSpecialite) {
        for (var id in markers) map.removeLayer(markers[id]);
        markers = {};
        
        var filtered = doctors;
        if (filterSpecialite && filterSpecialite !== '') {
            filtered = doctors.filter(function(d) { return d.specialite === filterSpecialite; });
        }
        
        document.getElementById('doctorCount').innerText = filtered.length;
        
        filtered.forEach(function(doctor) {
            var icon = L.divIcon({
                className: 'custom-marker',
                html: '<i class="fas fa-user-md"></i>',
                iconSize: [36, 36],
                popupAnchor: [0, -18]
            });
            
            var marker = L.marker([doctor.latitude, doctor.longitude], { icon: icon }).addTo(map);
            markers[doctor.id] = marker;
            
            var photoHtml = doctor.photo ? 
                '<img src="' + doctor.photo + '" style="width: 45px; height: 45px; border-radius: 50%; object-fit: cover; float: left; margin-right: 12px;">' : 
                '<div style="width: 45px; height: 45px; background: linear-gradient(135deg, #1a73e8, #0d47a1); border-radius: 50%; display: flex; align-items: center; justify-content: center; float: left; margin-right: 12px;"><i class="fas fa-user-md" style="color: white;"></i></div>';
            
            var popup = '<div style="min-width: 220px;">' + photoHtml +
                '<div style="margin-left: 57px;">' +
                '<strong style="color:#1a73e8;">Dr. ' + doctor.nom + '</strong><br>' +
                '<span style="color:#34a853;">' + doctor.specialite + '</span><br>' +
                '<i class="fas fa-map-marker-alt"></i> ' + doctor.lieu + '<br>' +
                '<i class="fas fa-money-bill-wave"></i> ' + doctor.tauxHoraire + ' Ar/h<br>' +
                '<div style="margin-top: 8px;">' +
                '<a href="${pageContext.request.contextPath}/search?action=profile&id=' + doctor.id + '" style="font-size:11px; padding:4px 8px;" class="btn-sm btn-outline-primary"><i class="fas fa-user-md"></i> Profil</a> ' +
                '<a href="${pageContext.request.contextPath}/rdv?action=form&idmed=' + doctor.id + '" style="font-size:11px; padding:4px 8px; background:#34a853; color:white;" class="btn-sm"><i class="fas fa-calendar-plus"></i> RDV</a>' +
                '</div></div></div>';
            
            marker.bindPopup(popup);
            marker.on('click', function() { showNearbyDoctors(doctor.latitude, doctor.longitude); });
        });
    }
    
    // Fonction principale : trouver les médecins autour d'un point
    function findNearbyDoctors(lat, lon, source) {
        currentLat = lat;
        currentLon = lon;
        var maxDistance = parseInt(document.getElementById('radiusSlider').value);
        var hint = document.getElementById('actionHint');
        
        if (source === 'gps') {
            hint.innerHTML = '📍 Vous êtes ici ! Recherche des médecins dans un rayon de ' + maxDistance + ' km...';
        } else if (source === 'address') {
            hint.innerHTML = '🔍 Recherche autour de l\'adresse saisie...';
        }
        
        var nearbyDiv = document.getElementById('nearbyDoctors');
        nearbyDiv.innerHTML = '<div style="text-align: center; padding: 20px;"><i class="fas fa-spinner fa-spin"></i> Recherche en cours...</div>';
        
        var results = [];
        for (var i = 0; i < doctors.length; i++) {
            var d = doctors[i];
            var dist = calculateDistance(lat, lon, d.latitude, d.longitude);
            if (dist <= maxDistance) {
                results.push({ doctor: d, distance: dist });
            }
        }
        
        results.sort(function(a, b) { return a.distance - b.distance; });
        
        var html = '';
        var count = results.length;
        document.getElementById('nearbyCount').innerHTML = '(' + count + ' dans ' + maxDistance + ' km)';
        
        if (count === 0) {
            html = '<div style="text-align: center; padding: 40px;"><i class="fas fa-search" style="font-size: 48px; margin-bottom: 10px;"></i>' +
                   '<p>Aucun médecin trouvé dans un rayon de ' + maxDistance + ' km.</p>' +
                   '<p style="font-size:12px;">🔍 Essayez d\'augmenter le rayon ou une autre position.</p></div>';
        } else {
            for (var i = 0; i < results.length; i++) {
                var r = results[i];
                var doc = r.doctor;
                var distText = r.distance < 1 ? (r.distance * 1000).toFixed(0) + ' m' : r.distance.toFixed(1) + ' km';
                
                var photoHtml = doc.photo ? 
                    '<img src="' + doc.photo + '" style="width: 50px; height: 50px; border-radius: 50%; object-fit: cover;">' : 
                    '<div style="width: 50px; height: 50px; background: linear-gradient(135deg, #1a73e8, #0d47a1); border-radius: 50%; display: flex; align-items: center; justify-content: center;"><i class="fas fa-user-md" style="color: white; font-size: 22px;"></i></div>';
                
                html += '<div class="doctor-card" onclick="centerOnDoctor(' + doc.latitude + ',' + doc.longitude + ')">' +
                    '<div style="display: flex; gap: 15px; align-items: center;">' +
                    '<div class="doctor-avatar">' + photoHtml + '</div>' +
                    '<div style="flex: 1;">' +
                    '<strong style="color:#1a73e8;">Dr. ' + doc.nom + '</strong><br>' +
                    '<span style="color:#34a853;">' + doc.specialite + '</span><br>' +
                    '<i class="fas fa-map-marker-alt"></i> ' + doc.lieu +
                    '</div>' +
                    '<div style="text-align: right;">' +
                    '<span class="distance-badge"><i class="fas fa-location-dot"></i> ' + distText + '</span><br>' +
                    '<div style="margin-top: 8px;">' +
                    '<a href="${pageContext.request.contextPath}/search?action=profile&id=' + doc.id + '" class="btn-sm btn-outline-primary"><i class="fas fa-user-md"></i> Profil</a> ' +
                    '<a href="${pageContext.request.contextPath}/rdv?action=form&idmed=' + doc.id + '" class="btn-sm" style="background:#34a853; color:white;"><i class="fas fa-calendar-plus"></i> RDV</a>' +
                    '</div></div></div></div>';
            }
        }
        
        nearbyDiv.innerHTML = html;
        map.setView([lat, lon], 13);
        
        if (currentPositionMarker) map.removeLayer(currentPositionMarker);
        
        var currentIcon = L.divIcon({
            className: 'custom-marker current-location-marker',
            html: '<i class="fas fa-location-dot"></i>',
            iconSize: [36, 36],
            popupAnchor: [0, -18]
        });
        
        currentPositionMarker = L.marker([lat, lon], { icon: currentIcon }).addTo(map);
        currentPositionMarker.bindPopup('<strong>📍 Votre position</strong>').openPopup();
        
        setTimeout(function() {
            hint.innerHTML = 'Cliquez sur "📍 Ma position" pour trouver les médecins autour de vous, ou entrez une adresse puis "🔍 Rechercher"';
        }, 3000);
    }
    
    // GPS - Ma position
    function useCurrentLocation() {
        if (navigator.geolocation) {
            var hint = document.getElementById('actionHint');
            hint.innerHTML = '📍 Récupération de votre position GPS...';
            
            navigator.geolocation.getCurrentPosition(
                function(position) {
                    findNearbyDoctors(position.coords.latitude, position.coords.longitude, 'gps');
                },
                function(error) {
                    var msg = '';
                    if (error.code === 1) msg = 'Vous avez refusé la géolocalisation. Activez-la dans les paramètres.';
                    else if (error.code === 2) msg = 'Position indisponible.';
                    else msg = 'Erreur de géolocalisation.';
                    alert(msg);
                    hint.innerHTML = '❌ ' + msg + ' Essayez avec une adresse.';
                }
            );
        } else {
            alert("Votre navigateur ne supporte pas la géolocalisation.");
        }
    }
    
    // Recherche par adresse
    function searchByAddress() {
        var address = document.getElementById('locationInput').value;
        if (!address.trim()) {
            alert("Veuillez entrer une adresse.");
            return;
        }
        
        var hint = document.getElementById('actionHint');
        hint.innerHTML = '🔍 Recherche de l\'adresse...';
        
        var url = 'https://nominatim.openstreetmap.org/search?q=' + encodeURIComponent(address) + '&format=json&limit=1';
        
        document.getElementById('nearbyDoctors').innerHTML = '<div style="text-align: center; padding: 20px;"><i class="fas fa-spinner fa-spin"></i> Recherche de l\'adresse...</div>';
        
        fetch(url, { headers: { 'User-Agent': 'RDV Medical/1.0' } })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data && data.length > 0) {
                    var lat = parseFloat(data[0].lat);
                    var lon = parseFloat(data[0].lon);
                    findNearbyDoctors(lat, lon, 'address');
                    document.getElementById('locationInput').value = data[0].display_name;
                } else {
                    document.getElementById('nearbyDoctors').innerHTML = '<div style="text-align: center; padding: 20px; color: #666;">Adresse non trouvée. Veuillez essayer autre chose.</div>';
                    hint.innerHTML = '❌ Adresse non trouvée. Essayez une autre.';
                }
            })
            .catch(function() {
                document.getElementById('nearbyDoctors').innerHTML = '<div style="text-align: center; padding: 20px; color: #666;">Erreur lors de la recherche.</div>';
            });
    }
    
    function calculateDistance(lat1, lon1, lat2, lon2) {
        var R = 6371;
        var dLat = (lat2 - lat1) * Math.PI / 180;
        var dLon = (lon2 - lon1) * Math.PI / 180;
        var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                Math.sin(dLon/2) * Math.sin(dLon/2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return R * c;
    }
    
    function centerOnDoctor(lat, lon) { map.setView([lat, lon], 16); }
    function resetMap() {
        addMarkers('');
        map.setView([-18.8792, 47.5079], 13);
        if (currentPositionMarker) map.removeLayer(currentPositionMarker);
        document.getElementById('nearbyDoctors').innerHTML = '<div style="text-align: center; padding: 40px;"><i class="fas fa-map-marker-alt" style="font-size: 48px;"></i><p>Cliquez sur "📍 Ma position" ou entrez une adresse</p></div>';
        document.getElementById('locationInput').value = '';
        document.getElementById('radiusSlider').value = 10;
        document.getElementById('radiusValue').innerHTML = '10 km';
        document.getElementById('specialiteFilter').value = '';
        document.getElementById('nearbyCount').innerHTML = '';
        document.getElementById('actionHint').innerHTML = 'Cliquez sur "📍 Ma position" pour trouver les médecins autour de vous, ou entrez une adresse puis "🔍 Rechercher"';
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        addMarkers('');
        document.getElementById('searchNearbyBtn').addEventListener('click', searchByAddress);
        document.getElementById('useCurrentLocationBtn').addEventListener('click', useCurrentLocation);
        document.getElementById('resetMapBtn').addEventListener('click', resetMap);
        document.getElementById('radiusSlider').addEventListener('input', function() {
            document.getElementById('radiusValue').innerHTML = this.value + ' km';
        });
        document.getElementById('specialiteFilter').addEventListener('change', function() {
            addMarkers(this.value);
            if (currentPositionMarker) findNearbyDoctors(currentLat, currentLon, 'update');
        });
        document.getElementById('locationInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') searchByAddress();
        });
    });
</script>

</body>
</html>