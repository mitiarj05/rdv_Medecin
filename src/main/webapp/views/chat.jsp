<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card">
        <h2 class="card-title">
            <i class="fas fa-envelope"></i> Messagerie
        </h2>
        
        <div style="display: flex; gap: 20px; flex-wrap: wrap;">
            <!-- Liste des conversations -->
            <div style="flex: 1; min-width: 280px; border-right: 1px solid var(--border-color);">
                <div style="padding: 10px; border-bottom: 1px solid var(--border-color);">
                    <button id="newConversationBtn" class="btn btn-primary" style="width: 100%;">
                        <i class="fas fa-plus"></i> Nouvelle conversation
                    </button>
                </div>
                <h3 style="margin: 15px 0 10px 10px;"><i class="fas fa-users"></i> Conversations</h3>
                <div id="conversationsList" style="max-height: 500px; overflow-y: auto;">
                    <div style="text-align: center; padding: 20px;">
                        <i class="fas fa-spinner fa-spin"></i> Chargement...
                    </div>
                </div>
            </div>
            
            <!-- Zone de chat -->
            <div style="flex: 2;">
                <div id="chatHeader" style="padding: 10px 0 15px 0; border-bottom: 1px solid var(--border-color);">
                    <h3 id="chatTitle" style="margin: 0;">
                        <i class="fas fa-comment-dots"></i> Sélectionnez une conversation
                    </h3>
                </div>
                <div id="messagesArea" style="height: 400px; overflow-y: auto; padding: 15px; background: var(--bg-primary); border-radius: 12px; margin: 15px 0;">
                    <div style="text-align: center; padding: 40px; color: #666;">
                        <i class="fas fa-comments" style="font-size: 48px; margin-bottom: 10px;"></i>
                        <p>Sélectionnez un contact pour commencer à discuter</p>
                    </div>
                </div>
                <div id="messageInputArea" style="display: none; padding-top: 15px; border-top: 1px solid var(--border-color);">
                    <div style="display: flex; gap: 10px; align-items: flex-end;">
                        <textarea id="messageInput" rows="2" style="flex: 1; padding: 12px; border: 1px solid var(--border-color); border-radius: 12px; resize: none; background: var(--bg-card); color: var(--text-primary);" placeholder="Écrivez votre message..."></textarea>
                        
                        <!-- Bouton pour envoyer une image -->
                        <div style="position: relative;">
                            <input type="file" id="imageInput" accept="image/jpeg,image/png,image/gif" style="display: none;" onchange="sendFile('image')">
                            <button type="button" class="btn btn-secondary" onclick="document.getElementById('imageInput').click()" style="border-radius: 12px; width: 45px; height: 45px;">
                                <i class="fas fa-image"></i>
                            </button>
                        </div>
                        
                        <!-- Bouton pour enregistrement vocal (maintenir appuyé) -->
                        <div style="position: relative;">
                            <button type="button" id="voiceRecordBtn" class="btn btn-secondary" style="border-radius: 12px; width: 45px; height: 45px; background: #ea4335; color: white;">
                                <i class="fas fa-microphone"></i>
                            </button>
                        </div>
                        
                        <button id="sendBtn" class="btn btn-primary" style="height: 50px; border-radius: 12px;">
                            <i class="fas fa-paper-plane"></i> Envoyer
                        </button>
                    </div>
                    
                    <!-- Indicateur d'enregistrement vocal -->
                    <div id="recordingIndicator" style="display: none; margin-top: 10px; padding: 10px; background: #ea4335; color: white; border-radius: 8px; text-align: center;">
                        <i class="fas fa-microphone fa-pulse"></i> Enregistrement en cours... <span id="recordingTime">0</span> secondes
                        <span style="float: right; font-size: 12px;">Relâchez pour envoyer</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODAL POUR NOUVELLE CONVERSATION -->
<div id="newConversationModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.6); z-index:2000; align-items:center; justify-content:center;">
    <div style="background:var(--bg-card); border-radius:16px; padding:25px; width:90%; max-width:450px; animation:fadeInUp 0.3s ease;">
        <h3 style="color:#1a73e8; margin-bottom:15px;">
            <i class="fas fa-comment-dots"></i> Nouvelle conversation
        </h3>
        <div class="form-group">
            <label>Choisissez un médecin :</label>
            <select id="contactSelect" style="width:100%; padding:10px; border:1px solid var(--border-color); border-radius:8px; margin-bottom:15px;">
                <option value="">-- Sélectionnez un médecin --</option>
            </select>
        </div>
        <div class="form-group">
            <label>Votre message :</label>
            <textarea id="firstMessage" rows="4" style="width:100%; padding:12px; border:1px solid var(--border-color); border-radius:8px; resize:vertical;" placeholder="Écrivez votre premier message..."></textarea>
        </div>
        <div style="display:flex; gap:10px; justify-content:flex-end; margin-top:20px;">
            <button onclick="closeNewConversationModal()" class="btn btn-secondary">Annuler</button>
            <button onclick="startNewConversation()" class="btn btn-primary">
                <i class="fas fa-paper-plane"></i> Envoyer
            </button>
        </div>
    </div>
