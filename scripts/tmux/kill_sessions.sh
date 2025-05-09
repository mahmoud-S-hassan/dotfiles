#!/bin/bash

# Check if tmux is installed
if ! command -v tmux &>/dev/null; then
  echo "tmux is not installed. Please install tmux first."
  exit 1
fi

# Check if fzf is installed
if ! command -v fzf &>/dev/null; then
  echo "fzf is not installed. Please install fzf."
  exit 1
fi

# Check if there are any tmux sessions
sessions=$(tmux list-sessions -F "#S: #W windows (created #T) [#P panes]" 2>/dev/null)
if [[ -z "$sessions" ]]; then
  echo "No tmux sessions found."
  exit 0
fi

# Use fzf to select sessions (multi-select enabled with --multi)
selected_sessions=$(echo "$sessions" | fzf --multi --preview "tmux list-windows -t {1} && tmux list-panes -t {1}" --preview-window=up:50% --header="Select tmux sessions to kill (use TAB to select multiple)")

# Check if any sessions were selected
if [[ -z "$selected_sessions" ]]; then
  echo "No sessions selected. Exiting."
  exit 0
fi

# Extract session names from selected lines and kill them
while IFS= read -r line; do
  session_name=$(echo "$line" | cut -d':' -f1)
  echo "Killing session: $session_name"
  tmux kill-session -t "$session_name"
done <<<"$selected_sessions"

echo "Selected sessions have been killed."
