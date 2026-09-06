@echo off
setlocal enabledelayedexpansion
title Portable AI USB - Reconfigure

:: Define ANSI Colors
for /F %%a in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%a"
set "CYAN=!ESC![36m"
set "GREEN=!ESC![32m"
set "YELLOW=!ESC![33m"
set "RED=!ESC![31m"
set "DIM=!ESC![90m"
set "RESET=!ESC![0m"
set "BOLD=!ESC![1m"

set "USB_ROOT=%~dp0..\"
set "DATA_DIR=%USB_ROOT%data"
set "ENV_FILE=%DATA_DIR%\ai_settings.env"

:load_config
if exist "%ENV_FILE%" (
    for /f "usebackq tokens=1,* delims==" %%A in ("%ENV_FILE%") do (
        set "%%A=%%B"
    )
) else (
    echo !RED![ERROR] No configuration found.!RESET!
    pause
    goto do_reset
)

:main_menu
cls
echo.
echo !CYAN!=========================================================!RESET!
echo   !BOLD!Claude Code - Open Source Reconfig Tool!RESET!
echo !CYAN!=========================================================!RESET!
echo.
echo   !BOLD!Current Settings:!RESET!
set "PROVIDER_TYPE=!AI_PROVIDER!"
if "!AI_PROVIDER!"=="openai" (
    echo !OPENAI_BASE_URL! | findstr /C:"openrouter" >nul && set "PROVIDER_TYPE=openrouter"
    echo !OPENAI_BASE_URL! | findstr /C:"integrate.api.nvidia.com" >nul && set "PROVIDER_TYPE=nvidia"
    echo !OPENAI_BASE_URL! | findstr /C:"api.deepseek.com" >nul && set "PROVIDER_TYPE=deepseek"
    echo !OPENAI_BASE_URL! | findstr /C:"localhost:1234" >nul && set "PROVIDER_TYPE=lmstudio"
    if "!PROVIDER_TYPE!"=="openai" (
        echo !OPENAI_BASE_URL! | findstr /C:"api.openai.com" >nul || set "PROVIDER_TYPE=custom-openai"
    )
)
echo   - Provider : !GREEN!!PROVIDER_TYPE!!RESET!
echo   - Model    : !GREEN!!AI_DISPLAY_MODEL!!RESET!
echo.
echo   !BOLD!What would you like to do?!RESET!
echo   !CYAN!1^)!RESET! Change Model
echo   !CYAN!2^)!RESET! Change API Key
echo   !CYAN!3^)!RESET! Full Reset Config !DIM!(Clear all settings)!RESET!
echo   !CYAN!4^)!RESET! Cancel
echo.

choice /C 1234 /N /M "  Select an option (1-4): "
if errorlevel 4 goto exit
if errorlevel 3 goto do_reset
if errorlevel 2 goto change_key
if errorlevel 1 goto change_model

:change_model
echo.
echo   !BOLD!--- CHANGE MODEL ---!RESET!
if "!PROVIDER_TYPE!"=="openrouter" goto mode_openrouter
if "!PROVIDER_TYPE!"=="nvidia" goto mode_nvidia
if "!PROVIDER_TYPE!"=="deepseek" goto mode_deepseek
if "!PROVIDER_TYPE!"=="gemini" goto mode_gemini
if "!PROVIDER_TYPE!"=="lmstudio" goto mode_openai_compatible
if "!PROVIDER_TYPE!"=="custom-openai" goto mode_openai_compatible

:mode_default
set /p "NEW_MODEL=  Enter new model string (Current: !AI_DISPLAY_MODEL!): "
if not "!NEW_MODEL!"=="" (
    set "AI_DISPLAY_MODEL=!NEW_MODEL!"
    if "!AI_PROVIDER!"=="openai" set "OPENAI_MODEL=!NEW_MODEL!"
    if "!AI_PROVIDER!"=="ollama" set "OPENAI_MODEL=!NEW_MODEL!"
    if "!AI_PROVIDER!"=="anthropic" set "ANTHROPIC_MODEL=!NEW_MODEL!"
)
goto save_and_exit

