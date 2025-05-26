// Chat Interface JavaScript
document.addEventListener('DOMContentLoaded', () => {
    const chatMessages = document.getElementById('chat-messages');
    const chatInput = document.getElementById('chat-input');
    const sendButton = document.getElementById('send-button');
    const loading = document.getElementById('loading');

    // Function to add message to chat
    const addMessage = (message, type) => {
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${type}`;
        messageDiv.textContent = message;
        chatMessages.appendChild(messageDiv);
        
        // Scroll to bottom
        chatMessages.scrollTop = chatMessages.scrollHeight;
    };

    // Function to show/hide loading indicator
    const toggleLoading = (show) => {
        loading.style.display = show ? 'block' : 'none';
        sendButton.disabled = show;
        if (show) {
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }
    };

    // Function to send message to backend
    const sendMessage = async () => {
        const message = chatInput.value.trim();
        
        if (!message) {
            return;
        }

        // Add user message to chat
        addMessage(message, 'user');
        
        // Clear input and disable send button
        chatInput.value = '';
        toggleLoading(true);

        try {
            // Send request to Flask backend
            const response = await fetch('/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ message: message })
            });

            const data = await response.json();

            if (response.ok) {
                // Add bot response to chat
                if (data.reply && data.reply.trim()) {
                    addMessage(data.reply.trim(), 'bot');
                } else {
                    addMessage('I received your message but I don\'t have a response.', 'bot');
                }
            } else {
                // Show error message
                addMessage(`Error: ${data.error || 'Unknown error occurred'}`, 'error');
            }
        } catch (error) {
            console.error('Error:', error);
            addMessage('Error: Unable to connect to the server. Please check if the server is running.', 'error');
        } finally {
            // Hide loading and re-enable send button
            toggleLoading(false);
            chatInput.focus();
        }
    };

    // Event listeners
    sendButton.addEventListener('click', sendMessage);

    chatInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // Focus on input when page loads
    chatInput.focus();

    // Add welcome message
    setTimeout(() => {
        addMessage('Hello! I\'m your GPT-2 assistant. Feel free to ask me anything!', 'bot');
    }, 500);
});
