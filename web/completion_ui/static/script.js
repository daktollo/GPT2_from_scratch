// Text Completion Interface JavaScript
document.addEventListener('DOMContentLoaded', () => {
    const inputText = document.getElementById('input-text');
    const maxTokensInput = document.getElementById('max-tokens');
    const temperatureInput = document.getElementById('temperature');
    const temperatureValue = document.getElementById('temperature-value');
    const topKInput = document.getElementById('top-k');
    const completeButton = document.getElementById('complete-button');
    const loading = document.getElementById('loading');
    const resultContainer = document.getElementById('result-container');
    const originalTextSpan = document.getElementById('original-text');
    const completionTextSpan = document.getElementById('completion-text');
    const copyButton = document.getElementById('copy-button');
    const errorMessage = document.getElementById('error-message');

    // Update temperature display
    temperatureInput.addEventListener('input', () => {
        temperatureValue.textContent = temperatureInput.value;
    });

    // Function to show/hide loading state
    const toggleLoading = (show) => {
        loading.style.display = show ? 'block' : 'none';
        if (show) {
            resultContainer.style.display = 'none';
            errorMessage.style.display = 'none';
        }
        completeButton.disabled = show;
    };

    // Function to show error
    const showError = (message) => {
        errorMessage.textContent = message;
        errorMessage.style.display = 'block';
        loading.style.display = 'none';
        resultContainer.style.display = 'none';
    };

    // Function to show result
    const showResult = (original, completion) => {
        originalTextSpan.textContent = original;
        completionTextSpan.textContent = completion;
        resultContainer.style.display = 'block';
        loading.style.display = 'none';
        errorMessage.style.display = 'none';
    };

    // Function to complete text
    const completeText = async () => {
        const text = inputText.value.trim();
        
        if (!text) {
            showError('Please enter some text to complete.');
            return;
        }

        toggleLoading(true);

        const requestData = {
            text: text,
            max_tokens: parseInt(maxTokensInput.value),
            temperature: parseFloat(temperatureInput.value),
            top_k: parseInt(topKInput.value)
        };

        try {
            const response = await fetch('/complete', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(requestData)
            });

            const data = await response.json();

            if (response.ok) {
                if (data.completion && data.completion.trim()) {
                    showResult(data.original_text, data.completion);
                } else {
                    showError('The model generated an empty completion. Try adjusting the parameters.');
                }
            } else {
                showError(data.error || 'Unknown error occurred');
            }
        } catch (error) {
            console.error('Error:', error);
            showError('Unable to connect to the server. Please check if the server is running.');
        } finally {
            toggleLoading(false);
        }
    };

    // Function to copy full text to clipboard
    const copyFullText = async () => {
        const fullText = originalTextSpan.textContent + completionTextSpan.textContent;
        
        try {
            await navigator.clipboard.writeText(fullText);
            
            // Visual feedback
            const originalText = copyButton.textContent;
            copyButton.textContent = 'Copied!';
            copyButton.style.background = '#4caf50';
            
            setTimeout(() => {
                copyButton.textContent = originalText;
                copyButton.style.background = '#00796b';
            }, 2000);
        } catch (error) {
            console.error('Failed to copy text:', error);
            // Fallback for older browsers
            const textArea = document.createElement('textarea');
            textArea.value = fullText;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
            
            copyButton.textContent = 'Copied!';
            setTimeout(() => {
                copyButton.textContent = 'Copy Full Text';
            }, 2000);
        }
    };

    // Event listeners
    completeButton.addEventListener('click', completeText);
    copyButton.addEventListener('click', copyFullText);

    // Allow Enter key to trigger completion (Ctrl+Enter for multiline)
    inputText.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && e.ctrlKey) {
            e.preventDefault();
            completeText();
        }
    });

    // Focus on input when page loads
    inputText.focus();

    // Input validation
    maxTokensInput.addEventListener('change', () => {
        const value = parseInt(maxTokensInput.value);
        if (value < 1) maxTokensInput.value = 1;
        if (value > 200) maxTokensInput.value = 200;
    });

    topKInput.addEventListener('change', () => {
        const value = parseInt(topKInput.value);
        if (value < 1) topKInput.value = 1;
        if (value > 100) topKInput.value = 100;
    });
});
