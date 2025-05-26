import torch.nn as nn
from model.layers import FeedForward, LayerNorm
from model.multihead_attention import MultiHeadAttention

class TransformerBlock(nn.Module):
    def __init__(self, conf):
        super().__init__()
        self.att = MultiHeadAttention(
            d_in=conf["emb_dim"],
            d_out=conf["emb_dim"],
            context_length=conf["context_length"],
            num_heads=conf["n_heads"], 
            dropout=conf["drop_rate"],
            qkv_bias=conf["qkv_bias"])
        self.ff = FeedForward(conf)
        self.norm1 = LayerNorm(conf["emb_dim"])
        self.norm2 = LayerNorm(conf["emb_dim"])
        self.drop_shortcut = nn.Dropout(conf["drop_rate"])

    def forward(self, x):
        # Shortcut connection for attention block
        shortcut = x
        x = self.norm1(x)
        x = self.att(x)  # Shape [batch_size, num_tokens, emb_size]
        x = self.drop_shortcut(x)
        x = x + shortcut  # Add the original input back

        # Shortcut connection for feed forward block
        shortcut = x
        x = self.norm2(x)
        x = self.ff(x)
        x = self.drop_shortcut(x)
        x = x + shortcut  # Add the original input back

        return x