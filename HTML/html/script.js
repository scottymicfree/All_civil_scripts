// Listen for server responses
window.addEventListener('message', (event) => {
    const data = event.data;
    
    // ... existing code ...
    
    if (data.type === 'serverResponse') {
        console.log('Received server response:', data.data);
        
        // Example: Show response in UI
        if (data.data && data.data.message) {
            const responseElement = document.createElement('div');
            responseElement.className = 'server-response';
            responseElement.textContent = data.data.message;
            
            document.getElementById('content').appendChild(responseElement);
            
            // Remove after 5 seconds
            setTimeout(() => {
                responseElement.remove();
            }, 5000);
        }
    }
});


// Variables
const container = document.getElementById('container');
const messageElement = document.getElementById('message');
const actionButton = document.getElementById('actionButton');
const notifyButton = document.getElementById('notifyButton');
const closeButton = document.getElementById('closeButton');

// Function to show UI
function showUI(message) {
    // Update message if provided
    if (message) {
        messageElement.textContent = message;
    }
    
    // Show container with animation
    container.style.display = 'block';
    container.classList.remove('fade-out');
    container.classList.add('fade-in');
}

// Function to hide UI
function hideUI() {
    // Hide with animation
    container.classList.remove('fade-in');
    container.classList.add('fade-out');
    
    // Actually hide after animation completes
    setTimeout(() => {
        container.style.display = 'none';
    }, 300);
}

// Function to send data to client script
function sendData(data) {
    fetch(`https://${GetParentResourceName()}/action`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    }).then(resp => resp.json());
}

// Function to close UI
function closeUI() {
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(resp => resp.json());
}

// Event listeners
actionButton.addEventListener('click', () => {
    sendData({
        type: 'serverEvent',
        action: 'button_click',
        data: {
            timestamp: Date.now(),
            message: 'Action button clicked'
        }
    });
});

notifyButton.addEventListener('click', () => {
    sendData({
        type: 'notification',
        message: 'This is a notification from the UI!'
    });
});

closeButton.addEventListener('click', () => {
    closeUI();
});

// Listen for messages from the client script
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.type === 'showUI') {
        showUI(data.message);
    } else if (data.type === 'hideUI') {
        hideUI();
    }
});

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    console.log('UI initialized');
});
