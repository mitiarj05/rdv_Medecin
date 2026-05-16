package com.rdv.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Service de géocodage utilisant Nominatim (OpenStreetMap)
 * Gratuit, sans clé API, mais avec limitation de 1 requête/seconde
 */
public class GeocodeService {

    private static final String NOMINATIM_URL = "https://nominatim.openstreetmap.org/search";
    private static final String REVERSE_URL = "https://nominatim.openstreetmap.org/reverse";
    
    /**
     * Convertit une adresse en coordonnées GPS
     * @param adresse Adresse complète (ex: "Antananarivo, Madagascar")
     * @return Tableau [latitude, longitude] ou null si non trouvé
     */
    public static double[] adresseVersCoordonnees(String adresse) {
        if (adresse == null || adresse.trim().isEmpty()) {
            return null;
        }
        
        try {
            String encodedAdresse = URLEncoder.encode(adresse, "UTF-8");
            String urlStr = NOMINATIM_URL + "?q=" + encodedAdresse + "&format=json&limit=1";
            
            URL url = new URL(urlStr);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("User-Agent", "RDV Medical App/1.0");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            
            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                reader.close();
                
                JSONArray results = new JSONArray(response.toString());
                if (results.length() > 0) {
                    JSONObject first = results.getJSONObject(0);
                    double lat = first.getDouble("lat");
                    double lon = first.getDouble("lon");
                    return new double[]{lat, lon};
                }
            }
            conn.disconnect();
        } catch (Exception e) {
            System.err.println("[GeocodeService] Erreur géocodage: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Convertit des coordonnées GPS en adresse
     * @param latitude Latitude
     * @param longitude Longitude
     * @return Adresse formatée ou null
     */
    public static String coordonneesVersAdresse(double latitude, double longitude) {
        try {
            String urlStr = REVERSE_URL + "?lat=" + latitude + "&lon=" + longitude + "&format=json";
            
            URL url = new URL(urlStr);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("User-Agent", "RDV Medical App/1.0");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            
            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                reader.close();
                
                JSONObject result = new JSONObject(response.toString());
                if (result.has("display_name")) {
                    return result.getString("display_name");
                }
            }
            conn.disconnect();
        } catch (Exception e) {
            System.err.println("[GeocodeService] Erreur reverse géocodage: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Valide et corrige une adresse
     */
    public static String validerAdresse(String adresse) {
        double[] coords = adresseVersCoordonnees(adresse);
        if (coords != null) {
            return coordonneesVersAdresse(coords[0], coords[1]);
        }
        return null;
    }
}