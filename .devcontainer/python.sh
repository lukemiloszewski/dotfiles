export PIPX_BIN_DIR="${PIPX_BIN_DIR}"
export PIPX_HOME="${PIPX_HOME}"
export PATH=${PATH}:${PIPX_BIN_DIR}

python_packages=("isort" "flake8" "black" "mypy" "pydocstyle" "bandit")

export PYTHONUSERBASE=/tmp/pip-tmp
export PIP_CACHE_DIR=/tmp/pip-tmp/cache
pipx_path=""
if ! type pipx > /dev/null 2>&1; then
    pip3 install --disable-pip-version-check --no-cache-dir --user pipx 2>&1
    /tmp/pip-tmp/bin/pipx install --pip-args=--no-cache-dir pipx
    pipx_path="/tmp/pip-tmp/bin/"
fi
for util in ${python_packages[@]}; do
    if ! type ${util} > /dev/null 2>&1; then
        ${pipx_path}pipx install --system-site-packages --pip-args '--no-cache-dir --force-reinstall' ${util}
    else
        echo "${util} already installed. Skipping."
    fi
done
rm -rf /tmp/pip-tmp

updaterc() {
    echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
    if [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
        echo -e "$1" >> /etc/bash.bashrc
    fi
    if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
        echo -e "$1" >> /etc/zsh/zshrc
    fi
}

updaterc "$(cat << EOF
export PIPX_BIN_DIR="${PIPX_BIN_DIR}"
export PIPX_HOME="${PIPX_HOME}"
if [[ "\${PATH}" != *"\${PIPX_BIN_DIR}"* ]]; then export PATH="\${PATH}:\${PIPX_BIN_DIR}"; fi
EOF
)"