</div>

<style>
    .conversation-item {
        padding: 12px 15px;
        border-bottom: 1px solid var(--border-color);
        cursor: pointer;
        transition: background 0.2s;
        display: flex;
        align-items: center;
        gap: 12px;
        border-radius: 12px;
        margin-bottom: 5px;
    }
    .conversation-item:hover {
        background: var(--hover-bg);
    }
    .conversation-item.active {
        background: #e8f0fe;
    }
    body.dark-mode .conversation-item.active {
        background: #1a2744;
    }
    .conversation-avatar {
        width: 45px;
        height: 45px;
        border-radius: 50%;
        background: linear-gradient(135deg, #1a73e8, #0d47a1);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 18px;
        flex-shrink: 0;
    }
    .conversation-info {
        flex: 1;
    }
    .conversation-name {
        font-weight: 600;
        font-size: 14px;
    }
    .conversation-last {
        font-size: 11px;
        color: var(--text-muted);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        max-width: 180px;
    }
    .unread-indicator {
        background: #ea4335;
        color: white;
        border-radius: 50%;
        padding: 2px 6px;
        font-size: 10px;
        min-width: 20px;
        text-align: center;
        font-weight: bold;
    }
    .message-bubble {
        margin-bottom: 15px;
        display: flex;
        animation: fadeInUp 0.2s ease-out;
        position: relative;
    }
    .message-bubble.me {
        justify-content: flex-end;
    }
    .message-bubble.other {
        justify-content: flex-start;
    }
    .message-content {
        max-width: 70%;
        padding: 10px 15px;
        border-radius: 18px;
        background: #e8f0fe;
        color: #333;
        word-wrap: break-word;
        position: relative;
    }
    body.dark-mode .message-content {
        background: #1a2744;
        color: #eee;
    }
    .message-bubble.me .message-content {
        background: #1a73e8;
        color: white;
    }
    .message-time {
        font-size: 10px;
        margin-top: 4px;
        color: var(--text-muted);
        text-align: right;
    }
    .message-actions {
        position: absolute;
        right: -30px;
        top: 0;
        opacity: 0;
        transition: opacity 0.2s;
        display: flex;
        gap: 5px;
    }
    .message-bubble:hover .message-actions {
        opacity: 1;
    }
    .message-actions button {
        background: var(--bg-card);
        border: 1px solid var(--border-color);
        border-radius: 50%;
        width: 24px;
        height: 24px;
        font-size: 10px;
        cursor: pointer;
        color: var(--text-secondary);
    }
    .message-actions button:hover {
        background: #ea4335;
        color: white;
    }
    .message-image {
        max-width: 200px;
        max-height: 200px;
        border-radius: 12px;
        cursor: pointer;
        margin-bottom: 5px;
    }
    .message-audio {
        width: 200px;
        height: 40px;
        border-radius: 20px;
    }
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    @keyframes pulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.1); }
        100% { transform: scale(1); }
    }
    .recording-pulse {
        animation: pulse 0.5s infinite;
    }
</style>

