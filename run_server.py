#!/usr/bin/env python3
"""
GPT-2 Server
This script starts the Flask web server for either the chat interface or completion interface.
Usage:
    python run_server.py chat     
    python run_server.py completion
"""
from settings import *
import sys
import os
import argparse
import threading
import time

sys.path.append(os.path.dirname(__file__))

def run_chat_server():
    """Run the chat interface server"""
    from web.chat_ui.app import app as chat_app, load_gpt_model as load_chat_model
    print("Loading GPT-2 model for chat interface...")
    load_chat_model()
    print(f"Starting Chat UI on http://localhost:{PORT}")
    chat_app.run(host=HOST, port=PORT, debug=DEBUG, use_reloader=False)

def run_completion_server():
    """Run the completion interface server"""
    from web.completion_ui.app import app as completion_app, load_gpt_model as load_completion_model
    print("Loading GPT-2 model for completion interface...")
    load_completion_model()
    print(f"Starting Completion UI on http://localhost:{PORT}")
    completion_app.run(host=HOST, port=PORT, debug=DEBUG, use_reloader=False)

def main():
    parser = argparse.ArgumentParser(description='GPT-2 Web Interface Server')
    parser.add_argument('mode', choices=['chat', 'completion'], 
                       help='Which interface to run: chat or completion')
    
    args = parser.parse_args()
    
    if args.mode == 'chat':
        run_chat_server()
    elif args.mode == 'completion':
        run_completion_server()
    else:
        raise ValueError("Invalid mode. Choose 'chat' or 'completion'.")

if __name__ == '__main__':
    main()