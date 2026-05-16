package com.rdv.service;

import java.util.List;

import com.rdv.dao.AvisDAO;
import com.rdv.model.Avis;

public class AvisService {
    
    private final AvisDAO avisDAO = new AvisDAO();
    
    public boolean donnerAvis(String idPatient, String idMedecin, int note, String commentaire) {
        if (note < 1 || note > 5) return false;
        if (commentaire == null || commentaire.trim().isEmpty()) return false;
        
        // Vérifier si le patient a déjà donné un avis
        if (avisDAO.aDejaNote(idPatient, idMedecin)) {
            return false;
        }
        
        Avis avis = new Avis(idPatient, idMedecin, note, commentaire);
        return avisDAO.inserer(avis);
    }
    
    public boolean modifierAvis(String idAvis, int note, String commentaire) {
        Avis avis = new Avis();
        avis.setIdAvis(idAvis);
        avis.setNote(note);
        avis.setCommentaire(commentaire);
        return avisDAO.modifier(avis);
    }
    
    public boolean repondreAvis(String idAvis, String reponse) {
        return avisDAO.repondre(idAvis, reponse);
    }
    
    public boolean supprimerAvis(String idAvis) {
        return avisDAO.supprimer(idAvis);
    }
    
    public List<Avis> getAvisPourMedecin(String idMedecin) {
        return avisDAO.listerParMedecin(idMedecin);
    }
    
    public List<Avis> getAvisPourPatient(String idPatient) {
        return avisDAO.listerParPatient(idPatient);
    }
    
    public Avis getAvisPatientMedecin(String idPatient, String idMedecin) {
        return avisDAO.trouverParPatientEtMedecin(idPatient, idMedecin);
    }
    
    public double getNoteMoyenne(String idMedecin) {
        return avisDAO.getNoteMoyenne(idMedecin);
    }
    
    public int getNombreAvis(String idMedecin) {
        return avisDAO.countByMedecin(idMedecin);
    }
    
    public boolean aDejaNote(String idPatient, String idMedecin) {
        return avisDAO.aDejaNote(idPatient, idMedecin);
    }
}