# Building LLM Architectures from Scratch

This project is a comprehensive implementation of the GPT-2 architecture built from scratch to gain deep understanding of large language model (LLM) architectures and the attention mechanism. The implementation includes both the core model components and a web-based chat interface for interactive testing.

## 🎯 Reference
- YouTube Playlist: [Building LLMs from Scratch](https://www.youtube.com/watch?v=Xpr8D6LeAtw&list=PLPTV0NXA_ZSgsLAr8YCgCwhPIJNNtexWu) by Vizuara

## 🚀 Features
- **Complete GPT-2 Implementation**: Full transformer architecture with multi-head attention
- **Web Chat Interface**: Interactive web application to chat with the model
- **Pretrained Model Support**: Load and use pretrained GPT-2 weights
- **Modular Design**: Clean, well-documented code structure for learning

## 📁 Project Structure
```
├── model/                      # Core GPT-2 implementation
│   ├── model.py               # Main GPT model class
│   ├── transformer_block.py   # Transformer block implementation
│   ├── multihead_attention.py # Multi-head attention mechanism
│   ├── layers.py              # Custom layers (LayerNorm, etc.)
│   ├── utils.py               # Utility functions
│   ├── download_pretrained_weights.py # Download GPT-2 weights
│   └── gpt2/                  # Pretrained model storage
├── web/                       # Web interface
│   ├── app.py                 # Flask web application
│   ├── templates/             # HTML templates
│   └── static/                # CSS and JavaScript files
├── settings.py                # Configuration settings
├── run_server.py              # Server startup script
└── simple_example.py
```

## 🛠️ Installation & Setup

### Prerequisites
- Python 3.7+
- PyTorch
- Flask
- tiktoken

### Quick Start
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd GPT
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```
   
   Or install manually:
   ```bash
   pip install torch>=2.0.0 tiktoken>=0.9.0 numpy>=1.20.0 flask>=3.0.0 flask-cors>=6.0.0 transformers>=4.0.0 safetensors>=0.5.0 requests>=2.25.0 tqdm>=4.60.0 PyYAML>=6.0.0
   ```

3. **Run the web interface**
   ```bash
   python run_server.py
   ```
   
4. **Open your browser** and navigate to `http://localhost:5000`

## 🎯 Objectives
1. **Understand Transformer Architecture**: Reconstruct GPT-2 step by step
2. **Master Attention Mechanisms**: Deep dive into multi-head self-attention
3. **Practical Implementation**: Build a working model with real-world usage
4. **Interactive Learning**: Test and experiment through the web interface

## 🧠 Core Components

### Model Architecture
- **Token & Position Embeddings**: Convert input tokens to vector representations
- **Transformer Blocks**: Stack of attention and feed-forward layers
- **Multi-Head Attention**: Parallel attention mechanisms for different representation subspaces
- **Layer Normalization**: Stabilize training and improve convergence
- **Output Head**: Generate probability distributions over vocabulary

### Web Interface
- **Real-time Chat**: Interactive conversation with the GPT-2 model
- **Modern UI**: Clean, responsive design for optimal user experience
- **Model Loading**: Automatic loading of pretrained weights


### Web Interface
1. Start the server: `python run_server.py`
2. Open browser to `http://localhost:5000`
3. Type your message and chat with GPT-2!

## 📚 Learning Resources
- Original GPT-2 paper: [Language Models are Unsupervised Multitask Learners](https://cdn.openai.com/better-language-models/language_models_are_unsupervised_multitask_learners.pdf)
- Attention mechanism: [Attention Is All You Need](https://arxiv.org/abs/1706.03762)

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License
This project is for educational purposes. Please refer to OpenAI's usage policies for GPT-2.

## 🙏 Acknowledgments
- **Vizuara**: For the excellent educational YouTube series that inspired this implementation
- **OpenAI**: For the GPT-2 architecture and pretrained models
- **Community**: All contributors and educators in the ML/AI space
