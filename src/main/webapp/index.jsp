<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>RDV Medical</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; text-align: center; padding: 50px; background: linear-gradient(135deg, #e8f0fe, #ffffff); margin: 0; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 16px; padding: 40px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        h1 { color: #1a73e8; margin-bottom: 20px; }
        .btn { display: inline-block; padding: 12px 24px; margin: 10px; background: #1a73e8; color: white; text-decoration: none; border-radius: 8px; font-weight: bold; transition: all 0.3s ease; }
        .btn:hover { background: #0d47a1; transform: translateY(-2px); }
        .btn-secondary { background: #34a853; }
        .btn-secondary:hover { background: #1e7e4a; }
        .status { margin-top: 20px; padding: 10px; background: #e6f4ea; border-radius: 8px; color: #137333; font-size: 14px; }
        .features { margin-top: 30px; text-align: left; display: inline-block; }
        .features li { margin: 8px 0; color: #555; }
    </style>
</head>
<body>
<div class="container">
    <h1>🏥 RDV Medical</h1>
    <p>Système de gestion de rendez-vous médicaux</p>
    
    <a href="${pageContext.request.contextPath}/views/shared/login.jsp" class="btn">🔐 Connexion</a>
    <a href="${pageContext.request.contextPath}/views/shared/register.jsp" class="btn btn-secondary">📝 Inscription</a>
    
    <div class="status">
        ✅ Application prête ! Connectez-vous pour accéder à votre espace.
    </div>
    
    <div class="features">
        <ul>
            <li>👨‍⚕️ Prenez rendez-vous avec des médecins spécialistes</li>
            <li>📅 Gérez votre agenda facilement</li>
            <li>🔔 Recevez des confirmations par email</li>
            <li>📊 Suivez votre historique médical</li>
        </ul>
    </div>
</div>
</body>
</html>