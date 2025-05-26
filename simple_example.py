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
"qkv_bias": True       # Query-Key-Value bias
}

settings, params = download_and_load_gpt2(model_size="124M", models_dir=MODEL_PATH)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

gpt = GPTModel(GPT_CONFIG_124M)
gpt.eval()

load_weights_into_gpt(gpt, params)
gpt.to(device)

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