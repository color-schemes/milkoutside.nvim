#!/usr/bin/env bash

# MilkOutside colors for Tmux

set -g mode-style "fg=#63c3dd,bg=#474747"

set -g message-style "fg=#63c3dd,bg=#474747"
set -g message-command-style "fg=#63c3dd,bg=#474747"

set -g pane-border-style "fg=#474747"
set -g pane-active-border-style "fg=#63c3dd"

set -g status "on"
set -g status-justify "left"

set -g status-style "fg=#63c3dd,bg=#000000"

set -g status-left-length "100"
set -g status-right-length "100"

set -g status-left-style NONE
set -g status-right-style NONE

set -g status-left "#[fg=#000000,bg=#63c3dd,bold] #S #[fg=#63c3dd,bg=#000000,nobold,nounderscore,noitalics]"
set -g status-right "#[fg=#000000,bg=#000000,nobold,nounderscore,noitalics]#[fg=#63c3dd,bg=#000000] #{prefix_highlight} #[fg=#474747,bg=#000000,nobold,nounderscore,noitalics]#[fg=#63c3dd,bg=#474747] %Y-%m-%d  %I:%M %p #[fg=#63c3dd,bg=#474747,nobold,nounderscore,noitalics]#[fg=#000000,bg=#63c3dd,bold] #h "
if-shell '[ "$(tmux show-option -gqv "clock-mode-style")" == "24" ]' {
  set -g status-right "#[fg=#000000,bg=#000000,nobold,nounderscore,noitalics]#[fg=#63c3dd,bg=#000000] #{prefix_highlight} #[fg=#474747,bg=#000000,nobold,nounderscore,noitalics]#[fg=#63c3dd,bg=#474747] %Y-%m-%d  %H:%M #[fg=#63c3dd,bg=#474747,nobold,nounderscore,noitalics]#[fg=#000000,bg=#63c3dd,bold] #h "
}

setw -g window-status-activity-style "underscore,fg=#e0e0e0,bg=#000000"
setw -g window-status-separator ""
setw -g window-status-style "NONE,fg=#e0e0e0,bg=#000000"
setw -g window-status-format "#[fg=#000000,bg=#000000,nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#000000,bg=#000000,nobold,nounderscore,noitalics]"
setw -g window-status-current-format "#[fg=#000000,bg=#474747,nobold,nounderscore,noitalics]#[fg=#63c3dd,bg=#474747,bold] #I  #W #F #[fg=#474747,bg=#000000,nobold,nounderscore,noitalics]"

# tmux-plugins/tmux-prefix-highlight support
set -g @prefix_highlight_output_prefix "#[fg=#f8e063]#[bg=#000000]#[fg=#000000]#[bg=#f8e063]"
set -g @prefix_highlight_output_suffix ""
