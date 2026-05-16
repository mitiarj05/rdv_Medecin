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
    
    // NOUVEAU : Photo de profil
    private String photoProfile;

    // ── Constructeurs ────────────────────────────────────────────────────────

    public Medecin() {}

    public Medecin(String idmed, String nommed, String specialite,
                   int tauxHoraire, String lieu, String email, String telephone) {
        this.idmed       = idmed;
        this.nommed      = nommed;
        this.specialite  = specialite;
        this.tauxHoraire = tauxHoraire;
        this.lieu        = lieu;
        this.email       = email;
        this.telephone   = telephone;
    }

    public Medecin(String idmed, String nommed, String specialite,
                   int tauxHoraire, String lieu, String email, String telephone, 
                   String bio, String diplomes, String experience, String photoProfile) {
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
    }

    public Medecin(String idmed, String nommed, String specialite,
                   int tauxHoraire, String lieu, String email, String telephone, 
                   String motDePasse, String bio, String diplomes, String experience, String photoProfile) {
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

    // NOUVEAU
    public String getPhotoProfile() { return photoProfile; }
    public void setPhotoProfile(String photoProfile) { this.photoProfile = photoProfile; }
    
    // Méthode utilitaire pour vérifier si une photo existe
    public boolean hasPhoto() {
        return photoProfile != null && !photoProfile.trim().isEmpty();
    }

    // ── Méthodes utilitaires ─────────────────────────────────────────────────
    
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

    @Override
    public String toString() {
        return "Medecin{" +
                "idmed='"      + idmed      + '\'' +
                ", nommed='"   + nommed     + '\'' +
                ", specialite='" + specialite + '\'' +
                ", lieu='"     + lieu       + '\'' +
                ", email='"    + email      + '\'' +
                ", telephone='" + telephone + '\'' +
                '}';
    }
}