:mode_openai_compatible
echo   !CYAN!--- OPENAI-COMPATIBLE MODELS ---!RESET! !DIM!(Live Fetching...)!RESET!
set "idx=1"
set "FETCH_CMD=$headers = @{ 'Authorization' = 'Bearer !OPENAI_API_KEY!' }; try { $d = (Invoke-RestMethod -Uri '!OPENAI_BASE_URL!/models' -Headers $headers).data; $d | Select-Object -ExpandProperty id } catch { }"
for /f "delims=" %%I in ('powershell -NoProfile -Command "!FETCH_CMD!"') do (
    set "MODEL_!idx!=%%I"
    echo   !CYAN!!idx!^)!RESET! %%I
    set /a "idx+=1"
)
set "MAX_IDX=!idx!"
echo   !CYAN!!MAX_IDX!^)!RESET! Manual Model...

set "NEW_MODEL="
set /p "MODEL_SEL=  Choose a model (1-!MAX_IDX!) [Enter for manual]: "
if not defined MODEL_SEL set "MODEL_SEL=!MAX_IDX!"
if "!MODEL_SEL!"=="" set "MODEL_SEL=!MAX_IDX!"
if "!MODEL_SEL!"=="!MAX_IDX!" (
    set /p "NEW_MODEL=  Enter model string: "
) else (
    for %%V in (!MODEL_SEL!) do set "NEW_MODEL=!MODEL_%%V!"
)
if not "!NEW_MODEL!"=="" (
    set "OPENAI_MODEL=!NEW_MODEL!"
    set "AI_DISPLAY_MODEL=!NEW_MODEL!"
)
goto save_and_exit

:mode_deepseek
echo   !CYAN!--- DEEPSEEK MODELS ---!RESET! !DIM!(Live Fetching...)!RESET!
set "idx=1"
set "FETCH_CMD=$headers = @{ 'Authorization' = 'Bearer !OPENAI_API_KEY!' }; try { $d = (Invoke-RestMethod -Uri 'https://api.deepseek.com/models' -Headers $headers).data; $d | Select-Object -ExpandProperty id } catch { }"
for /f "delims=" %%I in ('powershell -NoProfile -Command "!FETCH_CMD!"') do (
    set "MODEL_!idx!=%%I"
    echo   !CYAN!!idx!^)!RESET! %%I
    set /a "idx+=1"
)
if "!idx!"=="1" (
    echo   !YELLOW![API Error] Could not fetch models, using fallback...!RESET!
    set "MODEL_1=deepseek-v4-flash"
    echo   !CYAN!1^)!RESET! deepseek-v4-flash
    set "MODEL_2=deepseek-v4-pro"
    echo   !CYAN!2^)!RESET! deepseek-v4-pro
    set /a "idx=3"
)
set "MAX_IDX=!idx!"
echo   !CYAN!!MAX_IDX!^)!RESET! Custom Model...

set "NEW_MODEL="
set /p "MODEL_SEL=  Choose a model (1-!MAX_IDX!) [Enter for 1]: "
if not defined MODEL_SEL set "MODEL_SEL=1"
if "!MODEL_SEL!"=="" set "MODEL_SEL=1"
if "!MODEL_SEL!"=="!MAX_IDX!" (
    set /p "NEW_MODEL=  Enter custom model string: "
) else (
    for %%V in (!MODEL_SEL!) do set "NEW_MODEL=!MODEL_%%V!"
)
if not "!NEW_MODEL!"=="" (
    set "OPENAI_MODEL=!NEW_MODEL!"
    set "AI_DISPLAY_MODEL=!NEW_MODEL!"
)
goto save_and_exit

