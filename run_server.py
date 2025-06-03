#!/usr/bin/env python3
"""
GPT-2 Server
This script starts the Flask web server for either the chat interface or completion interface.
Usage:
    python run_server.py chat      # Start chat interface on port 5000
    python run_server.py completion # Start completion interface on port 5001
    python run_server.py both      # Start both interfaces (chat on 5000, completion on 5001)
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
    print("Starting Chat UI on http://localhost:5000")
    chat_app.run(host=HOST, port=5000, debug=False, use_reloader=False)

def run_completion_server():
    """Run the completion interface server"""
    from web.completion_ui.app import app as completion_app, load_gpt_model as load_completion_model
    print("Loading GPT-2 model for completion interface...")
    load_completion_model()
    print("Starting Completion UI on http://localhost:5001")
    completion_app.run(host=HOST, port=5001, debug=False, use_reloader=False)

def main():
    parser = argparse.ArgumentParser(description='GPT-2 Web Interface Server')
    parser.add_argument('mode', choices=['chat', 'completion', 'both'], 
                       help='Which interface to run: chat, completion, or both')
    
    args = parser.parse_args()
    
    if args.mode == 'chat':
        run_chat_server()
    elif args.mode == 'completion':
        run_completion_server()
    elif args.mode == 'both':
        print("Starting both Chat and Completion interfaces...")
        
        # Start chat server in a separate thread
        chat_thread = threading.Thread(target=run_chat_server)
        chat_thread.daemon = True
        chat_thread.start()
        
        # Give chat server time to start
        time.sleep(2)
        
        # Start completion server in main thread
        run_completion_server()

if __name__ == '__main__':
    main()