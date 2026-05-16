package com.rdv.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Avis {
    
    private String idAvis;
    private String idPatient;
    private String idMedecin;
    private int note;
    private String commentaire;
    private LocalDateTime dateAvis;
    private String reponseMedecin;
    private LocalDateTime dateReponse;
    
    // Objets associés pour l'affichage
    private Patient patient;
    private Medecin medecin;
    
    // Constructeurs
    public Avis() {}
    
    public Avis(String idPatient, String idMedecin, int note, String commentaire) {
        this.idPatient = idPatient;
        this.idMedecin = idMedecin;
        this.note = note;
        this.commentaire = commentaire;
        this.dateAvis = LocalDateTime.now();
    }
    
    // Getters et Setters
    public String getIdAvis() { return idAvis; }
    public void setIdAvis(String idAvis) { this.idAvis = idAvis; }
    
    public String getIdPatient() { return idPatient; }
    public void setIdPatient(String idPatient) { this.idPatient = idPatient; }
    
    public String getIdMedecin() { return idMedecin; }
    public void setIdMedecin(String idMedecin) { this.idMedecin = idMedecin; }
    
    public int getNote() { return note; }
    public void setNote(int note) { this.note = note; }
    
    public String getCommentaire() { return commentaire; }
    public void setCommentaire(String commentaire) { this.commentaire = commentaire; }
    
    public LocalDateTime getDateAvis() { return dateAvis; }
    public void setDateAvis(LocalDateTime dateAvis) { this.dateAvis = dateAvis; }
    
    public String getDateAvisFormatee() {
        if (dateAvis == null) return "";
        return dateAvis.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
    
    public String getReponseMedecin() { return reponseMedecin; }
    public void setReponseMedecin(String reponseMedecin) { this.reponseMedecin = reponseMedecin; }
    
    public LocalDateTime getDateReponse() { return dateReponse; }
    public void setDateReponse(LocalDateTime dateReponse) { this.dateReponse = dateReponse; }
    
    public String getDateReponseFormatee() {
        if (dateReponse == null) return "";
        return dateReponse.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
    
    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }
    
    public Medecin getMedecin() { return medecin; }
    public void setMedecin(Medecin medecin) { this.medecin = medecin; }
    
    public boolean hasReponse() {
        return reponseMedecin != null && !reponseMedecin.trim().isEmpty();
    }
}