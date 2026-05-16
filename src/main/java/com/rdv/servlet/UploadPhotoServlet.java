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
        String idUtilisateur = (String) session.getAttribute("idUtilisateur");
        
        // Seul un médecin peut uploader sa photo
        if (!"medecin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
            return;
        }

        Part filePart = req.getPart("photo");
        if (filePart == null || filePart.getSize() == 0) {
            session.setAttribute("erreurPhoto", "Veuillez sélectionner une photo.");
            resp.sendRedirect(req.getContextPath() + "/medecin?action=edit&id=" + idUtilisateur);
            return;
        }

        // Vérifier le type de fichier
        String contentType = filePart.getContentType();
        if (!contentType.startsWith("image/")) {
            session.setAttribute("erreurPhoto", "Le fichier doit être une image (JPG, PNG, GIF).");
            resp.sendRedirect(req.getContextPath() + "/medecin?action=edit&id=" + idUtilisateur);
            return;
        }

        // Vérifier la taille (max 5MB déjà défini dans @MultipartConfig)
        
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
        Medecin medecin = medecinService.trouverParId(idUtilisateur);
        if (medecin == null) {
            session.setAttribute("erreurPhoto", "Médecin non trouvé.");
            resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
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
            
            // Mettre à jour l'objet en session
            Medecin medecinMisAJour = medecinService.trouverParId(idUtilisateur);
            if (medecinMisAJour != null) {
                session.setAttribute("utilisateur", medecinMisAJour);
            }
        }
        
        resp.sendRedirect(req.getContextPath() + "/medecin?action=edit&id=" + idUtilisateur);
    }
}