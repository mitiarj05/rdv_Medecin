package com.rdv.model;

import java.time.LocalDate;

public class Patient {

    private String    idpat;
    private String    nomPat;
    private LocalDate datenais;
    private String    email;
    private String    telephone;  // NOUVEAU
    private String    motDePasse;

    // ── Constructeurs ────────────────────────────────────────────────────────

    public Patient() {}

    public Patient(String idpat, String nomPat, LocalDate datenais, String email, String telephone) {
        this.idpat     = idpat;
        this.nomPat    = nomPat;
        this.datenais  = datenais;
        this.email     = email;
        this.telephone = telephone;
    }

    public Patient(String idpat, String nomPat, LocalDate datenais,
                   String email, String telephone, String motDePasse) {
        this.idpat       = idpat;
        this.nomPat      = nomPat;
        this.datenais    = datenais;
        this.email       = email;
        this.telephone   = telephone;
        this.motDePasse  = motDePasse;
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

    @Override
    public String toString() {
        return "Patient{" +
                "idpat='"   + idpat   + '\'' +
                ", nomPat='" + nomPat  + '\'' +
                ", email='"  + email   + '\'' +
                ", telephone='" + telephone + '\'' +
                '}';
    }
}