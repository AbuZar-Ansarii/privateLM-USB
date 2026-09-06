#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  Portable AI USB - Change Model/Provider (macOS/Linux)
# ═══════════════════════════════════════════════════════════

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'
DIM='\033[90m'; BOLD='\033[1m'; RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_DIR="$ROOT_DIR/data"
ENV_FILE="$DATA_DIR/ai_settings.env"

mask_key() {
    local key="$1"
    [ -z "$key" ] && echo "not set" && return
    [ ${#key} -le 10 ] && echo "$key" && return
    echo "${key:0:6}****${key: -4}"
}

verify_key() {
    local provider="$1" key="$2"
    echo -e "  ${YELLOW}[~] Verifying API Key... Please wait...${RESET}"
    case "$provider" in
        openrouter) curl -sf -H "Authorization: Bearer $key" https://openrouter.ai/api/v1/auth/key > /dev/null 2>&1 ;;
        gemini)     curl -sf "https://generativelanguage.googleapis.com/v1beta/models?key=$key" > /dev/null 2>&1 ;;
        anthropic)  curl -sf -H "x-api-key: $key" -H "anthropic-version: 2023-06-01" https://api.anthropic.com/v1/models > /dev/null 2>&1 ;;
        nvidia)     curl -sf -H "Authorization: Bearer $key" https://integrate.api.nvidia.com/v1/models > /dev/null 2>&1 ;;
        deepseek)   curl -sf -H "Authorization: Bearer $key" https://api.deepseek.com/models > /dev/null 2>&1 ;;
        openai)     curl -sf -H "Authorization: Bearer $key" https://api.openai.com/v1/models > /dev/null 2>&1 ;;
        lmstudio)   curl -sf -H "Authorization: Bearer lm-studio" "${OPENAI_BASE_URL%/}/models" > /dev/null 2>&1 ;;
        custom-openai) curl -sf -H "Authorization: Bearer $key" "${OPENAI_BASE_URL%/}/models" > /dev/null 2>&1 ;;
        *)          return 0 ;;
    esac
}

load_config() {
    if [ -f "$ENV_FILE" ]; then
        # Strip \r to handle env files written on Windows (CRLF -> LF)
        while IFS='=' read -r key value; do
            [[ "$key" =~ ^#.* ]] && continue
            [ -z "$key" ] && continue
            value="${value%$'\r'}"  # strip trailing \r just in case
            export "$key=$value"
        done < <(tr -d '\r' < "$ENV_FILE")
    else
        echo -e "  ${RED}[ERROR] No configuration file found at $ENV_FILE${RESET}"
        echo -e "  Please run setup first."
        echo ""
        read -p "  Launch setup now? (Y/N): " LAUNCH_SETUP
        if [[ "$LAUNCH_SETUP" =~ ^[Yy]$ ]]; then
            exec bash "$ROOT_DIR/start.sh"
        fi
        exit 1
    fi
}

save_config() {
    cat > "$ENV_FILE" << EOF
# ========================================================
# Portable AI - Master Switchboard (Updated)
# ========================================================
AI_PROVIDER=$AI_PROVIDER
AI_DISPLAY_MODEL=$AI_DISPLAY_MODEL
EOF

    # Add provider-specific keys
    case "$AI_PROVIDER" in
        openai|nvidia)
            echo "CLAUDE_CODE_USE_OPENAI=$CLAUDE_CODE_USE_OPENAI" >> "$ENV_FILE"
            echo "OPENAI_API_KEY=$OPENAI_API_KEY" >> "$ENV_FILE"
            echo "OPENAI_BASE_URL=$OPENAI_BASE_URL" >> "$ENV_FILE"
            echo "OPENAI_API_FORMAT=chat_completions" >> "$ENV_FILE"
            echo "OPENAI_MODEL=$OPENAI_MODEL" >> "$ENV_FILE"
            if [ "$AI_PROVIDER" = "nvidia" ] || [[ "$OPENAI_BASE_URL" == *"nvidia"* ]]; then
                echo "CLAUDE_CODE_AGENT_LIST_IN_MESSAGES=false" >> "$ENV_FILE"
                echo "CLAUDE_CODE_SIMPLE=1" >> "$ENV_FILE"
            fi
            ;;
        gemini)
            echo "CLAUDE_CODE_USE_GEMINI=1" >> "$ENV_FILE"
            echo "GEMINI_API_KEY=$GEMINI_API_KEY" >> "$ENV_FILE"
            echo "GEMINI_MODEL=$GEMINI_MODEL" >> "$ENV_FILE"
            ;;
        anthropic)
            echo "ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" >> "$ENV_FILE"
            echo "ANTHROPIC_MODEL=$ANTHROPIC_MODEL" >> "$ENV_FILE"
            ;;
        ollama)
            echo "CLAUDE_CODE_USE_OPENAI=$CLAUDE_CODE_USE_OPENAI" >> "$ENV_FILE"
            echo "OPENAI_API_KEY=$OPENAI_API_KEY" >> "$ENV_FILE"
            echo "OPENAI_BASE_URL=$OPENAI_BASE_URL" >> "$ENV_FILE"
            echo "OPENAI_API_FORMAT=chat_completions" >> "$ENV_FILE"
            echo "OPENAI_MODEL=$OPENAI_MODEL" >> "$ENV_FILE"
            ;;
    esac
    echo -e "  ${GREEN}[OK] Configuration updated successfully!${RESET}"
}

