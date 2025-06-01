# Building LLM Architectures from Scratch

This project is a comprehensive implementation of the GPT-2 architecture built from scratch to gain deep understanding of large language model (LLM) architectures and the attention mechanism. The implementation includes both the core model components and a web-based chat interface for interactive testing.

## 🎯 Reference
- YouTube Playlist: [Building LLMs from Scratch](https://www.youtube.com/watch?v=Xpr8D6LeAtw&list=PLPTV0NXA_ZSgsLAr8YCgCwhPIJNNtexWu) by Vizuara


## 🧠 Core Components

### Model Architecture
- **Token & Position Embeddings**: Convert input tokens to vector representations
- **Transformer Blocks**: Stack of attention and feed-forward layers
- **Multi-Head Attention**: Parallel attention mechanisms for different representation subspaces
- **Layer Normalization**: Stabilize training and improve convergence
- **Output Head**: Generate probability distributions over vocabulary

## 🏗️ GPT-2 Architectural Overview

The GPT-2 architecture follows a transformer-based design that processes input sequentially through multiple layers. Understanding the data flow through each component is crucial for implementing the model correctly.

### Word Embeddings: The Foundation of Language Understanding

Word embeddings form the critical first step in transforming human language into mathematical representations that neural networks can process. In GPT-2, each token (word, subword, or punctuation) is converted into a high-dimensional vector that captures semantic meaning through learned patterns.

**Key Characteristics of Word Embeddings:**

- **High-Dimensional Representation**: GPT-2 uses 768-dimensional vectors to represent each token, providing rich semantic space
- **Semantic Geometry**: Words with similar meanings cluster together in the embedding space, creating meaningful geometric relationships
- **Learned Relationships**: The model learns that vector differences capture semantic relationships (e.g., "king" - "man" + "woman" ≈ "queen")
- **Context Independence**: Initial embeddings encode only individual word meanings, without contextual information

**Mathematical Foundation:**
Each word corresponds to a column in the embedding matrix (V × C), where V is the vocabulary size (50,257) and C is the embedding dimension (768). During training, these initially random vectors are optimized to position semantically similar words closer together in the high-dimensional space.

**From Words to Vectors:**
The embedding process transforms discrete tokens into continuous vector representations that enable mathematical operations. This transformation is essential because neural networks operate on numerical data, not symbolic text. The dot product between embedding vectors measures semantic similarity, with higher values indicating stronger relationships.

![Word Embedding Visualization](images/word_embedding.png)

*Figure: Word embedding space showing semantic relationships between words like "king", "queen", "man", and "woman" in a high-dimensional vector space*

*Reference: [But what is a GPT? Visual intro to Transformers](https://medium.com/lazy-by-design/but-what-is-a-gpt-visual-intro-to-transformers-3blue1brown-d078447b8ef4)*

### Key Configuration Parameters
- **Vocabulary Size (V)**: 50,257 tokens
- **Maximum Sequence Length (T)**: 1,024 tokens
- **Embedding Dimensionality (C)**: 768 dimensions
- **Number of Attention Heads (h)**: 12 heads
- **Number of Transformer Layers (N)**: 12 layers
- **Batch Size (B)**: 512 (configurable)

### Data Flow Through the Architecture

1. **Input Processing**
   - Input tokens (B, T) are embedded into dense vectors
   - Position embeddings are added to capture sequence order
   - Combined embeddings flow into transformer blocks

2. **Transformer Blocks** (Repeated N=12 times)
   - **Multi-Head Self-Attention**: Processes relationships between tokens
   - **Feed-Forward Network**: Applies non-linear transformations
   - **Residual Connections**: Enable stable gradient flow
   - **Layer Normalization**: Stabilizes training

3. **Output Generation**
   - Final layer normalization
   - Linear projection to vocabulary size
   - Softmax for probability distribution over next tokens

![Word Embedding Visualization](images/gpt_architectural_diagram.png)

*Figure: The architectural diagram helps visualize how tensors transform at each stage, from initial token embeddings (B, T) to final output probabilities (B, T, V).*

*Reference: [GPT-2 Detailed Model Architecture](https://medium.com/@hsinhungw/gpt-2-detailed-model-architecture-6b1aad33d16b)*

### Web Interface
- **Real-time Chat**: Interactive conversation with the GPT-2 model
- **Modern UI**: Clean, responsive design for optimal user experience
- **Model Loading**: Automatic loading of pretrained weights

## 🚀 Features
- **Complete GPT-2 Implementation**: Full transformer architecture with multi-head attention
- **Web Chat Interface**: Interactive web application to chat with the model
- **Pretrained Model Support**: Load and use pretrained GPT-2 weights
- **Modular Design**: Clean, well-documented code structure for learning

## 📁 Project Structure
```
├── model/                     # Core GPT-2 implementation
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


### Web Interface
1. Start the server: `python run_server.py`
2. Open browser to `http://localhost:7137`
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
