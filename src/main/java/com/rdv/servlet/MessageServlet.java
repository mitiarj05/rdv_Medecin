package com.rdv.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

import org.json.JSONArray;
import org.json.JSONObject;

import com.rdv.model.Message;
import com.rdv.service.MessageService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/message")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 1024 * 1024 * 10,       // 10 MB
    maxRequestSize = 1024 * 1024 * 20     // 20 MB
)
public class MessageServlet extends HttpServlet {
    
    private final MessageService messageService = new MessageService();
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"success\": false, \"message\": \"Non authentifié\"}");
            return;
        }
        
        String action = req.getParameter("action");
        String role = (String) session.getAttribute("role");
        String idUtilisateur = (String) session.getAttribute("idUtilisateur");
        String typeUtilisateur = role;
        
        PrintWriter out = resp.getWriter();
        JSONObject json = new JSONObject();
        
        // NOUVEAU : Envoyer un message avec fichier
        if ("envoyerFichier".equals(action)) {
            String idDestinataire = req.getParameter("idDestinataire");
            String typeDestinataire = req.getParameter("typeDestinataire");
            String contenu = req.getParameter("contenu");
            Part filePart = req.getPart("fichier");
            
            if (filePart == null || filePart.getSize() == 0) {
                json.put("success", false);
                json.put("message", "Aucun fichier sélectionné");
                out.write(json.toString());
                return;
            }
            
            // Lire le fichier et le convertir en Base64
            byte[] fileBytes = filePart.getInputStream().readAllBytes();
            String base64 = Base64.getEncoder().encodeToString(fileBytes);
            String contentType = filePart.getContentType();
            String typePiece = contentType.startsWith("image/") ? "image" : "audio";
            String dataUrl = "data:" + contentType + ";base64," + base64;
            
            boolean success = messageService.envoyerMessageAvecPiece(
                idUtilisateur, typeUtilisateur,
                idDestinataire, typeDestinataire,
                contenu != null ? contenu : "",
                dataUrl, typePiece
            );
            
            json.put("success", success);
            json.put("message", success ? "Message envoyé" : "Erreur");
            out.write(json.toString());
            
        } else if ("envoyer".equals(action)) {
            String idDestinataire = req.getParameter("idDestinataire");
            String typeDestinataire = req.getParameter("typeDestinataire");
            String contenu = req.getParameter("contenu");
            
            boolean success = messageService.envoyerMessage(
                idUtilisateur, typeUtilisateur,
                idDestinataire, typeDestinataire,
                contenu
            );
            
            json.put("success", success);
            json.put("message", success ? "Message envoyé" : "Erreur");
            out.write(json.toString());
            
        } else if ("supprimer".equals(action)) {
            String idMessage = req.getParameter("idMessage");
            boolean success = messageService.supprimerMessage(idMessage, idUtilisateur, typeUtilisateur);
            
            json.put("success", success);
            out.write(json.toString());
            
        } else if ("supprimerDefinitivement".equals(action)) {
            // Seul l'admin peut supprimer définitivement
            if (!"admin".equals(role)) {
                json.put("success", false);
                json.put("message", "Non autorisé");
                out.write(json.toString());
                return;
            }
            String idMessage = req.getParameter("idMessage");
            boolean success = messageService.supprimerDefinitivement(idMessage);
            
            json.put("success", success);
            out.write(json.toString());
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"success\": false, \"message\": \"Non authentifié\"}");
            return;
        }
        
        String action = req.getParameter("action");
        String role = (String) session.getAttribute("role");
        String idUtilisateur = (String) session.getAttribute("idUtilisateur");
        String typeUtilisateur = role;
        
        PrintWriter out = resp.getWriter();
        JSONObject json = new JSONObject();
        
        if ("conversation".equals(action)) {
            String idAutre = req.getParameter("idAutre");
            String typeAutre = req.getParameter("typeAutre");
            
            List<Message> messages = messageService.getConversation(
                idUtilisateur, typeUtilisateur,
                idAutre, typeAutre
            );
            
            for (Message m : messages) {
                if (m.getIdDestinataire().equals(idUtilisateur) && 
                    m.getTypeDestinataire().equals(typeUtilisateur) &&
                    !m.isLu()) {
                    messageService.marquerCommeLu(m.getIdMessage());
                }
            }
            
            JSONArray messagesArray = new JSONArray();
            for (Message m : messages) {
                JSONObject msg = new JSONObject();
                msg.put("id", m.getIdMessage());
                msg.put("contenu", m.getContenu());
                msg.put("date", m.getDateEnvoiFormatee());
                msg.put("estMoi", m.getIdExpediteur().equals(idUtilisateur));
                msg.put("lu", m.isLu());
                msg.put("pieceJointe", m.getPieceJointe() != null ? m.getPieceJointe() : "");
                msg.put("typePiece", m.getTypePiece() != null ? m.getTypePiece() : "");
                messagesArray.put(msg);
            }
            
            json.put("success", true);
            json.put("messages", messagesArray);
            out.write(json.toString());
            
        } else if ("liste".equals(action)) {
            List<Message> messages = messageService.getMessagesPourUtilisateur(idUtilisateur, typeUtilisateur);
            int nonLus = messageService.getNombreNonLus(idUtilisateur, typeUtilisateur);
            
            JSONArray messagesArray = new JSONArray();
            for (Message m : messages) {
                JSONObject msg = new JSONObject();
                msg.put("id", m.getIdMessage());
                msg.put("contenu", m.getContenu());
                msg.put("date", m.getDateEnvoiFormatee());
                msg.put("idExpediteur", m.getIdExpediteur());
                msg.put("idDestinataire", m.getIdDestinataire());
                msg.put("typeExpediteur", m.getTypeExpediteur());
                msg.put("typeDestinataire", m.getTypeDestinataire());
                msg.put("nomExpediteur", m.getNomExpediteur());
                msg.put("nomDestinataire", m.getNomDestinataire());
                msg.put("lu", m.isLu());
                messagesArray.put(msg);
            }
            
            json.put("success", true);
            json.put("nonLus", nonLus);
            json.put("messages", messagesArray);
            out.write(json.toString());
            
        } else if ("nonLus".equals(action)) {
            int nonLus = messageService.getNombreNonLus(idUtilisateur, typeUtilisateur);
            json.put("nonLus", nonLus);
            out.write(json.toString());
        }
    }
}