<script>
    let currentContact = null;
    let currentContactType = null;
    let currentContactName = null;
    let pollInterval = null;
    let allMessages = [];
    let userRole = '${sessionScope.role}';
    let userId = '${sessionScope.idUtilisateur}';
    let userType = userRole;
    
    // ========== GESTION DE L'ENREGISTREMENT VOCAL ==========
    let mediaRecorder = null;
    let audioChunks = [];
    let recordingTimer = null;
    let recordingSeconds = 0;
    let isRecording = false;
    
    const voiceRecordBtn = document.getElementById('voiceRecordBtn');
    const recordingIndicator = document.getElementById('recordingIndicator');
    const recordingTimeSpan = document.getElementById('recordingTime');
    
    function startVoiceRecording() {
        if (!currentContact) {
            alert('Veuillez d\'abord sélectionner une conversation.');
            return false;
        }
        
        navigator.mediaDevices.getUserMedia({ audio: true })
            .then(stream => {
                mediaRecorder = new MediaRecorder(stream);
                audioChunks = [];
                
                mediaRecorder.ondataavailable = event => {
                    audioChunks.push(event.data);
                };
                
                mediaRecorder.onstop = () => {
                    const audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
                    sendVoiceMessage(audioBlob);
                    recordingSeconds = 0;
                    recordingTimeSpan.textContent = '0';
                    recordingIndicator.style.display = 'none';
                    voiceRecordBtn.classList.remove('recording-pulse');
                    voiceRecordBtn.style.background = '#ea4335';
                    stream.getTracks().forEach(track => track.stop());
                    isRecording = false;
                };
                
                mediaRecorder.start();
                isRecording = true;
                recordingSeconds = 0;
                recordingIndicator.style.display = 'block';
                recordingTimeSpan.textContent = '0';
                voiceRecordBtn.classList.add('recording-pulse');
                voiceRecordBtn.style.background = '#c5221f';
                
                if (recordingTimer) clearInterval(recordingTimer);
                recordingTimer = setInterval(() => {
                    recordingSeconds++;
                    recordingTimeSpan.textContent = recordingSeconds;
                }, 1000);
            })
            .catch(error => {
                console.error('Erreur microphone:', error);
                alert('Impossible d\'accéder au microphone. Vérifiez les permissions.');
                return false;
            });
        return true;
    }
    
    function stopVoiceRecording() {
        if (mediaRecorder && mediaRecorder.state === 'recording') {
            mediaRecorder.stop();
            if (recordingTimer) clearInterval(recordingTimer);
            isRecording = false;
        }
    }
    
    function sendVoiceMessage(audioBlob) {
        const formData = new FormData();
        formData.append('action', 'envoyerFichier');
        formData.append('idDestinataire', currentContact);
        formData.append('typeDestinataire', currentContactType);
        formData.append('contenu', '');
        formData.append('fichier', audioBlob, 'voice.webm');
        
        fetch('${pageContext.request.contextPath}/message', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                loadMessages();
            } else {
                alert('Erreur: ' + data.message);
            }
        })
        .catch(error => console.error('Erreur:', error));
    }
    
    // Événements pour le bouton d'enregistrement vocal (maintenir appuyé)
    if (voiceRecordBtn) {
        voiceRecordBtn.addEventListener('mousedown', function(e) {
            e.preventDefault();
            startVoiceRecording();
        });
        
        voiceRecordBtn.addEventListener('mouseup', function(e) {
            e.preventDefault();
            stopVoiceRecording();
        });
        
        voiceRecordBtn.addEventListener('mouseleave', function(e) {
            if (isRecording) {
                stopVoiceRecording();
            }
        });
        
        // Pour le tactile (mobile)
        voiceRecordBtn.addEventListener('touchstart', function(e) {
            e.preventDefault();
            startVoiceRecording();
        });
        
        voiceRecordBtn.addEventListener('touchend', function(e) {
            e.preventDefault();
            stopVoiceRecording();
        });
    }
    
    // ========== ENVOI D'IMAGE ==========
    function sendFile(type) {
        const input = document.getElementById(type === 'image' ? 'imageInput' : 'audioInput');
        const file = input.files[0];
        if (!file) return;
        
        if (!currentContact) {
            alert('Veuillez d\'abord sélectionner une conversation.');
            input.value = '';
            return;
        }
        
        const formData = new FormData();
        formData.append('action', 'envoyerFichier');
        formData.append('idDestinataire', currentContact);
        formData.append('typeDestinataire', currentContactType);
        formData.append('contenu', '');
        formData.append('fichier', file);
        
        fetch('${pageContext.request.contextPath}/message', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                loadMessages();
            } else {
                alert('Erreur: ' + data.message);
            }
        })
        .catch(error => console.error('Erreur:', error));
        
        input.value = '';
    }
    
    // ========== SUPPRIMER UN MESSAGE ==========
    function deleteMessage(messageId) {
        if (!confirm('Voulez-vous vraiment supprimer ce message ?')) return;
        
        fetch('${pageContext.request.contextPath}/message', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=supprimer&idMessage=' + encodeURIComponent(messageId)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                loadMessages();
            } else {
                alert('Erreur lors de la suppression');
            }
        })
        .catch(error => console.error('Erreur:', error));
    }
    
    // ========== AFFICHER UNE IMAGE EN GRAND ==========
    function showFullImage(src) {
        const modal = document.createElement('div');
        modal.style.position = 'fixed';
        modal.style.top = '0';
        modal.style.left = '0';
        modal.style.width = '100%';
        modal.style.height = '100%';
        modal.style.background = 'rgba(0,0,0,0.9)';
        modal.style.zIndex = '3000';
        modal.style.display = 'flex';
        modal.style.alignItems = 'center';
        modal.style.justifyContent = 'center';
        modal.style.cursor = 'pointer';
        
        const img = document.createElement('img');
        img.src = src;
        img.style.maxWidth = '90%';
        img.style.maxHeight = '90%';
        img.style.borderRadius = '8px';
        
        modal.appendChild(img);
        document.body.appendChild(modal);
        
        modal.onclick = function() {
            modal.remove();
        };
    }
    
    // ========== CHARGER LES CONVERSATIONS ==========
    function loadConversations() {
        fetch('${pageContext.request.contextPath}/message?action=liste')
            .then(response => response.json())
            .then(data => {
                const container = document.getElementById('conversationsList');
                if (data.messages && data.messages.length > 0) {
                    const conversations = new Map();
                    data.messages.forEach(msg => {
                        const isMe = msg.idExpediteur === userId;
                        const otherId = isMe ? msg.idDestinataire : msg.idExpediteur;
                        const otherType = isMe ? msg.typeDestinataire : msg.typeExpediteur;
                        const otherName = isMe ? msg.nomDestinataire : msg.nomExpediteur;
                        const key = otherId + '_' + otherType;
                        
                        if (!conversations.has(key)) {
                            conversations.set(key, {
                                id: otherId,
                                type: otherType,
                                name: otherName,
                                lastMessage: msg.contenu,
                                lastDate: msg.date,
                                unread: (!isMe && !msg.lu) ? true : false
                            });
                        }
                    });
                    
                    let html = '';
                    conversations.forEach(conv => {
                        const unreadBadge = conv.unread ? '<span class="unread-indicator">!</span>' : '';
                        html += '<div class="conversation-item" onclick="selectConversation(\'' + conv.id + '\', \'' + conv.type + '\', \'' + escapeHtml(conv.name) + '\')">' +
                            '<div class="conversation-avatar"><i class="fas fa-user"></i></div>' +
                            '<div class="conversation-info">' +
                            '<div class="conversation-name">' + escapeHtml(conv.name) + '</div>' +
                            '<div class="conversation-last">' + escapeHtml(conv.lastMessage.substring(0, 40)) + (conv.lastMessage.length > 40 ? '...' : '') + '</div>' +
                            '</div>' +
                            unreadBadge +
                            '</div>';
                    });
                    container.innerHTML = html;
                } else {
                    container.innerHTML = '<div style="text-align: center; padding: 40px; color: #666;"><i class="fas fa-inbox"></i><p>Aucune conversation</p><p style="font-size:12px;">Cliquez sur "Nouvelle conversation" pour commencer</p></div>';
                }
            })
            .catch(error => {
                console.error('Erreur:', error);
                document.getElementById('conversationsList').innerHTML = '<div style="text-align: center; padding: 20px; color: red;">Erreur de chargement</div>';
            });
    }
    
    function escapeHtml(text) {
        if (!text) return '';
        return text.replace(/[&<>]/g, function(m) {
            if (m === '&') return '&amp;';
            if (m === '<') return '&lt;';
            if (m === '>') return '&gt;';
            return m;
        });
    }
    
    function selectConversation(id, type, name) {
        currentContact = id;
        currentContactType = type;
        currentContactName = name;
        
        document.getElementById('chatTitle').innerHTML = '<i class="fas fa-user-circle"></i> ' + escapeHtml(name);
        document.getElementById('messageInputArea').style.display = 'block';
        
        loadMessages();
        
        if (pollInterval) clearInterval(pollInterval);
        pollInterval = setInterval(loadMessages, 5000);
    }
    
    function loadMessages() {
        if (!currentContact) return;
        
        fetch('${pageContext.request.contextPath}/message?action=conversation&idAutre=' + currentContact + '&typeAutre=' + currentContactType)
            .then(response => response.json())
            .then(data => {
                if (data.messages && data.messages.length > 0) {
                    allMessages = data.messages;
                    const container = document.getElementById('messagesArea');
                    let html = '';
                    data.messages.forEach(msg => {
                        const isMe = msg.estMoi;
                        
                        let contentHtml = '';
                        if (msg.pieceJointe && msg.pieceJointe !== '') {
                            if (msg.typePiece === 'image') {
                                contentHtml = '<img src="' + msg.pieceJointe + '" class="message-image" onclick="showFullImage(\'' + msg.pieceJointe + '\')">';
                            } else if (msg.typePiece === 'audio') {
                                contentHtml = '<audio controls class="message-audio"><source src="' + msg.pieceJointe + '"></audio>';
                            }
                        }
                        if (msg.contenu && msg.contenu !== '') {
                            if (contentHtml) contentHtml += '<br>';
                            contentHtml += escapeHtml(msg.contenu);
                        }
                        
                        html += '<div class="message-bubble ' + (isMe ? 'me' : 'other') + '">' +
                            '<div class="message-content">' +
                            contentHtml +
                            '<div class="message-time">' + msg.date + '</div>' +
                            '<div class="message-actions">' +
                            '<button onclick="deleteMessage(\'' + msg.id + '\')" title="Supprimer"><i class="fas fa-trash-alt"></i></button>' +
                            '</div>' +
                            '</div>' +
                            '</div>';
                    });
                    container.innerHTML = html;
                    container.scrollTop = container.scrollHeight;
                    loadConversations();
                } else {
                    document.getElementById('messagesArea').innerHTML = '<div style="text-align: center; padding: 40px; color: #666;"><i class="fas fa-comments"></i><p>Aucun message. Commencez la conversation !</p></div>';
                }
            })
            .catch(error => console.error('Erreur:', error));
    }
    
    function sendMessage() {
        const message = document.getElementById('messageInput').value.trim();
        if (!message && !currentContact) return;
        if (!message) return;
        
        fetch('${pageContext.request.contextPath}/message', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=envoyer&idDestinataire=' + encodeURIComponent(currentContact) + 
                  '&typeDestinataire=' + encodeURIComponent(currentContactType) + 
                  '&contenu=' + encodeURIComponent(message)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                document.getElementById('messageInput').value = '';
                loadMessages();
            } else {
                alert('Erreur: ' + data.message);
            }
        })
        .catch(error => console.error('Erreur:', error));
    }
    
    // ========== NOUVELLE CONVERSATION ==========
    function loadDoctorsForNewConversation() {
        fetch('${pageContext.request.contextPath}/api/doctors-list')
            .then(response => response.json())
            .then(data => {
                const select = document.getElementById('contactSelect');
                select.innerHTML = '<option value="">-- Sélectionnez un médecin --</option>';
                if (data.doctors && data.doctors.length > 0) {
                    data.doctors.forEach(doc => {
                        select.innerHTML += '<option value="' + doc.id + '">Dr. ' + doc.nom + ' - ' + doc.specialite + ' (' + doc.lieu + ')</option>';
                    });
                } else {
                    select.innerHTML = '<option value="">Aucun médecin disponible</option>';
                }
            })
            .catch(error => {
                console.error('Erreur chargement médecins:', error);
                document.getElementById('contactSelect').innerHTML = '<option value="">Erreur de chargement</option>';
            });
    }
    
    function openNewConversationModal() {
        loadDoctorsForNewConversation();
        document.getElementById('newConversationModal').style.display = 'flex';
        document.getElementById('firstMessage').value = '';
    }
    
    function closeNewConversationModal() {
        document.getElementById('newConversationModal').style.display = 'none';
    }
    
    function startNewConversation() {
        const medecinId = document.getElementById('contactSelect').value;
        const message = document.getElementById('firstMessage').value.trim();
        
        if (!medecinId) {
            alert('Veuillez sélectionner un médecin.');
            return;
        }
        if (!message) {
            alert('Veuillez écrire un message.');
            return;
        }
        
        fetch('${pageContext.request.contextPath}/message', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=envoyer&idDestinataire=' + encodeURIComponent(medecinId) + 
                  '&typeDestinataire=medecin' + 
                  '&contenu=' + encodeURIComponent(message)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Message envoyé avec succès !');
                closeNewConversationModal();
                loadConversations();
                setTimeout(function() {
                    const select = document.getElementById('contactSelect');
                    const selectedOption = select.options[select.selectedIndex];
                    const medecinName = selectedOption ? selectedOption.text : 'Médecin';
                    selectConversation(medecinId, 'medecin', medecinName);
                }, 500);
            } else {
                alert('Erreur: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Erreur:', error);
            alert('Erreur lors de l\'envoi du message.');
        });
    }
    
    // ========== ÉVÉNEMENTS ==========
    document.getElementById('sendBtn').addEventListener('click', sendMessage);
    document.getElementById('messageInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });
    document.getElementById('newConversationBtn').addEventListener('click', openNewConversationModal);
    
    window.onclick = function(event) {
        const modal = document.getElementById('newConversationModal');
        if (event.target === modal) {
            closeNewConversationModal();
        }
    }
    
    loadConversations();
    
    window.addEventListener('beforeunload', function() {
        if (pollInterval) clearInterval(pollInterval);
        if (mediaRecorder && mediaRecorder.state === 'recording') {
            mediaRecorder.stop();
        }
    });
</script>

</body>
</html>