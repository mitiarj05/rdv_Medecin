package com.rdv.model;

import java.time.LocalDate;

public class Patient {

    private String    idpat;
    private String    nomPat;
    private LocalDate datenais;
    private String    email;
    private String    telephone;
    private String    motDePasse;

    // Langue préférée du patient
    private String    langue;

    // NOUVEAUX CHAMPS POUR GÉOLOCALISATION
    private Double    latitude;
    private Double    longitude;
    private String    adresse;

    // ── Constructeurs ────────────────────────────────────────────────────────

    public Patient() {
        this.langue = "fr";
    }

    public Patient(String idpat, String nomPat, LocalDate datenais, String email, String telephone) {
        this.idpat     = idpat;
        this.nomPat    = nomPat;
        this.datenais  = datenais;
        this.email     = email;
        this.telephone = telephone;
        this.langue    = "fr";
    }

    public Patient(String idpat, String nomPat, LocalDate datenais,
                   String email, String telephone, String motDePasse) {
        this.idpat       = idpat;
        this.nomPat      = nomPat;
        this.datenais    = datenais;
        this.email       = email;
        this.telephone   = telephone;
        this.motDePasse  = motDePasse;
        this.langue      = "fr";
    }

    public Patient(String idpat, String nomPat, LocalDate datenais,
                   String email, String telephone, String motDePasse, String langue,
                   Double latitude, Double longitude, String adresse) {
        this.idpat       = idpat;
        this.nomPat      = nomPat;
        this.datenais    = datenais;
        this.email       = email;
        this.telephone   = telephone;
        this.motDePasse  = motDePasse;
        this.langue      = langue != null ? langue : "fr";
        this.latitude    = latitude;
        this.longitude   = longitude;
        this.adresse     = adresse;
    }

    // ── Getters & Setters ────────────────────────────────────────────────────

    public String getIdpat() { return idpat; }
    public void setIdpat(String idpat) { this.idpat = idpat; }

    public String getNomPat() { return nomPat; }
    public void setNomPat(String nomPat) { this.nomPat = nomPat; }

    public LocalDate getDatenais() { return datenais; }
    public void setDatenais(LocalDate datenais) { this.datenais = datenais; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }

    public String getMotDePasse() { return motDePasse; }
    public void setMotDePasse(String motDePasse) { this.motDePasse = motDePasse; }

    public String getLangue() { return langue; }
    public void setLangue(String langue) { this.langue = langue; }

    // NOUVEAUX GETTERS/SETTERS
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }

    public boolean hasCoordinates() {
        return latitude != null && longitude != null;
    }

    @Override
    public String toString() {
        return "Patient{" +
                "idpat='"   + idpat   + '\'' +
                ", nomPat='" + nomPat  + '\'' +
                ", email='"  + email   + '\'' +
                ", telephone='" + telephone + '\'' +
                ", langue='" + langue + '\'' +
                '}';
    }
}