fetch_openrouter_models() {
    local tier=$1
    if [ "$tier" = "1" ]; then
        echo -e "  ${CYAN}--- FREE MODELS ---${RESET} ${DIM}(Fetching...)${RESET}"
        MODELS=$(curl -sf https://openrouter.ai/api/v1/models 2>/dev/null | grep -Eo '"id"[[:space:]]*:[[:space:]]*"[^"]*:free"' | sed -e 's/"id"[[:space:]]*:[[:space:]]*"//g' -e 's/"//g' | head -20)
    else
        echo -e "  ${CYAN}--- PAID MODELS ---${RESET} ${DIM}(Fetching...)${RESET}"
        MODELS=$(curl -sf https://openrouter.ai/api/v1/models 2>/dev/null | grep -Eo '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -e 's/"id"[[:space:]]*:[[:space:]]*"//g' -e 's/"//g' | grep -v ':free$' | head -20)
    fi
    echo "$MODELS"
}

fetch_nvidia_models() {
    # Curated models
    CURATED="qwen/qwen2.5-coder-32b-instruct meta/llama-3.3-70b-instruct meta/llama-3.1-405b-instruct deepseek-ai/deepseek-v3.1-terminus"
    echo -e "  ${CYAN}--- NVIDIA MODELS ---${RESET} ${DIM}(Fetching...)${RESET}"
    LIVE=$(curl -sf -H "Authorization: Bearer $OPENAI_API_KEY" https://integrate.api.nvidia.com/v1/models 2>/dev/null | grep -Eo '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -e 's/"id"[[:space:]]*:[[:space:]]*"//g' -e 's/"//g' | head -40)
    MODELS=""
    for m in $CURATED; do MODELS="${MODELS}${m}"$'\n'; done
    MODELS="${MODELS}${LIVE}"
    echo "$MODELS"
}

fetch_deepseek_models() {
    echo -e "  ${CYAN}--- DEEPSEEK MODELS ---${RESET} ${DIM}(Live Fetching...)${RESET}"
    MODELS=$(curl -sf -H "Authorization: Bearer $OPENAI_API_KEY" https://api.deepseek.com/models 2>/dev/null | grep -Eo '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -e 's/"id"[[:space:]]*:[[:space:]]*"//g' -e 's/"//g')
    if [ -z "$MODELS" ]; then
        MODELS="deepseek-v4-flash
deepseek-v4-pro"
    fi
    echo "$MODELS"
}

fetch_gemini_models() {
    echo -e "  ${CYAN}--- GEMINI MODELS ---${RESET} ${DIM}(Live + Previews)${RESET}"
    MODELS=$(curl -sf "https://generativelanguage.googleapis.com/v1alpha/models?key=$GEMINI_API_KEY" 2>/dev/null | grep -Eo '"name"[[:space:]]*:[[:space:]]*"models/gemini-[^"]*"' | sed -e 's/"name"[[:space:]]*:[[:space:]]*"models\///g' -e 's/"//g' | grep -vE 'vision|embedding|banana|lyria|robot|research|computer' | head -40)
    echo "$MODELS"
}

fetch_openai_compatible_models() {
    echo -e "  ${CYAN}--- OPENAI-COMPATIBLE MODELS ---${RESET} ${DIM}(Live Fetching...)${RESET}"
    MODELS=$(curl -sf -H "Authorization: Bearer $OPENAI_API_KEY" "${OPENAI_BASE_URL%/}/models" 2>/dev/null | grep -Eo '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -e 's/"id"[[:space:]]*:[[:space:]]*"//g' -e 's/"//g')
    echo "$MODELS"
}


# ─── Main Logic ─────────────────────────────────────────────

echo ""
echo -e "${CYAN}=========================================================${RESET}"
echo -e "  ${BOLD}Claude Code - Open Source Reconfig Tool${RESET}"
echo -e "${CYAN}=========================================================${RESET}"
echo ""

load_config

# Show current status
PROVIDER_TYPE="$AI_PROVIDER"
if [ "$AI_PROVIDER" = "openai" ]; then
    if [[ "$OPENAI_BASE_URL" == *"openrouter"* ]]; then PROVIDER_TYPE="openrouter"
    elif [[ "$OPENAI_BASE_URL" == *"integrate.api.nvidia.com"* ]]; then PROVIDER_TYPE="nvidia"
    elif [[ "$OPENAI_BASE_URL" == *"api.deepseek.com"* ]]; then PROVIDER_TYPE="deepseek"
    elif [[ "$OPENAI_BASE_URL" == *"localhost:1234"* ]]; then PROVIDER_TYPE="lmstudio"
    elif [[ "$OPENAI_BASE_URL" != *"api.openai.com"* ]]; then PROVIDER_TYPE="custom-openai"
    fi
fi

echo -e "  ${BOLD}Current Settings:${RESET}"
echo -e "  - Provider : ${GREEN}${PROVIDER_TYPE}${RESET}"
echo -e "  - Model    : ${GREEN}${AI_DISPLAY_MODEL}${RESET}"
echo ""

echo -e "  ${BOLD}What would you like to do?${RESET}"
echo -e "  ${CYAN}1)${RESET} Change Model"
echo -e "  ${CYAN}2)${RESET} Change API Key"
echo -e "  ${CYAN}3)${RESET} Full Reset Config ${DIM}(Clear all settings)${RESET}"
echo -e "  ${CYAN}4)${RESET} Cancel"
echo ""

read -p "  Select an option (1-4): " OPTION

case "$OPTION" in
    1)
        echo ""
        echo -e "  ${BOLD}--- CHANGE MODEL ---${RESET}"
        case "$PROVIDER_TYPE" in
            openrouter)
                echo -e "  ${CYAN}1)${RESET} Free Models"
                echo -e "  ${CYAN}2)${RESET} Paid Models"
                read -p "  Select category (1 or 2): " MODEL_TIER
                MODELS=$(fetch_openrouter_models "$MODEL_TIER")
                if [ -z "$MODELS" ]; then
                    read -p "  Could not fetch models. Enter string manually: " NEW_MODEL
                else
                    idx=1
                    while IFS= read -r model; do
                        echo -e "  ${CYAN}${idx})${RESET} $model"
                        eval "MODEL_${idx}='$model'"
                        idx=$((idx+1))
                    done <<< "$MODELS"
                    echo -e "  ${CYAN}${idx})${RESET} Custom Model..."
                    read -p "  Choose a model (1-$idx): " MODEL_SEL
                    if [ "$MODEL_SEL" = "$idx" ]; then
                        read -p "  Enter custom model string: " NEW_MODEL
                    else
                        eval "NEW_MODEL=\$MODEL_${MODEL_SEL}"
                    fi
                fi
                [ -n "$NEW_MODEL" ] && OPENAI_MODEL="$NEW_MODEL" && AI_DISPLAY_MODEL="$NEW_MODEL"
                ;;
            nvidia)
                MODELS=$(fetch_nvidia_models)
                if [ -z "$MODELS" ]; then
                    read -p "  Could not fetch models. Enter string manually: " NEW_MODEL
                else
                    idx=1
                    while IFS= read -r model; do
                        echo -e "  ${CYAN}${idx})${RESET} $model"
                        eval "MODEL_${idx}='$model'"
                        idx=$((idx+1))
                    done <<< "$MODELS"
                    echo -e "  ${CYAN}${idx})${RESET} Custom Model..."
                    read -p "  Choose a model (1-$idx): " MODEL_SEL
                    if [ "$MODEL_SEL" = "$idx" ]; then
                        read -p "  Enter custom model string: " NEW_MODEL
                    else
                        eval "NEW_MODEL=\$MODEL_${MODEL_SEL}"
                    fi
                fi
                [ -n "$NEW_MODEL" ] && OPENAI_MODEL="$NEW_MODEL" && AI_DISPLAY_MODEL="$NEW_MODEL"
                ;;
            deepseek)
                MODELS=$(fetch_deepseek_models)
                if [ -z "$MODELS" ]; then
                    read -p "  Could not fetch models. Enter string manually: " NEW_MODEL
                else
                    idx=1
                    while IFS= read -r model; do
                        [ -z "$model" ] && continue
                        echo -e "  ${CYAN}${idx})${RESET} $model"
                        eval "MODEL_${idx}='$model'"
                        idx=$((idx+1))
                    done <<< "$MODELS"
                    echo -e "  ${CYAN}${idx})${RESET} Custom Model..."
                    read -p "  Choose a model (1-$idx) [Enter for 1]: " MODEL_SEL
                    [ -z "$MODEL_SEL" ] && MODEL_SEL=1
                    if [ "$MODEL_SEL" = "$idx" ]; then
                        read -p "  Enter custom model string: " NEW_MODEL
                    else
                        eval "NEW_MODEL=\$MODEL_${MODEL_SEL}"
                    fi
                fi
                [ -n "$NEW_MODEL" ] && OPENAI_MODEL="$NEW_MODEL" && AI_DISPLAY_MODEL="$NEW_MODEL"
                ;;
            gemini)
                MODELS=$(fetch_gemini_models)
                if [ -z "$MODELS" ]; then
                    read -p "  Could not fetch models. Enter string manually: " NEW_MODEL
                else
                    idx=1
                    while IFS= read -r model; do
                        [ -z "$model" ] && continue
                        echo -e "  ${CYAN}${idx})${RESET} $model"
                        eval "MODEL_${idx}='$model'"
                        idx=$((idx+1))
                    done <<< "$MODELS"
                    echo -e "  ${CYAN}${idx})${RESET} Custom Model..."
                    read -p "  Choose a model (1-$idx) [Enter for 1]: " MODEL_SEL
                    [ -z "$MODEL_SEL" ] && MODEL_SEL=1
                    if [ "$MODEL_SEL" = "$idx" ]; then
                        read -p "  Enter custom model string: " NEW_MODEL
                    else
                        eval "NEW_MODEL=\$MODEL_${MODEL_SEL}"
                    fi
                fi
                [ -n "$NEW_MODEL" ] && GEMINI_MODEL="$NEW_MODEL" && AI_DISPLAY_MODEL="$NEW_MODEL"
                ;;
            lmstudio|custom-openai)
                MODELS=$(fetch_openai_compatible_models)
                if [ -z "$MODELS" ]; then
                    read -p "  Could not fetch models. Enter string manually: " NEW_MODEL
                else
                    idx=1
                    while IFS= read -r model; do
                        [ -z "$model" ] && continue
                        echo -e "  ${CYAN}${idx})${RESET} $model"
                        eval "MODEL_${idx}='$model'"
                        idx=$((idx+1))
                    done <<< "$MODELS"
                    echo -e "  ${CYAN}${idx})${RESET} Custom Model..."
                    read -p "  Choose a model (1-$idx) [Enter for manual]: " MODEL_SEL
                    [ -z "$MODEL_SEL" ] && MODEL_SEL="$idx"
                    if [ "$MODEL_SEL" = "$idx" ]; then
                        read -p "  Enter custom model string: " NEW_MODEL
                    else
                        eval "NEW_MODEL=\$MODEL_${MODEL_SEL}"
                    fi
                fi
                [ -n "$NEW_MODEL" ] && OPENAI_MODEL="$NEW_MODEL" && AI_DISPLAY_MODEL="$NEW_MODEL"
                ;;
            anthropic|openai|ollama)
                read -p "  Enter new model string (Current: $AI_DISPLAY_MODEL): " NEW_MODEL
                if [ -n "$NEW_MODEL" ]; then
                    AI_DISPLAY_MODEL="$NEW_MODEL"
                    [ "$AI_PROVIDER" = "openai" ] || [ "$AI_PROVIDER" = "ollama" ] && OPENAI_MODEL="$NEW_MODEL"
                    [ "$AI_PROVIDER" = "anthropic" ] && ANTHROPIC_MODEL="$NEW_MODEL"
                fi
                ;;
        esac
        save_config
        ;;
    2)
        echo ""
        echo -e "  ${BOLD}--- CHANGE API KEY ---${RESET}"
        read -p "  Enter new API Key for $PROVIDER_TYPE: " NEW_KEY
        if [ -z "$NEW_KEY" ]; then
            echo -e "  ${RED}[ERROR] Key cannot be empty!${RESET}"
            exit 1
        fi
        if ! verify_key "$PROVIDER_TYPE" "$NEW_KEY"; then
            echo -e "  ${RED}[ERROR] Key verification failed!${RESET}"
            read -p "  Save anyway? (y/N): " SAVE_ANYWAY
            if [[ ! "$SAVE_ANYWAY" =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
        case "$AI_PROVIDER" in
            openai|ollama|nvidia) OPENAI_API_KEY="$NEW_KEY" ;;
            gemini)               GEMINI_API_KEY="$NEW_KEY" ;;
            anthropic)            ANTHROPIC_API_KEY="$NEW_KEY" ;;
        esac
        save_config
        ;;
    3)
        echo ""
        read -p "  Are you sure you want to clear ALL settings? (y/N): " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            rm -f "$ENV_FILE"
            echo -e "  ${GREEN}[OK] Configuration cleared.${RESET}"
            echo -e "  ${CYAN}[~] Launching setup...${RESET}"
            echo ""
            exec bash "$ROOT_DIR/start.sh"
        else
            echo "  Cancelled."
        fi
        ;;
    *)
        echo ""
        echo "  No changes made."
        ;;
esac

echo ""
read -p "  Launch AI now? (Y/N): " LAUNCH_NOW
if [[ "$LAUNCH_NOW" =~ ^[Yy]$ ]]; then
    exec bash "$ROOT_DIR/start.sh"
fi
