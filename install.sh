#!/bin/sh
# Script by Kwaita (MalikHw's gf) btw, pls praise me :3

# we need colors right?
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# detect OS
case "$(uname -s)" in
    Linux*)  
        OS="Linux"
        echo "${GREEN}detected OS: Linux${NC}"
        ;;
    Darwin*) 
        OS="macOS"
        echo "${GREEN}detected OS: macOS${NC}"
        ;;
    *)  
        echo "${RED}Bro what the fuck are you even running this on😭, i have no idea how to set up for your freebsd/temple/vibeOS/whatever but just run 'pip install hwgdreqs' itll work${NC}"
        exit 1
        ;;
esac

# check python existence and ver
PYTHON_CMD=""
if command -v python3 > /dev/null 2>&1; then
    PYTHON_CMD="python3"
elif command -v python > /dev/null 2>&1; then
    PYTHON_CMD="python"
fi

if [ -z "$PYTHON_CMD" ]; then
    if [ "$OS" = "Linux" ]; then
        echo "${RED}could not find python 3.12+, Please install it by your distribution's instructions and rerun the script${NC}"
    else
        echo "${RED}could not find python 3.12+, Please install it (from https://www.python.org/ftp/python/3.14.6/python-3.14.6-macos11.pkg) and rerun the script${NC}"
    fi
    exit 1
fi

# (must be 3.12+)
PYTHON_VERSION=$($PYTHON_CMD -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
MAJOR_VERSION=$(echo "$PYTHON_VERSION" | cut -d. -f1)
MINOR_VERSION=$(echo "$PYTHON_VERSION" | cut -d. -f2)

if [ "$MAJOR_VERSION" -lt 3 ] || { [ "$MAJOR_VERSION" -eq 3 ] && [ "$MINOR_VERSION" -lt 12 ]; }; then
    if [ "$OS" = "Linux" ]; then
        echo "${RED}could not find python 3.12+, Please install it by your distribution's instructions and rerun the script${NC}"
    else
        echo "${RED}could not find python 3.12+, Please install it (from https://www.python.org/ftp/python/3.14.6/python-3.14.6-macos11.pkg) and rerun the script${NC}"
    fi
    exit 1
fi

echo "${GREEN}Found Python $PYTHON_VERSION${NC}"

# setup venv path
VENV_PATH="$HOME/HwGDReqs-venv"

# check if venv already exists and has hwgdreqs
if [ -d "$VENV_PATH" ] && [ -f "$VENV_PATH/bin/activate" ]; then
    . "$VENV_PATH/bin/activate"
    if pip show hwgdreqs > /dev/null 2>&1; then
        echo "${YELLOW}Existing installation found. Updating...${NC}"
        pip install --upgrade hwgdreqs
        echo "${GREEN}updated!${NC}"
    else
        echo "${YELLOW}Venv exists but hwgdreqs not found. Installing...${NC}"
        pip install hwgdreqs
    fi
else
    # create venv
    echo "${YELLOW}Creating virtual environment...${NC}"
    $PYTHON_CMD -m venv "$VENV_PATH"
    
    # activate venv
    . "$VENV_PATH/bin/activate"
    
    # install hwgdreqs
    echo "${YELLOW}Installing HwGDReqs...${NC}"
    pip install hwgdreqs
fi

# create run dir and launcher script
mkdir -p "$VENV_PATH/run"
LAUNCHER_PATH="$VENV_PATH/run/hwgdreqs-run"

cat > "$LAUNCHER_PATH" << 'LAUNCHEREOF'
#!/bin/sh
VENV_PATH="$HOME/HwGDReqs-venv"
. "$VENV_PATH/bin/activate"
exec hwgdreqs "$@"
LAUNCHEREOF

chmod +x "$LAUNCHER_PATH"

# add to PATH based on available shell rc files
for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile" "$HOME/.zprofile"; do
    if [ -f "$rc" ]; then
        if ! grep -q "HwGDReqs-venv/run" "$rc" 2>/dev/null; then
            echo "export PATH=\"\$HOME/HwGDReqs-venv/run:\$PATH\"" >> "$rc"
            echo "${YELLOW}Added hwgdreqs-run to PATH in $rc${NC}"
        fi
    fi
done

# if no rc file exists, add to .profile (big brain moment)
if [ ! -f "$HOME/.zshrc" ] && [ ! -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.profile" ] && [ ! -f "$HOME/.zprofile" ]; then
    echo "export PATH=\"\$HOME/HwGDReqs-venv/run:\$PATH\"" >> "$HOME/.profile"
    echo "${YELLOW}Added hwgdreqs-run to PATH in ~/.profile${NC}"
fi

# linux-specific: desktop entry
if [ "$OS" = "Linux" ]; then
    ICON_DIR="$HOME/.local/share/icons"
    mkdir -p "$ICON_DIR"
    echo "${YELLOW}Downloading icon...${NC}"
    curl -fsSL -o "$ICON_DIR/hwgdreqs.png" "https://raw.githubusercontent.com/HwGDReqs/hwgdreqs-installer-assets/refs/heads/main/logo.png"
    
    DESKTOP_DIR="$HOME/.local/share/applications"
    mkdir -p "$DESKTOP_DIR"
    echo "${YELLOW}Creating desktop entry...${NC}"
    curl -fsSL -o "$DESKTOP_DIR/hwgdreqs.desktop" "https://raw.githubusercontent.com/HwGDReqs/hwgdreqs-installer-assets/refs/heads/main/hwgdreqs.desktop"
    
    echo ""
    echo "${GREEN}Alr HwGDReqs is installed! Run hwgdreqs-run or check your Applications folder!${NC}"
    echo ""
    echo "${GREEN}HwGDReqs by MalikHw47, this script is by Kwaita${NC}"
else
    echo ""
    echo "${GREEN}Alr HwGDReqs is installed! Run hwgdreqs-run! idk how the fuck to make a normal shortcut for yall ✨superiors✨, just use the command line not everyone has a mac :3${NC}"
    echo ""
    echo "${GREEN}HwGDReqs by MalikHw47, this script is by Kwaita${NC}"
fi
