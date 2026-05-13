package com.rdv.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.rdv.model.Rdv;

public class CalendarService {

    private final RdvService rdvService = new RdvService();

    /**
     * Récupère les rendez-vous pour un mois donné
     * - Pour admin : tous les rendez-vous de tous les médecins
     * - Pour médecin : ses rendez-vous uniquement
     * - Pour patient : ses rendez-vous uniquement
     */
    public Map<Integer, List<CalendarRdv>> getRdvsByMonth(String idUtilisateur, String role, int year, int month) {
        Map<Integer, List<CalendarRdv>> rdvMap = new HashMap<>();

        List<Rdv> rdvs;

        // 🔥 ADMIN : Récupérer TOUS les rendez-vous
        if ("admin".equals(role)) {
            rdvs = rdvService.listerTous();
            System.out.println("[CalendarService] Admin - Affichage de tous les RDV: " + (rdvs != null ? rdvs.size() : 0) + " RDV");
        } else if ("medecin".equals(role)) {
            rdvs = rdvService.listerParMedecin(idUtilisateur);
        } else {
            rdvs = rdvService.listerParPatient(idUtilisateur);
        }

        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.withDayOfMonth(startDate.lengthOfMonth());

        for (Rdv rdv : rdvs) {
            LocalDateTime dateTime = rdv.getDateRdv();
            if (dateTime != null) {
                LocalDate rdvDate = dateTime.toLocalDate();
                if ((rdvDate.isEqual(startDate) || rdvDate.isAfter(startDate)) &&
                        (rdvDate.isEqual(endDate) || rdvDate.isBefore(endDate))) {

                    int day = rdvDate.getDayOfMonth();
                    CalendarRdv calRdv = new CalendarRdv();
                    calRdv.setIdrdv(rdv.getIdrdv());
                    calRdv.setHeure(dateTime.format(DateTimeFormatter.ofPattern("HH:mm")));
                    calRdv.setStatut(rdv.getStatut());

                    // 🔥 ADMIN : Afficher les informations complètes (médecin + patient)
                    if ("admin".equals(role)) {
                        calRdv.setNom(rdv.getPatient() != null ? rdv.getPatient().getNomPat() : "Patient");
                        calRdv.setEmail(rdv.getPatient() != null ? rdv.getPatient().getEmail() : "");
                        calRdv.setMedecinNom(rdv.getMedecin() != null ? "Dr. " + rdv.getMedecin().getNommed() : "Médecin");
                        calRdv.setMedecinSpecialite(rdv.getMedecin() != null ? rdv.getMedecin().getSpecialite() : "");
                        calRdv.setLieu(rdv.getMedecin() != null ? rdv.getMedecin().getLieu() : "");
                    } else if ("medecin".equals(role)) {
                        calRdv.setNom(rdv.getPatient() != null ? rdv.getPatient().getNomPat() : "Patient");
                        calRdv.setEmail(rdv.getPatient() != null ? rdv.getPatient().getEmail() : "");
                    } else {
                        calRdv.setNom(rdv.getMedecin() != null ? "Dr. " + rdv.getMedecin().getNommed() : "Médecin");
                        calRdv.setSpecialite(rdv.getMedecin() != null ? rdv.getMedecin().getSpecialite() : "");
                        calRdv.setLieu(rdv.getMedecin() != null ? rdv.getMedecin().getLieu() : "");
                    }

                    if (!rdvMap.containsKey(day)) {
                        rdvMap.put(day, new ArrayList<>());
                    }
                    rdvMap.get(day).add(calRdv);
                }
            }
        }

        return rdvMap;
    }

    /**
     * Récupère les statistiques du mois
     */
    public MonthStats getMonthStats(String idUtilisateur, String role, int year, int month) {
        MonthStats stats = new MonthStats();
        Map<Integer, List<CalendarRdv>> rdvs = getRdvsByMonth(idUtilisateur, role, year, month);

        int totalRdvs = 0;
        int totalConfirmes = 0;
        int totalAnnules = 0;

        for (List<CalendarRdv> list : rdvs.values()) {
            totalRdvs += list.size();
            for (CalendarRdv rdv : list) {
                if ("CONFIRME".equals(rdv.getStatut())) {
                    totalConfirmes++;
                } else {
                    totalAnnules++;
                }
            }
        }

        stats.setTotalRdvs(totalRdvs);
        stats.setTotalConfirmes(totalConfirmes);
        stats.setTotalAnnules(totalAnnules);
        stats.setTauxOccupation(totalRdvs > 0 ? (totalConfirmes * 100 / totalRdvs) : 0);

        return stats;
    }

    // Classe interne pour les rendez-vous du calendrier
    public static class CalendarRdv {
        private String idrdv;
        private String heure;
        private String statut;
        private String nom;
        private String email;
        private String specialite;
        private String lieu;

        // 🔥 Nouveaux champs pour l'admin
        private String medecinNom;
        private String medecinSpecialite;

        public String getIdrdv() { return idrdv; }
        public void setIdrdv(String idrdv) { this.idrdv = idrdv; }
        public String getHeure() { return heure; }
        public void setHeure(String heure) { this.heure = heure; }
        public String getStatut() { return statut; }
        public void setStatut(String statut) { this.statut = statut; }
        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getSpecialite() { return specialite; }
        public void setSpecialite(String specialite) { this.specialite = specialite; }
        public String getLieu() { return lieu; }
        public void setLieu(String lieu) { this.lieu = lieu; }

        // 🔥 Getters/Setters pour l'admin
        public String getMedecinNom() { return medecinNom; }
        public void setMedecinNom(String medecinNom) { this.medecinNom = medecinNom; }
        public String getMedecinSpecialite() { return medecinSpecialite; }
        public void setMedecinSpecialite(String medecinSpecialite) { this.medecinSpecialite = medecinSpecialite; }

        public boolean isConfirme() { return "CONFIRME".equals(statut); }
    }

    // Classe interne pour les statistiques du mois
    public static class MonthStats {
        private int totalRdvs;
        private int totalConfirmes;
        private int totalAnnules;
        private int tauxOccupation;

        public int getTotalRdvs() { return totalRdvs; }
        public void setTotalRdvs(int totalRdvs) { this.totalRdvs = totalRdvs; }
        public int getTotalConfirmes() { return totalConfirmes; }
        public void setTotalConfirmes(int totalConfirmes) { this.totalConfirmes = totalConfirmes; }
        public int getTotalAnnules() { return totalAnnules; }
        public void setTotalAnnules(int totalAnnules) { this.totalAnnules = totalAnnules; }
        public int getTauxOccupation() { return tauxOccupation; }
        public void setTauxOccupation(int tauxOccupation) { this.tauxOccupation = tauxOccupation; }
    }
}