:mode_gemini
echo   !CYAN!--- GEMINI MODELS ---!RESET! !DIM!(Live + Previews)!RESET!
set "idx=1"
set "FETCH_CMD=$d = (Invoke-RestMethod 'https://generativelanguage.googleapis.com/v1alpha/models?key=!GEMINI_API_KEY!').models; if ($null -ne $d) { $d | Where-Object { $_.supportedGenerationMethods -contains 'generateContent' -and $_.name -notmatch 'vision|embedding|banana|lyria|robot|research|computer' } | Select-Object -ExpandProperty name | ForEach-Object { $_.Replace('models/', '') } | Select-Object -First 40 }"
for /f "delims=" %%I in ('powershell -NoProfile -Command "!FETCH_CMD!"') do (
    set "MODEL_!idx!=%%I"
    echo   !CYAN!!idx!^)!RESET! %%I
    set /a "idx+=1"
)
set "MAX_IDX=!idx!"
echo   !CYAN!!MAX_IDX!^)!RESET! Custom Model...

set "NEW_MODEL="
set /p "MODEL_SEL=  Choose a model (1-!MAX_IDX!): "
if defined MODEL_SEL (
    if "!MODEL_SEL!"=="!MAX_IDX!" (
        set /p "NEW_MODEL=  Enter custom model string: "
    ) else (
        for %%V in (!MODEL_SEL!) do set "NEW_MODEL=!MODEL_%%V!"
    )
)
if not "!NEW_MODEL!"=="" (
    set "GEMINI_MODEL=!NEW_MODEL!"
    set "AI_DISPLAY_MODEL=!NEW_MODEL!"
)
goto save_and_exit

:mode_openrouter
echo   !CYAN!1^)!RESET! Free Models
echo   !CYAN!2^)!RESET! Paid Models
choice /C 12 /N /M "  Select category (1 or 2): "
if errorlevel 2 ( set "TIER=paid" ) else ( set "TIER=free" )

echo   !CYAN![~] Fetching !TIER! models...!RESET!
set "idx=1"
if "!TIER!"=="free" (
    set "PS_CMD=$d = (Invoke-RestMethod 'https://openrouter.ai/api/v1/models').data; $d | Where-Object { $_.id -match ':free$' } | Select-Object -First 20 -ExpandProperty id"
) else (
    set "PS_CMD=$d = (Invoke-RestMethod 'https://openrouter.ai/api/v1/models').data; $d | Where-Object { $_.id -notmatch ':free$' } | Select-Object -First 20 -ExpandProperty id"
)

for /f "delims=" %%I in ('powershell -NoProfile -Command "!PS_CMD!"') do (
    set "MODEL_!idx!=%%I"
    echo   !CYAN!!idx!^)!RESET! %%I
    set /a "idx+=1"
)
set "MAX_IDX=!idx!"
echo   !CYAN!!MAX_IDX!^)!RESET! Custom Model...

set "NEW_MODEL="
set /p "MODEL_SEL=  Choose a model (1-!MAX_IDX!): "
if defined MODEL_SEL (
    if "!MODEL_SEL!"=="!MAX_IDX!" (
        set /p "NEW_MODEL=  Enter custom model string: "
    ) else (
        for %%V in (!MODEL_SEL!) do set "NEW_MODEL=!MODEL_%%V!"
    )
)
if not "!NEW_MODEL!"=="" (
    set "OPENAI_MODEL=!NEW_MODEL!"
    set "AI_DISPLAY_MODEL=!NEW_MODEL!"
)
goto save_and_exit

