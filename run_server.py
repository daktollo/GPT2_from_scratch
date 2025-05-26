#!/usr/bin/env python3
"""
GPT-2 Chat Server
This script starts the Flask web server for the GPT-2 chat interface.
"""

import sys
import os
sys.path.append(os.path.dirname(__file__))

from web.app import app, load_gpt_model

if __name__ == '__main__':
    # Load the model before starting the server
    load_gpt_model()
    
    # Start the Flask application
    app.run(host='0.0.0.0', port=5000, debug=True)