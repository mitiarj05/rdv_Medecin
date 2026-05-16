package com.rdv.model;

public class Medecin {

    private String idmed;
    private String nommed;
    private String specialite;
    private int    tauxHoraire;
    private String lieu;
    private String email;
    private String telephone;
    private String motDePasse;
    
    // Profil détaillé
    private String bio;
    private String diplomes;
    private String experience;
    
    // Photo de profil
    private String photoProfile;
    
    // Géolocalisation
    private String adresse;
    private Double latitude;
    private Double longitude;
    
    // NOUVEAU : Langue préférée du médecin
    private String langue;

    // ── Constructeurs ────────────────────────────────────────────────────────

    public Medecin() {
        this.langue = "fr"; // Langue par défaut
    }

    public Medecin(String idmed, String nommed, String specialite,
                   int tauxHoraire, String lieu, String email, String telephone) {
        this.idmed       = idmed;
        this.nommed      = nommed;
        this.specialite  = specialite;
        this.tauxHoraire = tauxHoraire;
        this.lieu        = lieu;
        this.email       = email;
        this.telephone   = telephone;
        this.langue      = "fr";
    }

    public Medecin(String idmed, String nommed, String specialite,
                   int tauxHoraire, String lieu, String email, String telephone, 
                   String bio, String diplomes, String experience, String photoProfile,
                   String adresse, Double latitude, Double longitude) {
        this.idmed       = idmed;
        this.nommed      = nommed;
        this.specialite  = specialite;
        this.tauxHoraire = tauxHoraire;
        this.lieu        = lieu;
        this.email       = email;
        this.telephone   = telephone;
        this.bio         = bio;
        this.diplomes    = diplomes;
        this.experience  = experience;
        this.photoProfile = photoProfile;
        this.adresse     = adresse;
        this.latitude    = latitude;
        this.longitude   = longitude;
        this.langue      = "fr";
    }

    public Medecin(String idmed, String nommed, String specialite,
                   int tauxHoraire, String lieu, String email, String telephone, 
                   String motDePasse, String bio, String diplomes, String experience, 
                   String photoProfile, String adresse, Double latitude, Double longitude, 
                   String langue) {
        this.idmed       = idmed;
        this.nommed      = nommed;
        this.specialite  = specialite;
        this.tauxHoraire = tauxHoraire;
        this.lieu        = lieu;
        this.email       = email;
        this.telephone   = telephone;
        this.motDePasse  = motDePasse;
        this.bio         = bio;
        this.diplomes    = diplomes;
        this.experience  = experience;
        this.photoProfile = photoProfile;
        this.adresse     = adresse;
        this.latitude    = latitude;
        this.longitude   = longitude;
        this.langue      = langue != null ? langue : "fr";
    }

    // ── Getters & Setters ────────────────────────────────────────────────────

    public String getIdmed() { return idmed; }
    public void setIdmed(String idmed) { this.idmed = idmed; }

    public String getNommed() { return nommed; }
    public void setNommed(String nommed) { this.nommed = nommed; }

    public String getSpecialite() { return specialite; }
    public void setSpecialite(String specialite) { this.specialite = specialite; }

    public int getTauxHoraire() { return tauxHoraire; }
    public void setTauxHoraire(int tauxHoraire) { this.tauxHoraire = tauxHoraire; }

    public String getLieu() { return lieu; }
    public void setLieu(String lieu) { this.lieu = lieu; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }

    public String getMotDePasse() { return motDePasse; }
    public void setMotDePasse(String motDePasse) { this.motDePasse = motDePasse; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getDiplomes() { return diplomes; }
    public void setDiplomes(String diplomes) { this.diplomes = diplomes; }

    public String getExperience() { return experience; }
    public void setExperience(String experience) { this.experience = experience; }

    public String getPhotoProfile() { return photoProfile; }
    public void setPhotoProfile(String photoProfile) { this.photoProfile = photoProfile; }
    
    public boolean hasPhoto() {
        return photoProfile != null && !photoProfile.trim().isEmpty();
    }

    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    
    // NOUVEAU
    public String getLangue() { return langue; }
    public void setLangue(String langue) { this.langue = langue; }
    
    public boolean hasCoordinates() {
        return latitude != null && longitude != null;
    }
    
    public String getBioFormatee() {
        if (bio == null || bio.trim().isEmpty()) {
            return "Aucune biographie renseignée.";
        }
        return bio.trim();
    }
    
    public String getDiplomesFormatee() {
        if (diplomes == null || diplomes.trim().isEmpty()) {
            return "Aucun diplôme renseigné.";
        }
        return diplomes.trim();
    }
    
    public String getExperienceFormatee() {
        if (experience == null || experience.trim().isEmpty()) {
            return "Aucune expérience renseignée.";
        }
        return experience.trim();
    }

    public double distanceTo(double lat, double lon) {
        if (latitude == null || longitude == null) return Double.MAX_VALUE;
        final int R = 6371;
        double latDistance = Math.toRadians(lat - latitude);
        double lonDistance = Math.toRadians(lon - longitude);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2) +
                   Math.cos(Math.toRadians(latitude)) * Math.cos(Math.toRadians(lat)) *
                   Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    @Override
    public String toString() {
        return "Medecin{" +
                "idmed='"      + idmed      + '\'' +
                ", nommed='"   + nommed     + '\'' +
                ", specialite='" + specialite + '\'' +
                ", lieu='"     + lieu       + '\'' +
                ", email='"    + email      + '\'' +
                ", telephone='" + telephone + '\'' +
                ", langue='"   + langue     + '\'' +
                '}';
    }
}