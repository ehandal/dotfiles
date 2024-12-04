#!/usr/bin/env python3
import argparse
import gzip
import json
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

def get_github_release(repo: str, name_re: str, file: str):
    with urllib.request.urlopen(f'https://api.github.com/repos/{repo}/releases/latest') as req:
        release = json.load(req)
    release_name = release['name']
    assert isinstance(release_name, str), release_name
    m = re.fullmatch(name_re, release_name)
    assert m is not None, repo
    version = m.group(1)
    file = file.format(version=version)
    for asset in release['assets']:
        if asset['name'] == file:
            download_url = asset['browser_download_url']
            assert isinstance(download_url, str), download_url
            return version, download_url, file
    sys.exit(f'ERROR: no release found for github repo {repo}')

parser = argparse.ArgumentParser()
parser.add_argument('--pyenv', action='store_true', help='install pyenv')
parser.add_argument('--skip-apt', action='store_true', help='skip Ubuntu apt commands')
parser.add_argument('--vim-ppa', action='store_true', help='add vim PPA')
args = parser.parse_args()

dotfile_dir = Path(__file__).parent
config_dir = Path.home() / '.config'
data_dir = Path.home() / '.local/share'

system = platform.system()
if system == 'Linux':
    distro = platform.freedesktop_os_release()['ID']
    assert distro == 'ubuntu', distro
else:
    sys.exit(f'Unexpected system {system}')

