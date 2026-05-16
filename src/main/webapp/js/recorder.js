// recorder.js - Gestion de l'enregistrement vocal
let mediaRecorder = null;
let audioChunks = [];
let recordingTimer = null;
let recordingSeconds = 0;
let isRecording = false;

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
                document.getElementById('recordingTime').textContent = '0';
                document.getElementById('recordingIndicator').style.display = 'none';
                stream.getTracks().forEach(track => track.stop());
                isRecording = false;
            };
            
            mediaRecorder.start();
            isRecording = true;
            recordingSeconds = 0;
            document.getElementById('recordingIndicator').style.display = 'block';
            document.getElementById('recordingTime').textContent = '0';
            
            recordingTimer = setInterval(() => {
                recordingSeconds++;
                document.getElementById('recordingTime').textContent = recordingSeconds;
            }, 1000);
        })
        .catch(error => {
            alert('Impossible d\'accéder au microphone. Vérifiez les permissions.');
            console.error('Erreur microphone:', error);
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
    
    fetch('/rdv-medical/message', {
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