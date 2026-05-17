<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Carte de mes patients - RDV Medical</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        #map {
            height: 550px;
            width: 100%;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

        .patient-card {
            background: var(--bg-card);
            border-radius: 12px;
            padding: 15px;
            margin-bottom: 12px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            transition: transform 0.2s;
            cursor: pointer;
            border: 1px solid var(--border-color);
        }

        .patient-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px var(--shadow-hover);
        }

        .patient-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: linear-gradient(135deg, #34a853, #1e7e4a);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
            flex-shrink: 0;
        }

        .distance-badge {
            background: #1a73e8;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .btn-sm {
            padding: 5px 10px;
            font-size: 11px;
            border-radius: 6px;
            text-decoration: none;
        }

        .search-box {
            background: var(--bg-card);
            padding: 20px;
            border-radius: 16px;
            margin-bottom: 20px;
            border: 1px solid var(--border-color);
        }

        .custom-marker-doctor {
            background: #1a73e8;
            border: 3px solid white;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
            cursor: pointer;
            transition: transform 0.2s;
        }

        .custom-marker-doctor:hover {
            transform: scale(1.1);
        }

        .custom-marker-patient {
            background: #34a853;
            border: 3px solid white;
            border-radius: 50%;
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 14px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
            cursor: pointer;
            transition: transform 0.2s;
        }

        .custom-marker-patient:hover {
            transform: scale(1.1);
            background: #1e7e4a;
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
        }

        .route-planner {
            background: var(--bg-card);
            border-radius: 12px;
            padding: 15px;
            margin-top: 20px;
            border: 1px solid var(--border-color);
        }

        .patient-checkbox {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px;
            border-bottom: 1px solid var(--border-color);
        }

        .patient-checkbox:hover {
            background: var(--hover-bg);
        }

        /* Contrôle des couches de carte */
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
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        }

        .layer-control button {
            background: none;
            border: none;
            padding: 5px 12px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 11px;
            transition: all 0.2s;
        }

        .layer-control button.active {
            background: #1a73e8;
            color: white;
        }

        .layer-control button:hover:not(.active) {
            background: var(--hover-bg);
        }

        @media (max-width: 768px) {
            #map { height: 350px; }
            .stats-bar { flex-direction: column; align-items: stretch; }
            .layer-control { bottom: 10px; right: 10px; padding: 5px 10px; }
            .layer-control button { padding: 3px 8px; font-size: 10px; }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="card">
        <h2 class="card-title">
            <i class="fas fa-heartbeat"></i> Carte de mes patients
        </h2>

        <!-- Barre d'info -->
        <div class="search-box">
            <div style="display: flex; gap: 10px; flex-wrap: wrap; align-items: center; justify-content: space-between;">
                <div>
                    <i class="fas fa-info-circle"></i>
                    <strong>${medecin.nommed}</strong> - Cabinet: ${medecin.lieu}
                    <c:if test="${medecin.hasCoordinates()}">
                        <span class="distance-badge" style="background:#34a853;">
                            <i class="fas fa-check-circle"></i> Cabinet géolocalisé
                        </span>
                    </c:if>
                </div>
                <div>
                    <button id="centerOnCabinetBtn" class="btn btn-primary btn-sm">
                        <i class="fas fa-map-marker-alt"></i> Centrer sur mon cabinet
                    </button>
                    <button id="planRouteBtn" class="btn btn-success btn-sm">
                        <i class="fas fa-route"></i> Planifier itinéraire
                    </button>
                    <button id="resetViewBtn" class="btn btn-secondary btn-sm">
                        <i class="fas fa-undo-alt"></i> Réinitialiser
                    </button>
                </div>
            </div>
        </div>

        <!-- Statistiques -->
        <div class="stats-bar">
            <div class="result-counter">
                <i class="fas fa-users"></i> <span id="patientCount">0</span> patients géolocalisés
            </div>
            <div id="searchInfo" style="font-size: 12px;">
                <i class="fas fa-info-circle"></i> Cliquez sur un patient pour voir ses informations
            </div>
        </div>

        <!-- Carte -->
        <div id="map"></div>

        <!-- Contrôle des couches de carte (vue satellite) -->
        <div class="layer-control">
            <button id="layerStreet" class="active">🗺️ Rue</button>
            <button id="layerSatellite">🛰️ Satellite</button>
            <button id="layerDark">🌙 Nuit</button>
        </div>

        <!-- Planificateur d'itinéraire -->
        <div class="route-planner" id="routePlanner" style="display: none;">
            <h4><i class="fas fa-route"></i> Planificateur d'itinéraire</h4>
            <p>Sélectionnez les patients à visiter :</p>
            <div id="patientsListForRoute" style="max-height: 200px; overflow-y: auto; margin-bottom: 10px;"></div>
            <button id="generateRouteBtn" class="btn btn-primary">
                <i class="fas fa-map-marked-alt"></i> Générer l'itinéraire
            </button>
            <button id="cancelRouteBtn" class="btn btn-secondary">
                <i class="fas fa-times"></i> Annuler
            </button>
            <div id="routeResult" style="margin-top: 15px; display: none;">
                <h5>Itinéraire suggéré :</h5>
                <ol id="routeSteps"></ol>
                <p><strong>Distance totale :</strong> <span id="totalDistance"></span></p>
                <a id="openGoogleMapsBtn" href="#" target="_blank" class="btn btn-success">
                    <i class="fas fa-directions"></i> Ouvrir dans Google Maps
                </a>
            </div>
        </div>

        <!-- Liste des patients -->
        <h3><i class="fas fa-users"></i> Mes patients <span id="patientListCount"></span></h3>
        <div id="patientsList" style="max-height: 400px; overflow-y: auto;">
            <div style="text-align: center; padding: 40px;">
                <i class="fas fa-spinner fa-spin"></i> Chargement...
            </div>
        </div>
    </div>
</div>

<script>
    // Initialisation de la carte
    var map = L.map('map').setView([-18.8792, 47.5079], 13);

    // ========== DIFFÉRENTES COUCHES DE CARTE ==========

    // 1. Carte standard (rue) - CartoDB Voyager
    var streetLayer = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>',
        subdomains: 'abcd',
        maxZoom: 19
    });

    // 2. Carte satellite - ESRI World Imagery (vue réelle)
    var satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
        maxZoom: 18
    });

    // 3. Carte nuit (sombre) - CartoDB Dark Matter
    var darkLayer = L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>',
        subdomains: 'abcd',
        maxZoom: 19
    });

    // Ajouter la couche par défaut (rue)
    streetLayer.addTo(map);

    var currentLayer = 'street';

    function switchLayer(layerType) {
        map.removeLayer(streetLayer);
        map.removeLayer(satelliteLayer);
        map.removeLayer(darkLayer);

        switch(layerType) {
            case 'street':
                streetLayer.addTo(map);
                break;
            case 'satellite':
                satelliteLayer.addTo(map);
                break;
            case 'dark':
                darkLayer.addTo(map);
                break;
        }
        currentLayer = layerType;

        document.getElementById('layerStreet').classList.remove('active');
        document.getElementById('layerSatellite').classList.remove('active');
        document.getElementById('layerDark').classList.remove('active');
        document.getElementById('layer' + layerType.charAt(0).toUpperCase() + layerType.slice(1)).classList.add('active');
    }

    document.getElementById('layerStreet').addEventListener('click', function() { switchLayer('street'); });
    document.getElementById('layerSatellite').addEventListener('click', function() { switchLayer('satellite'); });
    document.getElementById('layerDark').addEventListener('click', function() { switchLayer('dark'); });

    var markers = {};
    var cabinetMarker = null;
    var patients = [];
    var cabinetLat = ${medecin.latitude != null ? medecin.latitude : -18.8792};
    var cabinetLon = ${medecin.longitude != null ? medecin.longitude : 47.5079};
    var doctorName = '${fn:escapeXml(medecin.nommed)}';
    var selectedPatientsForRoute = [];

    // Récupérer les patients du médecin
    <c:forEach var="p" items="${patientsAvecStats}">
    patients.push({
        id: '${p.idpat}',
        nom: '${fn:escapeXml(p.nomPat)}',
        email: '${fn:escapeXml(p.email)}',
        telephone: '${fn:escapeXml(p.telephone)}',
        latitude: ${p.latitude},
        longitude: ${p.longitude},
        adresse: '${fn:escapeXml(p.adresse != null ? p.adresse : p.nomPat)}',
        nbRdv: ${p.nbRendezVous},
        dernierRdv: '${p.dernierRdv != null ? p.dernierRdv : ""}'
    });
    </c:forEach>

    function addCabinetMarker() {
        if (cabinetMarker) map.removeLayer(cabinetMarker);

        var cabinetIcon = L.divIcon({
            className: 'custom-marker-doctor',
            html: '<i class="fas fa-stethoscope"></i>',
            iconSize: [40, 40],
            popupAnchor: [0, -20]
        });

        cabinetMarker = L.marker([cabinetLat, cabinetLon], { icon: cabinetIcon }).addTo(map);
        cabinetMarker.bindPopup('<strong><i class="fas fa-stethoscope"></i> Mon cabinet</strong><br>' + doctorName);
    }

    function addPatientMarkers() {
        for (var id in markers) map.removeLayer(markers[id]);
        markers = {};

        document.getElementById('patientCount').innerText = patients.length;
        document.getElementById('patientListCount').innerHTML = '(' + patients.length + ')';

        patients.forEach(function(patient) {
            var patientIcon = L.divIcon({
                className: 'custom-marker-patient',
                html: '<i class="fas fa-user"></i>',
                iconSize: [32, 32],
                popupAnchor: [0, -16]
            });

            var marker = L.marker([patient.latitude, patient.longitude], { icon: patientIcon }).addTo(map);
            markers[patient.id] = marker;

            var distance = calculateDistance(cabinetLat, cabinetLon, patient.latitude, patient.longitude);
            var distanceText = distance < 1 ? (distance * 1000).toFixed(0) + ' m' : distance.toFixed(1) + ' km';

            var lastRdvText = patient.dernierRdv ? patient.dernierRdv : 'Aucun RDV';

            var popupContent =
                '<div style="min-width: 220px;">' +
                '<div style="width: 45px; height: 45px; background: #34a853; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; float: left; margin-right: 12px;"><i class="fas fa-user" style="color: white; font-size: 20px;"></i></div>' +
                '<div style="margin-left: 57px;">' +
                '<strong>' + patient.nom + '</strong><br>' +
                '<span style="color: #34a853;">' + patient.nbRdv + ' consultation(s)</span><br>' +
                '<span style="font-size: 11px; color: #666;"><i class="fas fa-calendar"></i> Dernier RDV: ' + lastRdvText + '</span><br>' +
                '<i class="fas fa-map-marker-alt"></i> ' + (patient.adresse || patient.nom) + '<br>' +
                '<i class="fas fa-road"></i> Distance cabinet: ' + distanceText + '<br>' +
                '<i class="fas fa-envelope"></i> ' + patient.email + '<br>' +
                '<i class="fas fa-phone"></i> ' + (patient.telephone != 'null' && patient.telephone ? patient.telephone : 'Non renseigné') + '<br>' +
                '<div style="margin-top: 8px;">' +
                '<a href="https://www.google.com/maps/dir/?api=1&destination=' + patient.latitude + ',' + patient.longitude + '" target="_blank" class="btn-sm" style="background:#1a73e8; color:white;"><i class="fas fa-directions"></i> Itinéraire</a>' +
                '</div>' +
                '</div>' +
                '</div>';

            marker.bindPopup(popupContent);
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

    function centerOnCabinet() {
        map.setView([cabinetLat, cabinetLon], 14);
        if (cabinetMarker) cabinetMarker.openPopup();
    }

    function resetView() {
        map.setView([cabinetLat, cabinetLon], 12);
    }

    function displayPatientsList() {
        var container = document.getElementById('patientsList');
        if (patients.length === 0) {
            container.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="fas fa-user-slash"></i><p>Aucun patient avec adresse géolocalisée.</p><p style="font-size:12px;">Les patients doivent avoir une adresse renseignée pour apparaître sur la carte.</p></div>';
            return;
        }

        var html = '';
        patients.forEach(function(patient) {
            var distance = calculateDistance(cabinetLat, cabinetLon, patient.latitude, patient.longitude);
            var distanceText = distance < 1 ? (distance * 1000).toFixed(0) + ' m' : distance.toFixed(1) + ' km';
            var lastRdvText = patient.dernierRdv ? patient.dernierRdv : 'Aucun RDV';

            html += '<div class="patient-card" onclick="centerOnPatient(' + patient.latitude + ', ' + patient.longitude + ')">' +
                '<div style="display: flex; gap: 15px; align-items: center;">' +
                '<div class="patient-avatar"><i class="fas fa-user"></i></div>' +
                '<div style="flex: 1;">' +
                '<strong>' + patient.nom + '</strong><br>' +
                '<span style="color: #34a853; font-size: 12px;">' + patient.nbRdv + ' consultation(s)</span><br>' +
                '<span style="font-size: 11px; color: #666;"><i class="fas fa-calendar"></i> Dernier RDV: ' + lastRdvText + '</span><br>' +
                '<i class="fas fa-map-marker-alt" style="font-size: 11px;"></i> ' + (patient.adresse || patient.nom) +
                '</div>' +
                '<div style="text-align: right;">' +
                '<span class="distance-badge"><i class="fas fa-road"></i> ' + distanceText + '</span><br>' +
                '<div style="margin-top: 8px;">' +
                '<a href="https://www.google.com/maps/dir/?api=1&destination=' + patient.latitude + ',' + patient.longitude + '" target="_blank" class="btn-sm" style="background:#1a73e8; color:white;"><i class="fas fa-directions"></i> Y aller</a>' +
                '</div>' +
                '</div>' +
                '</div>' +
                '</div>';
        });
        container.innerHTML = html;
    }

    function centerOnPatient(lat, lon) {
        map.setView([lat, lon], 15);
    }

    // ========== PLANIFICATEUR D'ITINÉRAIRE ==========
    function showRoutePlanner() {
        document.getElementById('routePlanner').style.display = 'block';
        var container = document.getElementById('patientsListForRoute');
        var html = '';
        patients.forEach(function(patient) {
            html += '<div class="patient-checkbox">' +
                '<input type="checkbox" class="patient-route-checkbox" value="' + patient.id + '" data-nom="' + patient.nom + '" data-lat="' + patient.latitude + '" data-lon="' + patient.longitude + '">' +
                '<strong>' + patient.nom + '</strong>' +
                '<span style="margin-left: auto; font-size: 11px;">' + (patient.adresse || patient.nom) + '</span>' +
                '</div>';
        });
        container.innerHTML = html;
        document.getElementById('routeResult').style.display = 'none';
        selectedPatientsForRoute = [];

        document.querySelectorAll('.patient-route-checkbox').forEach(function(cb) {
            cb.addEventListener('change', function() {
                if (this.checked) {
                    selectedPatientsForRoute.push({
                        id: this.value,
                        nom: this.dataset.nom,
                        lat: parseFloat(this.dataset.lat),
                        lon: parseFloat(this.dataset.lon)
                    });
                } else {
                    selectedPatientsForRoute = selectedPatientsForRoute.filter(function(p) { return p.id !== this.value; }.bind(this));
                }
            });
        });
    }

    function hideRoutePlanner() {
        document.getElementById('routePlanner').style.display = 'none';
    }

    function generateRoute() {
        if (selectedPatientsForRoute.length === 0) {
            alert('Veuillez sélectionner au moins un patient.');
            return;
        }

        var patientsWithDistance = selectedPatientsForRoute.map(function(p) {
            var dist = calculateDistance(cabinetLat, cabinetLon, p.lat, p.lon);
            return { patient: p, distance: dist };
        });

        patientsWithDistance.sort(function(a, b) {
            return a.distance - b.distance;
        });

        var stepsHtml = '';
        var totalDistance = 0;

        for (var i = 0; i < patientsWithDistance.length; i++) {
            var p = patientsWithDistance[i];
            stepsHtml += '<li>' + p.patient.nom + ' - ' + p.distance.toFixed(1) + ' km</li>';
            totalDistance += p.distance;
        }

        document.getElementById('routeSteps').innerHTML = stepsHtml;
        document.getElementById('totalDistance').innerHTML = totalDistance.toFixed(1) + ' km';
        document.getElementById('routeResult').style.display = 'block';

        var waypoints = '';
        for (var i = 0; i < patientsWithDistance.length; i++) {
            waypoints += '/' + patientsWithDistance[i].patient.lat + ',' + patientsWithDistance[i].patient.lon;
        }
        var mapsUrl = 'https://www.google.com/maps/dir/' + cabinetLat + ',' + cabinetLon + waypoints;
        document.getElementById('openGoogleMapsBtn').href = mapsUrl;
    }

    document.getElementById('centerOnCabinetBtn').addEventListener('click', centerOnCabinet);
    document.getElementById('resetViewBtn').addEventListener('click', resetView);
    document.getElementById('planRouteBtn').addEventListener('click', showRoutePlanner);
    document.getElementById('cancelRouteBtn').addEventListener('click', hideRoutePlanner);
    document.getElementById('generateRouteBtn').addEventListener('click', generateRoute);

    document.addEventListener('DOMContentLoaded', function() {
        addCabinetMarker();
        addPatientMarkers();
        displayPatientsList();
        centerOnCabinet();
    });
</script>

</body>
</html>