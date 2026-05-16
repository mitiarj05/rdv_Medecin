package com.rdv.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Message {
    
    private String idMessage;
    private String idExpediteur;
    private String typeExpediteur;
    private String idDestinataire;
    private String typeDestinataire;
    private String contenu;
    private LocalDateTime dateEnvoi;
    private boolean lu;
    private LocalDateTime dateLu;
    private boolean supprimeExpediteur;
    private boolean supprimeDestinataire;
    
    // NOUVEAUX CHAMPS POUR PIÈCES JOINTES
    private String pieceJointe;
    private String typePiece;
    
    // Objets associés pour l'affichage
    private String nomExpediteur;
    private String nomDestinataire;
    
    // Constructeurs
    public Message() {}
    
    public Message(String idExpediteur, String typeExpediteur, 
                   String idDestinataire, String typeDestinataire, 
                   String contenu) {
        this.idExpediteur = idExpediteur;
        this.typeExpediteur = typeExpediteur;
        this.idDestinataire = idDestinataire;
        this.typeDestinataire = typeDestinataire;
        this.contenu = contenu;
        this.dateEnvoi = LocalDateTime.now();
        this.lu = false;
    }
    
    // Getters et Setters
    public String getIdMessage() { return idMessage; }
    public void setIdMessage(String idMessage) { this.idMessage = idMessage; }
    
    public String getIdExpediteur() { return idExpediteur; }
    public void setIdExpediteur(String idExpediteur) { this.idExpediteur = idExpediteur; }
    
    public String getTypeExpediteur() { return typeExpediteur; }
    public void setTypeExpediteur(String typeExpediteur) { this.typeExpediteur = typeExpediteur; }
    
    public String getIdDestinataire() { return idDestinataire; }
    public void setIdDestinataire(String idDestinataire) { this.idDestinataire = idDestinataire; }
    
    public String getTypeDestinataire() { return typeDestinataire; }
    public void setTypeDestinataire(String typeDestinataire) { this.typeDestinataire = typeDestinataire; }
    
    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }
    
    public LocalDateTime getDateEnvoi() { return dateEnvoi; }
    public void setDateEnvoi(LocalDateTime dateEnvoi) { this.dateEnvoi = dateEnvoi; }
    
    public String getDateEnvoiFormatee() {
        if (dateEnvoi == null) return "";
        return dateEnvoi.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
    
    public boolean isLu() { return lu; }
    public void setLu(boolean lu) { this.lu = lu; }
    
    public LocalDateTime getDateLu() { return dateLu; }
    public void setDateLu(LocalDateTime dateLu) { this.dateLu = dateLu; }
    
    public boolean isSupprimeExpediteur() { return supprimeExpediteur; }
    public void setSupprimeExpediteur(boolean supprimeExpediteur) { this.supprimeExpediteur = supprimeExpediteur; }
    
    public boolean isSupprimeDestinataire() { return supprimeDestinataire; }
    public void setSupprimeDestinataire(boolean supprimeDestinataire) { this.supprimeDestinataire = supprimeDestinataire; }
    
    // NOUVEAUX GETTERS/SETTERS
    public String getPieceJointe() { return pieceJointe; }
    public void setPieceJointe(String pieceJointe) { this.pieceJointe = pieceJointe; }
    
    public String getTypePiece() { return typePiece; }
    public void setTypePiece(String typePiece) { this.typePiece = typePiece; }
    
    public boolean hasPieceJointe() {
        return pieceJointe != null && !pieceJointe.trim().isEmpty();
    }
    
    public boolean isImage() {
        return "image".equals(typePiece);
    }
    
    public boolean isAudio() {
        return "audio".equals(typePiece);
    }
    
    public String getNomExpediteur() { return nomExpediteur; }
    public void setNomExpediteur(String nomExpediteur) { this.nomExpediteur = nomExpediteur; }
    
    public String getNomDestinataire() { return nomDestinataire; }
    public void setNomDestinataire(String nomDestinataire) { this.nomDestinataire = nomDestinataire; }
}