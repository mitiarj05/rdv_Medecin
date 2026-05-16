package com.rdv.servlet;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.UUID;

import com.rdv.model.Medecin;
import com.rdv.service.MedecinService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/upload-photo")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 1024 * 1024 * 5,        // 5 MB
    maxRequestSize = 1024 * 1024 * 10     // 10 MB
)
public class UploadPhotoServlet extends HttpServlet {

    private final MedecinService medecinService = new MedecinService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        String idMedecin = req.getParameter("idmed");
        
        // CORRECTION : Admin peut uploader pour n'importe quel médecin
        // Sinon, le médecin ne peut uploader que pour lui-même
        if ("admin".equals(role)) {
            // Admin : utiliser l'ID passé en paramètre
            if (idMedecin == null || idMedecin.isEmpty()) {
                session.setAttribute("erreurPhoto", "ID du médecin manquant.");
                resp.sendRedirect(req.getContextPath() + "/admin?action=editMedecin&id=" + idMedecin);
                return;
            }
        } else if ("medecin".equals(role)) {
            // Médecin : utiliser son propre ID
            idMedecin = (String) session.getAttribute("idUtilisateur");
            if (idMedecin == null) {
                resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
                return;
            }
        } else {
            // Autre rôle non autorisé
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        Part filePart = req.getPart("photo");
        if (filePart == null || filePart.getSize() == 0) {
            session.setAttribute("erreurPhoto", "Veuillez sélectionner une photo.");
            if ("admin".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/admin?action=editMedecin&id=" + idMedecin);
            } else {
                resp.sendRedirect(req.getContextPath() + "/medecin?action=edit&id=" + idMedecin);
            }
            return;
        }

        // Vérifier le type de fichier
        String contentType = filePart.getContentType();
        if (!contentType.startsWith("image/")) {
            session.setAttribute("erreurPhoto", "Le fichier doit être une image (JPG, PNG, GIF).");
            if ("admin".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/admin?action=editMedecin&id=" + idMedecin);
            } else {
                resp.sendRedirect(req.getContextPath() + "/medecin?action=edit&id=" + idMedecin);
            }
            return;
        }

        // Générer un nom de fichier unique
        String extension = "";
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        int dotIndex = fileName.lastIndexOf(".");
        if (dotIndex > 0) {
            extension = fileName.substring(dotIndex);
        }
        
        String uniqueFileName = UUID.randomUUID().toString() + extension;
        
        // Déterminer le chemin de sauvegarde
        String uploadPath = getServletContext().getRealPath("/") + "uploads" + File.separator + "medecins";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        String filePath = uploadPath + File.separator + uniqueFileName;
        filePart.write(filePath);
        
        // Chemin relatif pour la base de données et l'affichage
        String relativePath = req.getContextPath() + "/uploads/medecins/" + uniqueFileName;
        
        // Mettre à jour la base de données
        Medecin medecin = medecinService.trouverParId(idMedecin);
        if (medecin == null) {
            session.setAttribute("erreurPhoto", "Médecin non trouvé.");
            if ("admin".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/admin?action=medecins");
            } else {
                resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
            }
            return;
        }
        
        // Supprimer l'ancienne photo si elle existe
        String oldPhoto = medecin.getPhotoProfile();
        if (oldPhoto != null && !oldPhoto.isEmpty()) {
            String oldPhotoPath = getServletContext().getRealPath("/") + "uploads/medecins/" + 
                oldPhoto.substring(oldPhoto.lastIndexOf("/") + 1);
            File oldFile = new File(oldPhotoPath);
            if (oldFile.exists()) {
                oldFile.delete();
            }
        }
        
        String erreur = medecinService.modifier(
            medecin.getIdmed(),
            medecin.getNommed(),
            medecin.getSpecialite(),
            String.valueOf(medecin.getTauxHoraire()),
            medecin.getLieu(),
            medecin.getEmail(),
            medecin.getTelephone(),
            medecin.getBio(),
            medecin.getDiplomes(),
            medecin.getExperience(),
            relativePath
        );
        
        if (erreur != null) {
            session.setAttribute("erreurPhoto", "Erreur lors de l'enregistrement: " + erreur);
        } else {
            session.setAttribute("succesPhoto", "Photo de profil mise à jour avec succès !");
            
            // Mettre à jour l'objet en session si c'est le médecin lui-même
            if ("medecin".equals(role)) {
                Medecin medecinMisAJour = medecinService.trouverParId(idMedecin);
                if (medecinMisAJour != null) {
                    session.setAttribute("utilisateur", medecinMisAJour);
                }
            }
        }
        
        // Redirection selon le rôle
        if ("admin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/admin?action=editMedecin&id=" + idMedecin);
        } else {
            resp.sendRedirect(req.getContextPath() + "/medecin?action=edit&id=" + idMedecin);
        }
    }
}