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
            background: white;
            border-radius: 12px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            transition: transform 0.2s;
            cursor: pointer;
        }
        .doctor-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.15);
        }
        .doctor-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            object-fit: cover;
            background: #e9ecef;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .doctor-avatar i {
            font-size: 24px;
            color: #1a73e8;
        }
        .distance-badge {
            background: #1a73e8;
            color: white;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            display: inline-block;
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
            background: white;
        }
        .btn-outline-primary:hover {
            background: #1a73e8;
            color: white;
        }
        .search-box {
            background: white;
            padding: 15px;
            border-radius: 12px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .custom-marker {
            background: #1a73e8;
            border: 2px solid white;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 12px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            cursor: pointer;
        }
        .custom-marker:hover {
            transform: scale(1.1);
            background: #0d47a1;
        }
        .leaflet-popup-content {
            min-width: 200px;
        }
        .leaflet-popup-content .btn {
            display: inline-block;
            margin-top: 8px;
        }
        @media (max-width: 768px) {
            #map {
                height: 350px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="card">
        <h2 class="card-title">
            <i class="fas fa-map-marker-alt"></i> Carte des médecins
        </h2>
        
        <!-- Barre de recherche -->
        <div class="search-box">
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                <div style="flex: 2;">
                    <input type="text" id="locationInput" 
                           placeholder="Entrez votre adresse ou ville..." 
                           style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px;">
                </div>
                <div style="flex: 1;">
                    <select id="specialiteFilter" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px;">
                        <option value="">Toutes spécialités</option>
                        <c:forEach var="sp" items="${specialites}">
                            <option value="${sp}">${sp}</option>
                        </c:forEach>
                    </select>
                </div>
                <button id="searchNearbyBtn" class="btn btn-primary">
                    <i class="fas fa-search-location"></i> Médecins à proximité
                </button>
                <button id="useCurrentLocationBtn" class="btn btn-secondary">
                    <i class="fas fa-location-dot"></i> Ma position
                </button>
            </div>
        </div>
        
        <!-- Carte -->
        <div id="map"></div>
        
        <!-- Résultats à proximité -->
        <h3><i class="fas fa-chart-line"></i> Médecins à proximité</h3>
        <div id="nearbyDoctors" style="max-height: 400px; overflow-y: auto;">
            <div style="text-align: center; padding: 40px; color: #666;">
                <i class="fas fa-map-marker-alt" style="font-size: 48px; margin-bottom: 10px;"></i>
                <p>Cliquez sur "Médecins à proximité" ou sur un marqueur pour voir les médecins près de vous.</p>
            </div>
        </div>
    </div>
</div>

<script>
    // Initialisation de la carte (centre sur Antananarivo par défaut)
    var map = L.map('map').setView([-18.8792, 47.5079], 13);
    
    // Tuile OpenStreetMap
    L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>',
        subdomains: 'abcd',
        maxZoom: 19
    }).addTo(map);
    
    var markers = {};
    var currentPositionMarker = null;
    var doctors = [];
    
    // Récupérer les médecins depuis la BDD - version sans fn:replace
    <c:forEach var="m" items="${medecins}">
    <c:set var="nomEscaped">${fn:escapeXml(m.nommed)}</c:set>
    <c:set var="specialiteEscaped">${fn:escapeXml(m.specialite)}</c:set>
    <c:set var="lieuEscaped">${fn:escapeXml(m.lieu)}</c:set>
    <c:set var="adresseValue">${m.adresse != null ? m.adresse : m.lieu}</c:set>
    <c:set var="adresseEscaped">${fn:escapeXml(adresseValue)}</c:set>
    doctors.push({
        id: '${m.idmed}',
        nom: '${nomEscaped}',
        specialite: '${specialiteEscaped}',
        lieu: '${lieuEscaped}',
        tauxHoraire: ${m.tauxHoraire},
        latitude: ${m.latitude},
        longitude: ${m.longitude},
        adresse: '${adresseEscaped}',
        photo: '${m.photoProfile != null ? m.photoProfile : ""}',
        telephone: '${m.telephone != null ? m.telephone : ""}'
    });
    </c:forEach>
    
    // Ajouter les marqueurs sur la carte
    function addMarkers(filterSpecialite) {
        // Supprimer les marqueurs existants
        for (var id in markers) {
            map.removeLayer(markers[id]);
        }
        markers = {};
        
        var filteredDoctors = doctors;
        if (filterSpecialite && filterSpecialite !== '') {
            filteredDoctors = doctors.filter(function(d) {
                return d.specialite === filterSpecialite;
            });
        }
        
        filteredDoctors.forEach(function(doctor) {
            var customIcon = L.divIcon({
                className: 'custom-marker',
                html: '<i class="fas fa-user-md" style="font-size: 14px;"></i>',
                iconSize: [30, 30],
                popupAnchor: [0, -15]
            });
            
            var marker = L.marker([doctor.latitude, doctor.longitude], { icon: customIcon }).addTo(map);
            markers[doctor.id] = marker;
            
            // Contenu du popup
            var photoHtml = doctor.photo ? 
                '<img src="' + doctor.photo + '" style="width: 50px; height: 50px; border-radius: 50%; object-fit: cover; float: left; margin-right: 10px;">' : 
                '<div style="width: 50px; height: 50px; background: #e9ecef; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; float: left; margin-right: 10px;"><i class="fas fa-user-md" style="font-size: 20px; color: #1a73e8;"></i></div>';
            
            var popupContent = 
                '<div style="min-width: 200px;">' +
                photoHtml +
                '<div style="margin-left: 60px;">' +
                '<strong>Dr. ' + doctor.nom + '</strong><br>' +
                '<span style="color: #1a73e8;">' + doctor.specialite + '</span><br>' +
                '<i class="fas fa-map-marker-alt"></i> ' + doctor.lieu + '<br>' +
                '<i class="fas fa-money-bill-wave"></i> ' + doctor.tauxHoraire + ' Ar/h<br>' +
                '<div style="margin-top: 10px;">' +
                '<a href="${pageContext.request.contextPath}/medecin?action=profile&id=' + doctor.id + '" class="btn btn-sm btn-outline-primary" style="margin-right: 5px;"><i class="fas fa-user-md"></i> Profil</a>' +
                '<a href="${pageContext.request.contextPath}/rdv?action=form&idmed=' + doctor.id + '" class="btn btn-sm" style="background: #34a853; color: white;"><i class="fas fa-calendar-plus"></i> RDV</a>' +
                '</div>' +
                '</div>' +
                '</div>';
            
            marker.bindPopup(popupContent);
            
            marker.on('click', function() {
                showNearbyDoctors(doctor.latitude, doctor.longitude);
            });
        });
    }
    
    // Afficher les médecins à proximité
    function showNearbyDoctors(lat, lon) {
        var nearbyDiv = document.getElementById('nearbyDoctors');
        nearbyDiv.innerHTML = '<div style="text-align: center; padding: 20px;"><i class="fas fa-spinner fa-spin"></i> Chargement...</div>';
        
        // Calculer les distances et trier
        var doctorsWithDistance = doctors.map(function(doctor) {
            var distance = calculateDistance(lat, lon, doctor.latitude, doctor.longitude);
            return {
                doctor: doctor,
                distance: distance
            };
        });
        
        doctorsWithDistance.sort(function(a, b) {
            return a.distance - b.distance;
        });
        
        // Afficher les 10 plus proches
        var html = '';
        var count = 0;
        for (var i = 0; i < doctorsWithDistance.length && count < 10; i++) {
            var item = doctorsWithDistance[i];
            var doctor = item.doctor;
            var distance = item.distance;
            
            var distanceText = distance < 1 ? 
                (distance * 1000).toFixed(0) + ' m' : 
                distance.toFixed(1) + ' km';
            
            var photoHtml = doctor.photo ? 
                '<img src="' + doctor.photo + '" style="width: 50px; height: 50px; border-radius: 50%; object-fit: cover;">' : 
                '<div style="width: 50px; height: 50px; background: #e9ecef; border-radius: 50%; display: flex; align-items: center; justify-content: center;"><i class="fas fa-user-md" style="font-size: 20px; color: #1a73e8;"></i></div>';
            
            html += 
                '<div class="doctor-card" onclick="centerOnDoctor(' + doctor.latitude + ', ' + doctor.longitude + ')">' +
                '<div style="display: flex; gap: 15px; align-items: center;">' +
                '<div class="doctor-avatar">' + photoHtml + '</div>' +
                '<div style="flex: 1;">' +
                '<strong>Dr. ' + doctor.nom + '</strong><br>' +
                '<span style="color: #1a73e8;">' + doctor.specialite + '</span><br>' +
                '<i class="fas fa-map-marker-alt"></i> ' + doctor.lieu +
                '</div>' +
                '<div style="text-align: right;">' +
                '<span class="distance-badge"><i class="fas fa-location-dot"></i> ' + distanceText + '</span><br>' +
                '<div style="margin-top: 8px;">' +
                '<a href="${pageContext.request.contextPath}/medecin?action=profile&id=' + doctor.id + '" class="btn-sm" style="background: #1a73e8; color: white; text-decoration: none; padding: 4px 8px; border-radius: 4px;"><i class="fas fa-user-md"></i> Profil</a> ' +
                '<a href="${pageContext.request.contextPath}/rdv?action=form&idmed=' + doctor.id + '" class="btn-sm" style="background: #34a853; color: white; text-decoration: none; padding: 4px 8px; border-radius: 4px;"><i class="fas fa-calendar-plus"></i> RDV</a>' +
                '</div>' +
                '</div>' +
                '</div>' +
                '</div>';
            count++;
        }
        
        if (count === 0) {
            html = '<div style="text-align: center; padding: 40px; color: #666;">Aucun médecin trouvé à proximité.</div>';
        }
        
        nearbyDiv.innerHTML = html;
        
        // Centrer la carte sur la position
        map.setView([lat, lon], 13);
        
        // Ajouter un marqueur pour la position actuelle
        if (currentPositionMarker) {
            map.removeLayer(currentPositionMarker);
        }
        
        var currentIcon = L.divIcon({
            className: 'custom-marker',
            html: '<i class="fas fa-location-dot" style="font-size: 14px; color: white;"></i>',
            iconSize: [30, 30],
            popupAnchor: [0, -15]
        });
        
        currentPositionMarker = L.marker([lat, lon], { icon: currentIcon }).addTo(map);
        currentPositionMarker.bindPopup('<strong>Votre position</strong>').openPopup();
    }
    
    // Calculer la distance entre deux points (Haversine)
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
    
    // Centrer la carte sur un médecin
    function centerOnDoctor(lat, lon) {
        map.setView([lat, lon], 16);
    }
    
    // Utiliser la position actuelle du navigateur
    function useCurrentLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {
                var lat = position.coords.latitude;
                var lon = position.coords.longitude;
                showNearbyDoctors(lat, lon);
            }, function(error) {
                alert("Impossible d'obtenir votre position. Veuillez activer la geolocalisation.");
            });
        } else {
            alert("Votre navigateur ne supporte pas la geolocalisation.");
        }
    }
    
    // Rechercher par adresse
    function searchByAddress() {
        var address = document.getElementById('locationInput').value;
        if (!address.trim()) {
            alert("Veuillez entrer une adresse.");
            return;
        }
        
        // Utiliser Nominatim pour géocoder
        var url = 'https://nominatim.openstreetmap.org/search?q=' + encodeURIComponent(address) + '&format=json&limit=1';
        
        document.getElementById('nearbyDoctors').innerHTML = '<div style="text-align: center; padding: 20px;"><i class="fas fa-spinner fa-spin"></i> Recherche de l\'adresse...</div>';
        
        fetch(url, {
            headers: {
                'User-Agent': 'RDV Medical App/1.0'
            }
        })
        .then(function(response) {
            return response.json();
        })
        .then(function(data) {
            if (data && data.length > 0) {
                var lat = parseFloat(data[0].lat);
                var lon = parseFloat(data[0].lon);
                showNearbyDoctors(lat, lon);
            } else {
                document.getElementById('nearbyDoctors').innerHTML = '<div style="text-align: center; padding: 20px; color: #666;">Adresse non trouvée. Veuillez essayer autre chose.</div>';
            }
        })
        .catch(function(error) {
            console.error('Erreur:', error);
            document.getElementById('nearbyDoctors').innerHTML = '<div style="text-align: center; padding: 20px; color: #666;">Erreur lors de la recherche.</div>';
        });
    }
    
    // Initialisation
    document.addEventListener('DOMContentLoaded', function() {
        addMarkers('');
        
        document.getElementById('searchNearbyBtn').addEventListener('click', searchByAddress);
        document.getElementById('useCurrentLocationBtn').addEventListener('click', useCurrentLocation);
        
        document.getElementById('specialiteFilter').addEventListener('change', function() {
            addMarkers(this.value);
        });
        
        // Si l'utilisateur a une position, la demander
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {
                // Optionnel : afficher les médecins proches automatiquement
                // showNearbyDoctors(position.coords.latitude, position.coords.longitude);
            }, function() {});
        }
    });
</script>

</body>
</html>