symlinks = (
    ('bashrc', '.bashrc'),
    ('gitconfig', f'{config_dir}/git/config'),
    ('inputrc', f'{config_dir}/'),
    ('npmrc', f'{config_dir}/'),
    ('nvim', f'{config_dir}/'),
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

if system == 'Linux' and distro == 'ubuntu':
    if not args.skip_apt:
        apt_cache_policy = subprocess.check_output(['apt-cache', 'policy'], text=True)

        # PPAs
        if args.vim_ppa:
            vim_ppa = 'jonathonf/vim'
            if vim_ppa not in apt_cache_policy:
                subprocess.run(['sudo', 'add-apt-repository', f'ppa:{vim_ppa}'], check=True)

        # nodejs
        if 'nodesource' not in apt_cache_policy:
            with urllib.request.urlopen('https://deb.nodesource.com/setup_lts.x') as req:
                subprocess.run(['sudo', '-E', 'bash', '-'], input=req.read(), check=True)

        # install apt packages
        packages = { # general
            'aptitude', 'curl', 'gcc', 'git', 'make', 'ncdu', 'nodejs',
            'openssh-server', 'python3-pip', 'python3-venv', 'vim', 'xcape',
            'xclip', 'xsel', 'zsh',
        }
        packages |= {'libevent-dev', 'libncurses-dev', 'libutempter-dev'} # tmux build
        if args.pyenv:
            packages |= { # python build
                'libbz2-dev', 'libffi-dev', 'libgdbm-dev', 'liblzma-dev',
                'libncurses-dev', 'libreadline-dev', 'libsqlite3-dev', 'libssl-dev',
                'uuid-dev', 'zlib1g-dev',
            }
        packages |= {'ninja-build', 'gettext', 'cmake', 'unzip', 'curl', 'gcc', 'g++', 'make'} # neovim build
        subprocess.run(['sudo', 'apt', 'install', *sorted(packages)], check=True)

    semver_re = r'(\d+\.\d+\.\d+)'
    github_releases = (
        ('BurntSushi/ripgrep', semver_re, 'ripgrep_{version}_amd64.deb'),
        ('sharkdp/bat', f'v{semver_re}', 'bat_{version}_amd64.deb'),
        ('sharkdp/fd', f'v{semver_re}', 'fd_{version}_amd64.deb'),
        ('sharkdp/hexyl', f'v{semver_re}', 'hexyl_{version}_amd64.deb'),
        ('tmux/tmux', r'tmux (\d.\d[a-z]?)', 'tmux-{version}.tar.gz'),
    )

    release_dir = Path.home() / 'Downloads/github_releases'
    release_dir.mkdir(parents=True, exist_ok=True)
    for repo, release_name_re, file in github_releases:
        version, dl_url, dl_file = get_github_release(repo, release_name_re, file)
        user, sep, name = repo.partition('/')
        assert sep, repo
        version_opt = '-V' if name == 'tmux' else '--version'
        binary_name = 'rg' if name == 'ripgrep' else name
        try:
            version_str = subprocess.check_output([binary_name, version_opt], text=True)
        except FileNotFoundError:
            installed_version = None
        else:
            version_str = version_str.rstrip()
            if name == 'ripgrep':
                version_str = version_str.splitlines()[0]
                program_name, installed_version, _ = version_str.split(maxsplit=2)
            else:
                assert user in {'sharkdp', 'tmux'}, user
                program_name, sep, installed_version = version_str.partition(' ')
                assert sep, name
            assert name == program_name, name
        release_path = release_dir / dl_file
        if installed_version == version:
            continue
        if installed_version is None:
            print(f'{name} not installed, installing...')
        else:
            print(f'{name} installing {version} over {installed_version}...')
            if release_path.suffix == '.deb':
                subprocess.run(['dpkg', '-s', name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True) # check that package already exists
        if not release_path.exists():
            with urllib.request.urlopen(dl_url) as req, release_path.open('wb') as f:
                shutil.copyfileobj(req, f)
        if release_path.suffix == '.deb':
            subprocess.run(['sudo', 'dpkg', '-i', release_path], check=True)
        else:
            assert name == 'tmux' and release_path.suffixes[-2:] == ['.tar', '.gz']
            with tempfile.TemporaryDirectory() as tmp_dir:
                tmux_src_dir = Path(tmp_dir) / f'tmux-{version}'
                usable_cpus = len(os.sched_getaffinity(0))
                shutil.unpack_archive(release_path, tmp_dir)
                tmux_prefix = Path.home() / '.local'
                subprocess.run(['./configure', f'--prefix={tmux_prefix}', '--enable-utempter'], cwd=tmux_src_dir, check=True)
                subprocess.run(['make', f'-j{usable_cpus}'], cwd=tmux_src_dir, check=True)
                subprocess.run(['make', 'install'], cwd=tmux_src_dir, check=True)

    # pyenv
    if args.pyenv and shutil.which('pyenv') is None:
        pyenv_root = data_dir / 'pyenv'
        pyenv_env = dict(os.environ, PYENV_ROOT=pyenv_root)

        # install pyenv
        with urllib.request.urlopen('https://pyenv.run') as req:
            subprocess.run(['bash', '-'], input=req.read(), env=pyenv_env, check=True)

        # install latest Python 3
        pyenv_bin = pyenv_root / 'bin/pyenv'
        pyenv_list = subprocess.check_output([pyenv_bin, 'install', '--list'], env=pyenv_env, text=True)
        latest_version = (3, 0, 0)
        for line in pyenv_list.splitlines():
            if not (m := re.fullmatch(r'\s*3\.(\d+)\.(\d+)', line)):
                continue
            minor, patchlevel = m.groups()
            version = (3, int(minor), int(patchlevel))
            latest_version = max(latest_version, version)
        assert latest_version != (3, 0, 0)
        latest_version_str = '.'.join(str(i) for i in latest_version)
        install_env = dict(pyenv_env, PYTHON_CONFIGURE_OPTS='--enable-optimizations --with-lto', PYTHON_CFLAGS='-march=native')
        subprocess.run([pyenv_bin, 'install', latest_version_str], env=install_env, check=True)
        subprocess.run([pyenv_bin, 'global', latest_version_str], env=pyenv_env, check=True)

if system == 'Linux' and shutil.which('infocmp'):
    terms = {'mintty-direct', 'tmux-256color', 'tmux-direct', 'vte-direct'}
    def has_terminfo(term):
        return subprocess.run(['infocmp', term], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
    missing_terms = [term for term in sorted(terms) if not has_terminfo(term)]
    if missing_terms:
        with urllib.request.urlopen('http://invisible-island.net/datafiles/current/terminfo.src.gz') as req:
            with tempfile.NamedTemporaryFile('wb') as fw:
                with gzip.open(req) as fr:
                    shutil.copyfileobj(fr, fw)
                fw.flush()
                print('Adding missing terminfo:', *missing_terms)
                subprocess.run(['tic', '-x', '-e', ','.join(missing_terms), fw.name])
        assert all(has_terminfo(term) for term in missing_terms)

# tmux
if not (tpm_dir := data_dir / 'tmux/plugins/tpm').exists():
    subprocess.run(['git', 'clone', 'https://github.com/tmux-plugins/tpm', tpm_dir], check=True)
    subprocess.run(tpm_dir / 'bin/install_plugins', check=True)

# vim
vim_env = dict(os.environ, ZDOTDIR=config_dir / 'zsh') # it's possible zshenv isn't sourced yet
if not (data_dir / 'vim/plugged').exists():
    subprocess.run(['vim', '+PlugInstall', '+qall'], env=vim_env, check=True)
