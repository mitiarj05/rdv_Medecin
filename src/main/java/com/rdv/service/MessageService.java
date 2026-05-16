package com.rdv.service;

import java.util.List;

import com.rdv.dao.MessageDAO;
import com.rdv.model.Message;

public class MessageService {
    
    private final MessageDAO messageDAO = new MessageDAO();
    
    public boolean envoyerMessage(String idExpediteur, String typeExpediteur,
                                  String idDestinataire, String typeDestinataire,
                                  String contenu) {
        if (contenu == null || contenu.trim().isEmpty()) return false;
        
        Message message = new Message(idExpediteur, typeExpediteur, 
                                      idDestinataire, typeDestinataire, 
                                      contenu);
        return messageDAO.envoyer(message);
    }
    
    // NOUVEAU : Envoyer un message avec pièce jointe
    public boolean envoyerMessageAvecPiece(String idExpediteur, String typeExpediteur,
                                            String idDestinataire, String typeDestinataire,
                                            String contenu, String pieceJointe, String typePiece) {
        Message message = new Message(idExpediteur, typeExpediteur, 
                                      idDestinataire, typeDestinataire, 
                                      contenu != null ? contenu : "");
        message.setPieceJointe(pieceJointe);
        message.setTypePiece(typePiece);
        return messageDAO.envoyer(message);
    }
    
    public List<Message> getConversation(String idUser1, String typeUser1,
                                         String idUser2, String typeUser2) {
        return messageDAO.getConversation(idUser1, typeUser1, idUser2, typeUser2);
    }
    
    public List<Message> getMessagesPourUtilisateur(String idUtilisateur, String typeUtilisateur) {
        return messageDAO.getMessagesPourUtilisateur(idUtilisateur, typeUtilisateur);
    }
    
    public boolean marquerCommeLu(String idMessage) {
        return messageDAO.marquerCommeLu(idMessage);
    }
    
    public int getNombreNonLus(String idUtilisateur, String typeUtilisateur) {
        return messageDAO.countNonLus(idUtilisateur, typeUtilisateur);
    }
    
    public boolean supprimerMessage(String idMessage, String idUtilisateur, String typeUtilisateur) {
        return messageDAO.supprimerMessage(idMessage, idUtilisateur, typeUtilisateur);
    }
    
    // NOUVEAU : Supprimer définitivement un message (admin uniquement)
    public boolean supprimerDefinitivement(String idMessage) {
        return messageDAO.supprimerDefinitivement(idMessage);
    }
}