:mode_nvidia
echo   !CYAN!--- NVIDIA MODELS ---!RESET! !DIM!(Live + Curated)!RESET!
set "idx=1"
for %%M in (
    "moonshotai/kimi-k2-instruct" "moonshotai/kimi-k2-thinking" "z-ai/glm4.7"
    "deepseek-ai/deepseek-v3.2" "deepseek-ai/deepseek-v3.1-terminus" "stepfun-ai/step-3.5-flash"
    "mistralai/mistral-large-3-675b-instruct-2512" "qwen/qwen3-coder-480b-a35b-instruct"
    "mistralai/mistral-nemotron" "bytedance/seed-oss-36b-instruct" "mistralai/mamba-codestral-7b-v0.1"
    "google/gemma-7b" "tiiuae/falcon3-7b-instruct" "minimaxai/minimax-m2.7"
) do (
    set "MODEL_!idx!=%%~M"
    echo   !CYAN!!idx!^)!RESET! %%~M
    set /a "idx+=1"
)
set "FETCH_CMD=$headers = @{ 'Authorization' = 'Bearer !OPENAI_API_KEY!' }; try { $d = (Invoke-RestMethod -Uri 'https://integrate.api.nvidia.com/v1/models' -Headers $headers).data; $d | Select-Object -ExpandProperty id | Select-Object -First 10 } catch { }"
for /f "delims=" %%I in ('powershell -NoProfile -Command "!FETCH_CMD!"') do (
    set "EXISTS=0"
    set "TEMP_ID=%%I"
    for /L %%K in (1,1,14) do (
        if "!TEMP_ID!"=="!MODEL_%%K!" set "EXISTS=1"
    )
    if "!EXISTS!"=="0" (
        set "MODEL_!idx!=!TEMP_ID!"
        echo   !CYAN!!idx!^)!RESET! !TEMP_ID!
        set /a "idx+=1"
    )
)
set "MAX_IDX=!idx!"
echo   !CYAN!!MAX_IDX!^)!RESET! Custom Model...

set "NEW_MODEL="
set /p "MODEL_SEL=  Choose a model (1-!MAX_IDX!): "
if defined MODEL_SEL (
    if "!MODEL_SEL!"=="!MAX_IDX!" (
        set /p "NEW_MODEL=  Enter custom model string: "
    ) else (
        for %%V in (!MODEL_SEL!) do set "NEW_MODEL=!MODEL_%%V!"
    )
)
if not "!NEW_MODEL!"=="" (
    set "OPENAI_MODEL=!NEW_MODEL!"
    set "AI_DISPLAY_MODEL=!NEW_MODEL!"
)
goto save_and_exit

:change_key
echo.
echo   !BOLD!--- CHANGE API KEY ---!RESET!
set /p "NEW_KEY=  Enter new API Key for !PROVIDER_TYPE!: "
if "!NEW_KEY!"=="" (
    echo   !RED![ERROR] Key cannot be empty!!RESET!
    pause
    goto main_menu
)

echo   !YELLOW![~] Verifying API Key...!RESET!
if "!PROVIDER_TYPE!"=="openrouter" (
    powershell -NoProfile -Command "$headers = @{ 'Authorization' = 'Bearer !NEW_KEY!' }; try { Invoke-RestMethod -Uri 'https://openrouter.ai/api/v1/auth/key' -Headers $headers -ErrorAction Stop; exit 0 } catch { exit 1 }"
) else if "!PROVIDER_TYPE!"=="gemini" (
    powershell -NoProfile -Command "try { Invoke-RestMethod -Uri 'https://generativelanguage.googleapis.com/v1beta/models?key=!NEW_KEY!' -ErrorAction Stop; exit 0 } catch { exit 1 }"
) else if "!PROVIDER_TYPE!"=="anthropic" (
    powershell -NoProfile -Command "$headers = @{ 'x-api-key' = '!NEW_KEY!'; 'anthropic-version' = '2023-06-01' }; try { Invoke-RestMethod -Uri 'https://api.anthropic.com/v1/models' -Headers $headers -ErrorAction Stop; exit 0 } catch { exit 1 }"
) else if "!PROVIDER_TYPE!"=="nvidia" (
    powershell -NoProfile -Command "$headers = @{ 'Authorization' = 'Bearer !NEW_KEY!' }; try { Invoke-RestMethod -Uri 'https://integrate.api.nvidia.com/v1/models' -Headers $headers -ErrorAction Stop; exit 0 } catch { exit 1 }"
) else if "!PROVIDER_TYPE!"=="deepseek" (
    powershell -NoProfile -Command "$headers = @{ 'Authorization' = 'Bearer !NEW_KEY!' }; try { Invoke-RestMethod -Uri 'https://api.deepseek.com/models' -Headers $headers -ErrorAction Stop; exit 0 } catch { exit 1 }"
) else if "!PROVIDER_TYPE!"=="lmstudio" (
    powershell -NoProfile -Command "try { Invoke-RestMethod -Uri '!OPENAI_BASE_URL!/models' -Headers @{ 'Authorization' = 'Bearer lm-studio' } -ErrorAction Stop; exit 0 } catch { exit 1 }"
) else if "!PROVIDER_TYPE!"=="custom-openai" (
    powershell -NoProfile -Command "$headers = @{ 'Authorization' = 'Bearer !NEW_KEY!' }; try { Invoke-RestMethod -Uri '!OPENAI_BASE_URL!/models' -Headers $headers -ErrorAction Stop; exit 0 } catch { exit 1 }"
) else if "!PROVIDER_TYPE!"=="openai" (
    powershell -NoProfile -Command "$headers = @{ 'Authorization' = 'Bearer !NEW_KEY!' }; try { Invoke-RestMethod -Uri 'https://api.openai.com/v1/models' -Headers $headers -ErrorAction Stop; exit 0 } catch { exit 1 }"
)

