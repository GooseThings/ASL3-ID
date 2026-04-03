#!/bin/bash

NODE="1234"           # Change to your Node Number
SOUND_FILE="/var/lib/asterisk/sounds/alert" # Path without extension
INTERVAL_SEC=600      # 10 minutes (600 seconds)
IDLE_DELAY_SEC=120    # 2 minutes (120 seconds)

is_active() {
    # Returns 1 if the node is keyed/active, 0 if idle
    # ASL3 'rpt nodes' lists keyed nodes; grep checks if our node is in that list
    asterisk -rx "rpt nodes $NODE" | grep -q "KEYED"
    return $?
}

play_sound() {
    # Uses the asterisk CLI to play a sound locally
    asterisk -rx "rpt localplay $NODE $SOUND_FILE"
}

STATE="IDLE"
LAST_ACTIVE_TIME=0

while true; do
    if is_active; then
        if [ "$STATE" == "IDLE" ]; then
            # TRANSITION: IDLE -> ACTIVE (Initial transmission)
            play_sound
            STATE="ACTIVE"
            LAST_ACTIVE_TIME=$(date +%s)
        else
            # CONTINUOUS ACTIVITY: Check if 10 minutes passed
            CURRENT_TIME=$(date +%s)
            ELAPSED=$((CURRENT_TIME - LAST_ACTIVE_TIME))
            if [ $ELAPSED -ge $INTERVAL_SEC ]; then
                play_sound
                LAST_ACTIVE_TIME=$CURRENT_TIME
            fi
        fi
        # Reset idle timer since we are active
        IDLE_START_TIME=0
    else
        if [ "$STATE" == "ACTIVE" ]; then
            # TRANSITION: ACTIVE -> PENDING_IDLE
            if [ $IDLE_START_TIME -eq 0 ]; then
                IDLE_START_TIME=$(date +%s)
            fi
            
            CURRENT_TIME=$(date +%s)
            IDLE_ELAPSED=$((CURRENT_TIME - IDLE_START_TIME))
            
            if [ $IDLE_ELAPSED -ge $IDLE_DELAY_SEC ]; then
                # Node has been idle for 2 minutes
                play_sound
                STATE="IDLE"
                IDLE_START_TIME=0
            fi
        fi
    fi
    sleep 2 # Check state every 2 seconds
done
