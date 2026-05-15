package com.rdv.servlet;

import java.io.IOException;
import java.util.Properties;

import jakarta.mail.Authenticator;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMessage.RecipientType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/diagnostic-email")
public class DiagnosticEmailServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        resp.setContentType("text/html;charset=UTF-8");
        StringBuilder html = new StringBuilder();
        
        html.append("<html><head><title>Diagnostic Email</title>");
        html.append("<style>body{font-family:monospace;padding:20px;} .ok{color:green;} .error{color:red;}</style>");
        html.append("</head><body>");
        html.append("<h1>🔧 Diagnostic Email - RDV Medical</h1>");
        
        // 1. Vérifier les variables d'environnement
        html.append("<h2>1. Variables d'environnement</h2>");
        String username = System.getenv("MAIL_USERNAME");
        String password = System.getenv("MAIL_PASSWORD");
        
        if (username != null && !username.isEmpty()) {
            html.append("<p class='ok'>✅ MAIL_USERNAME = ").append(username).append("</p>");
        } else {
            html.append("<p class='error'>❌ MAIL_USERNAME non définie</p>");
        }
        
        if (password != null && !password.isEmpty()) {
            html.append("<p class='ok'>✅ MAIL_PASSWORD = définie (").append(password.length()).append(" caractères)</p>");
        } else {
            html.append("<p class='error'>❌ MAIL_PASSWORD non définie</p>");
        }
        
        // 2. Tester la connexion SMTP
        html.append("<h2>2. Test connexion SMTP</h2>");
        
        String testEmail = req.getParameter("email");
        if (testEmail == null || testEmail.isEmpty()) {
            html.append("<form method='get'>");
            html.append("<input type='email' name='email' placeholder='Entrez votre email pour tester' required>");
            html.append("<button type='submit'>Tester l'envoi</button>");
            html.append("</form>");
        } else {
            try {
                Properties props = new Properties();
                props.put("mail.smtp.host", "smtp.gmail.com");
                props.put("mail.smtp.port", "587");
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");
                props.put("mail.smtp.ssl.protocols", "TLSv1.2");
                props.put("mail.smtp.connectiontimeout", "10000");
                props.put("mail.smtp.timeout", "10000");
                
                Session session = Session.getInstance(props, new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(username, password);
                    }
                });
                
                MimeMessage message = new MimeMessage(session);
                message.setFrom(new InternetAddress(username));
                message.setRecipient(RecipientType.TO, new InternetAddress(testEmail));
                message.setSubject("Test SMTP - RDV Medical");
                message.setText("Ceci est un email de test depuis Render.com\n\nSi vous recevez ce message, la configuration SMTP fonctionne correctement !");
                
                Transport.send(message);
                html.append("<p class='ok'>✅ Email de test envoyé avec succès à ").append(testEmail).append("</p>");
                
            } catch (Exception e) {
                html.append("<p class='error'>❌ Erreur: ").append(e.getMessage()).append("</p>");
                html.append("<pre>");
                e.printStackTrace(new java.io.PrintWriter(new java.io.StringWriter() {
                    public String toString() {
                        return super.toString();
                    }
                }));
                html.append("</pre>");
            }
        }
        
        html.append("</body></html>");
        resp.getWriter().write(html.toString());
    }
}