# ~/.config/zsh/plugins/gsh.zsh
GSH_CACHE="$HOME/.cache/gsh_cache.txt"

function shellgpt() {
    local query="$*"
    
    # Check for API key
    if [[ -z "$OPENAI_API_KEY" ]]; then
        echo "❌ OPENAI_API_KEY is not set." >&2
        return 1
    fi
    
    # Validate query
    if [[ -z "$query" ]]; then
        echo "❌ Please provide a query." >&2
        echo "Usage: gsh <command description>" >&2
        return 1
    fi
    
    # Create cache directory if it doesn't exist
    mkdir -p "$(dirname "$GSH_CACHE")"
    
    echo "🔄 Fetching commands from OpenAI..."
    
    # Make API call with better error handling
    local response
    response=$(curl -s --fail https://api.openai.com/v1/chat/completions \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
          "model": "gpt-4",
          "messages": [{"role": "user", "content": "Give me 3 numbered shell commands to: '"$query"'"}],
          "temperature": 0.3
      }')
    
    local curl_status=$?
    
    # Check if curl failed
    if [[ $curl_status -ne 0 ]]; then
        echo "❌ Failed to connect to OpenAI API (curl error: $curl_status)" >&2
        return 1
    fi
    
    # Check for API errors in response
    if echo "$response" | grep -q '"error"'; then
        local error_message=$(echo "$response" | grep -o '"message":"[^"]*"' | head -1 | sed 's/"message":"//;s/"$//')
        echo "❌ API Error: ${error_message:-Unknown error}" >&2
        return 1
    fi
    
    # Parse the content using jq if available, else fallback to Python
    local content
    if command -v jq &>/dev/null; then
        content=$(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null)
    else
        content=$(python3 -c 'import json, sys; print(json.loads(sys.stdin.read())["choices"][0]["message"]["content"])' <<< "$response" 2>/dev/null)
    fi
    
    # If both methods fail, try grep/sed fallback
    if [[ -z "$content" ]]; then
        content=$(echo "$response" | grep -o '"content":"[^"]*"' | head -1 | sed 's/"content":"//;s/"$//' | sed 's/\\n/\n/g' | sed 's/\\\"/"/g')
        
        if [[ -z "$content" ]]; then
            echo "❌ Failed to parse API response." >&2
            return 1
        fi
    fi
    
    # Display commands
    echo "\n🧠 Available Commands:\n"
    echo "$content"
    echo
    
    # Interactive command selection with improved UX
    local selection
    while true; do
        echo -n "Enter command number (1-3) or q to quit: "
        read -r selection
        
        if [[ "$selection" =~ ^[1-3]$ ]] || [[ "$selection" == "q" ]]; then
            break
        else
            echo "❌ Invalid input. Please enter 1, 2, 3, or q." >&2
        fi
    done
    
    if [[ "$selection" == "q" ]]; then
        echo "❌ No command selected."
        return 1
    fi
    
    # Get the selected command line (improved pattern matching)
    local line=$(echo "$content" | grep -E "^$selection\." | head -1)
    
    if [[ -z "$line" ]]; then
        echo "❌ Invalid selection." >&2
        return 1
    fi
    
    # Extract command from the line - FIXED METHOD
    local command=$(echo "$line" | grep -o '`[^`]*`' | head -1 | sed 's/^`//;s/`$//')
    
    # If no command found in backticks, look for it in code blocks
    if [[ -z "$command" ]]; then
        command=$(echo "$content" | grep -E -A 2 "^$selection\." | grep -E '^```' -A 1 | grep -v '^```' | sed 's/^[ ]*//;s/[ ]*$//' | head -1)
    fi
    
    # Final validation
    if [[ -z "$command" ]]; then
        echo "❌ Could not extract command from the selected line." >&2
        return 1
    fi
    
    echo "\n🧠 Selected Command:\n"
    echo "$command"
    
    # Save to cache with timestamp
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $query | $command" >> "$GSH_CACHE"
    
    # Copy to clipboard with multiple tool support
    if command -v xclip &>/dev/null; then
        echo -n "$command" | xclip -selection clipboard
        echo "\n📋 Copied to clipboard (xclip). Paste and run manually if desired."
    elif command -v pbcopy &>/dev/null; then
        echo -n "$command" | pbcopy
        echo "\n📋 Copied to clipboard (pbcopy). Paste and run manually if desired."
    elif command -v clip.exe &>/dev/null; then
        echo -n "$command" | clip.exe
        echo "\n📋 Copied to clipboard (Windows). Paste and run manually if desired."
    else
        echo "\n📋 No clipboard tool available. You'll need to copy the command manually."
    fi
    
    # Optional: Offer to execute directly
    echo -n "\nExecute now? (y/N): "
    read -r execute_now
    if [[ "$execute_now" =~ ^[Yy]$ ]]; then
        echo "\n🚀 Executing:"
        echo "$command"
        eval "$command"
    fi
}

# Create aliases
alias gsh="shellgpt"
alias shellgpt-clear="rm -f \"$GSH_CACHE\""
alias shellgpt-history="cat \"$GSH_CACHE\""