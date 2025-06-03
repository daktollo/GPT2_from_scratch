from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import sys
import os

# Add the parent directory to the path so we can import from the model
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))

import tiktoken
from settings import *
from model.model import GPTModel
from model.utils import *
from model.download_pretrained_weights import download_and_load_gpt2
import torch

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Global variables for the model
model = None
tokenizer = None
device = None

def load_gpt_model():
    """Load the GPT-2 model once on startup"""
    global model, tokenizer, device
    
    print("Loading GPT-2 model...")
    
    # Set up tokenizer
    tokenizer = tiktoken.get_encoding("gpt2")
    torch.manual_seed(123)
    
    # Model configuration
    GPT_CONFIG_124M = {
        "vocab_size": 50257,
        "context_length": 1024,
        "emb_dim": 768,
        "n_heads": 12,
        "n_layers": 12,
        "drop_rate": 0.1,
        "qkv_bias": True
    }
    
    # Load model and weights
    settings, params = download_and_load_gpt2(model_size="124M", models_dir=MODEL_PATH)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    
    model = GPTModel(GPT_CONFIG_124M)
    model.eval()
    
    load_weights_into_gpt(model, params)
    model.to(device)
    
    print(f"Model loaded successfully on {device}")

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/chat', methods=['POST'])
def chat():
    global model, tokenizer, device
    
    try:
        # Get user message
        data = request.get_json()
        if not data or 'message' not in data:
            return jsonify({'error': 'No message provided'}), 400
        
        user_message = data['message'].strip()
        if not user_message:
            return jsonify({'error': 'Empty message'}), 400
        
        # Generate response
        idx = text_to_token_ids(user_message, tokenizer)
        idx = idx.to(device)
        
        token_ids = generate(
            model=model,
            idx=idx,
            max_new_tokens=50,  # Limit response length for better performance
            context_size=1024,
            top_k=50,  # Use top-k sampling for more diverse responses
            temperature=0.8  # Slightly creative but not too random
        )
        
        # Generate response and clean it up
        full_response = token_ids_to_text(token_ids, tokenizer)
        # Remove the original prompt from the response
        response = full_response[len(user_message):].strip()
        
        return jsonify({'reply': response})
        
    except Exception as e:
        print(f"Error generating response: {str(e)}")
        return jsonify({'error': 'Failed to generate response'}), 500

if __name__ == '__main__':
    # Load the model when the app starts
    load_gpt_model()
    
    # Run the Flask app
    app.run(host='0.0.0.0', port=5000, debug=True)