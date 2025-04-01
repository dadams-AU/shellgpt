# ~/.config/zsh/plugins/shellgpt.zsh
GSH_CACHE="$HOME/.cache/shellgpt_cache.txt"

function shellgpt() {
    local query="$*"
    if [[ -z "$OPENAI_API_KEY" ]]; then
        echo "❌ OPENAI_API_KEY is not set."
        return 1
    fi
    
    # Create cache directory if it doesn't exist
    mkdir -p "$(dirname "$GSH_CACHE")"
    
    echo "🔄 Fetching commands from OpenAI..."
    
    # Make API call 
    local response=$(curl -s https://api.openai.com/v1/chat/completions \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
          "model": "gpt-4",
          "messages": [{"role": "user", "content": "Give me 3 numbered shell commands to: '"$query"'"}],
          "temperature": 0.3
      }')
    
    # Check if API call was successful
    if echo "$response" | grep -q "error"; then
        echo "❌ API call failed with error"
        return 1
    fi
    
    # Parse the content using Python
    local content=$(python3 -c 'import json, sys; print(json.loads(sys.stdin.read())["choices"][0]["message"]["content"])' <<< "$response" 2>/dev/null)
    
    if [[ -z "$content" ]]; then
        # Fallback method if Python parsing fails
        content=$(echo "$response" | grep -o '"content":"[^"]*"' | head -1 | sed 's/"content":"//;s/"$//' | sed 's/\\n/\n/g' | sed 's/\\\"/"/g')
        
        if [[ -z "$content" ]]; then
            echo "❌ Failed to parse API response."
            return 1
        fi
    fi
    
    # Display commands
    echo "\n🧠 Available Commands:\n"
    echo "$content"
    echo
    
    # Prompt for selection
    echo -n "Enter command number (1-3) or q to quit: "
    read -r selection
    
    if [[ "$selection" == "q" ]]; then
        echo "❌ No command selected."
        return 1
    fi
    
    # Get the selected command line
    local line=$(echo "$content" | grep -E "^$selection\." || echo "$content" | grep -E "^$selection\)")
    
    if [[ -z "$line" ]]; then
        echo "❌ Invalid selection."
        return 1
    fi
    
    # Extract command from the line
    local command=$(echo "$line" | grep -o '`[^`]*`' | head -1 | sed 's/^`//;s/`$//')
    
    if [[ -z "$command" ]]; then
        command=$(echo "$line" | sed -E 's/^[0-9]+\.|\)//; s/:.*//')
    fi
    
    echo "\n🧠 Selected Command:\n"
    echo "$command"
    
    # Copy to clipboard if xclip is available
    if command -v xclip &>/dev/null; then
        echo -n "$command" | xclip -selection clipboard
        echo "\n📋 Copied to clipboard. Paste and run manually if desired."
    else
        echo "\n📋 No clipboard tool available. You'll need to copy the command manually."
    fi
}
