#!/usr/bin/env python3
import argparse
import gzip
import os
import platform
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--skip-apt', action='store_true', help='skip Ubuntu apt commands')
args = parser.parse_args()

dotfile_dir = Path(__file__).parent
config_dir = Path.home() / '.config'
data_dir = Path.home() / '.local/share'

if sys.platform == 'linux':
    distro = platform.freedesktop_os_release()['ID']
    assert distro == 'ubuntu', distro
elif sys.platform != 'darwin':
    sys.exit(f'Unexpected system {sys.platform}')
else:
    distro = None

symlinks = (
    ('bashrc', '.bashrc'),
    ('gitconfig', f'{config_dir}/git/config'),
    ('inputrc', f'{config_dir}/'),
    ('npmrc', f'{config_dir}/'),
    ('nvim', f'{config_dir}/'),
    ('ruff.toml', f'{config_dir}/ruff/'),
    ('tmux', f'{config_dir}/'),
    ('vim', '.vim'),
    ('zsh', f'{config_dir}/'),

    (f'{config_dir}/zsh/.zshenv', '.zshenv'),
)

for file, p in symlinks:
    path = Path(p)
    if not path.is_absolute():
        path = Path.home() / path
    if p.endswith('/'):
        path /= file
    target = Path(os.path.relpath(dotfile_dir / file, path.parent))
    if path.is_symlink() and target == Path(os.readlink(path)):
        continue
    rel_path = path.relative_to(Path.home())
    print(f'symlink {rel_path} to {target}')
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        if input(f'Replace {rel_path}? ') != 'y':
            continue
        path.unlink()
    path.symlink_to(target)

if sys.platform == 'linux' and distro == 'ubuntu' and not args.skip_apt:
    subprocess.run(['sudo', 'apt', 'install',
        'aptitude', 'curl', 'gcc', 'git', 'make', 'ncdu', 'openssh-server', 'vim', 'xclip', 'xsel', 'zsh',
    ], check=True)

if sys.platform == 'darwin' or (sys.platform == 'linux' and distro == 'ubuntu'):
    terms = {'mintty-direct', 'tmux-256color', 'tmux-direct', 'vte-direct'}
    def has_terminfo(term):
        return subprocess.run(['infocmp', term], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
    missing_terms = [term for term in sorted(terms) if not has_terminfo(term)]
    if missing_terms:
        with urllib.request.urlopen('http://invisible-island.net/datafiles/current/terminfo.src.gz') as req, tempfile.NamedTemporaryFile('wb') as fw:
            with gzip.open(req) as fr:
                shutil.copyfileobj(fr, fw)
            fw.flush()
            print('Adding missing terminfo:', *missing_terms)
            subprocess.run(['tic', '-x', '-e', ','.join(missing_terms), fw.name])
        assert all(has_terminfo(term) for term in missing_terms)

    subprocess.run(['brew', 'install',
        'bat', 'btop', 'choose-rust', 'eza', 'fd', 'fzf', 'hexyl', 'hyperfine', 'lua-language-server', 'neovim',
        'procs', 'pyright', 'ripgrep', 'ruff', 'tlrc', 'tmux', 'tree-sitter-cli', 'ty', 'uv', 'wget', 'zsh-syntax-highlighting',
    ], check=True)

# tmux
if not (tpm_dir := data_dir / 'tmux/plugins/tpm').exists():
    subprocess.run(['git', 'clone', 'https://github.com/tmux-plugins/tpm', tpm_dir], check=True)
    subprocess.run(tpm_dir / 'bin/install_plugins', check=True)

# vim
vim_env = dict(os.environ, ZDOTDIR=config_dir / 'zsh') # it's possible zshenv isn't sourced yet
if not (data_dir / 'vim/plugged').exists():
    subprocess.run(['vim', '+PlugInstall', '+qall'], env=vim_env, check=True)
