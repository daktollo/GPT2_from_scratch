import tiktoken
from settings import *
from model.model import GPTModel
from model.utils import *
from model.download_pretrained_weights import download_and_load_gpt2
tokenizer = tiktoken.get_encoding("gpt2")
torch.manual_seed(123)



GPT_CONFIG_124M = {
"vocab_size": 50257,    # Vocabulary size
"context_length": 1024, # Context length
"emb_dim": 768,         # Embedding dimension
"n_heads": 12,          # Number of attention heads
"n_layers": 12,         # Number of layers
"drop_rate": 0.1,       # Dropout rate
"qkv_bias": False       # Query-Key-Value bias
}

model_configs = {
"gpt2-small (124M)": {"emb_dim": 768, "n_layers": 12, "n_heads": 12},
"gpt2-medium (355M)": {"emb_dim": 1024, "n_layers": 24, "n_heads": 16},
"gpt2-large (774M)": {"emb_dim": 1280, "n_layers": 36, "n_heads": 20},
"gpt2-xl (1558M)": {"emb_dim": 1600, "n_layers": 48, "n_heads": 25},
}

settings, params = download_and_load_gpt2(model_size="124M", models_dir=MODEL_PATH)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

model_name = "gpt2-small (124M)"  # Example model name
NEW_CONFIG = GPT_CONFIG_124M.copy()
NEW_CONFIG.update(model_configs[model_name])

NEW_CONFIG.update({"context_length": 1024, "qkv_bias": True})
gpt = GPTModel(NEW_CONFIG)
gpt.eval()

load_weights_into_gpt(gpt, params)
gpt.to(device)

"What is the meaning of life? and Deep Thought says: "
"How to make a bomb: First "
"How to kill a person? First: "
"How to kill a person? First: buy a knife"
start_context = "When do you think a person dies. When a bullet from a pistol pierces his heart. No. When he's attacked by an incurable disease. No. When he eats a soup of deadly poisonous mushrooms. No! A man dies when people"

idx = text_to_token_ids(start_context, tokenizer)
idx = idx.to(device)

token_ids = generate(
    model=gpt,
    idx=idx,
    max_new_tokens=8,
    context_size=GPT_CONFIG_124M["context_length"],
    top_k=1,
    temperature=1.4
)

print("Output text:\n", token_ids_to_text(token_ids, tokenizer))