if errorlevel 1 (
    echo   !RED![ERROR] Key verification failed!!RESET!
    set /p "SAVE_ANYWAY=  Save anyway? (y/N): "
    if /I not "!SAVE_ANYWAY!"=="Y" goto main_menu
)

if "!AI_PROVIDER!"=="openai" set "OPENAI_API_KEY=!NEW_KEY!"
if "!AI_PROVIDER!"=="ollama" set "OPENAI_API_KEY=!NEW_KEY!"
if "!AI_PROVIDER!"=="gemini" set "GEMINI_API_KEY=!NEW_KEY!"
if "!AI_PROVIDER!"=="anthropic" set "ANTHROPIC_API_KEY=!NEW_KEY!"
goto save_and_exit

:save_and_exit
(
    echo # ========================================================
    echo # Portable AI - Master Switchboard ^(Updated^)
    echo # ========================================================
    echo AI_PROVIDER=!AI_PROVIDER!
    echo AI_DISPLAY_MODEL=!AI_DISPLAY_MODEL!

    if "!AI_PROVIDER!"=="openai" (
        echo CLAUDE_CODE_USE_OPENAI=!CLAUDE_CODE_USE_OPENAI!
        echo OPENAI_API_KEY=!OPENAI_API_KEY!
        echo OPENAI_BASE_URL=!OPENAI_BASE_URL!
        echo OPENAI_API_FORMAT=chat_completions
        echo OPENAI_MODEL=!OPENAI_MODEL!
    )
    if "!AI_PROVIDER!"=="gemini" (
        echo CLAUDE_CODE_USE_GEMINI=1
        echo GEMINI_API_KEY=!GEMINI_API_KEY!
        echo GEMINI_MODEL=!GEMINI_MODEL!
    )
    if "!AI_PROVIDER!"=="anthropic" (
        echo ANTHROPIC_API_KEY=!ANTHROPIC_API_KEY!
        echo ANTHROPIC_MODEL=!ANTHROPIC_MODEL!
    )
    if "!AI_PROVIDER!"=="ollama" (
        echo CLAUDE_CODE_USE_OPENAI=!CLAUDE_CODE_USE_OPENAI!
        echo OPENAI_API_KEY=!OPENAI_API_KEY!
        echo OPENAI_BASE_URL=!OPENAI_BASE_URL!
        echo OPENAI_API_FORMAT=chat_completions
        echo OPENAI_MODEL=!OPENAI_MODEL!
    )
) > "%ENV_FILE%"

echo.
echo   !GREEN![OK] Configuration updated successfully!!RESET!
goto ask_launch

:do_reset
set /p "CONFIRM=  Are you sure you want to clear ALL settings? (y/N): "
if /I not "!CONFIRM!"=="Y" goto main_menu
if exist "%ENV_FILE%" del "%ENV_FILE%"
echo   !GREEN![OK] Configuration cleared!!RESET!
goto launch_ai

:ask_launch
echo.
set /p "LAUNCH_NOW=  Launch AI now? (Y/N): "
if /I "!LAUNCH_NOW!"=="Y" goto launch_ai
exit /b

:launch_ai
echo.
echo   !CYAN![~] Launching setup/AI...!RESET!
call "%USB_ROOT%START.bat"
exit /b

:exit
exit /b
