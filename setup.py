#!/usr/bin/env python3
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

dotfile_dir = Path(__file__).parent
config_dir = Path.home() / '.config'
data_dir = Path.home() / '.local/share'

system = platform.system()
if system == 'Linux':
    try:
        distro = subprocess.check_output(['lsb_release', '-is'], text=True)
        distro = distro.rstrip()
    except FileNotFoundError:
        distro = None
    if distro is None:
        if not Path('/data/data/com.termux').exists():
            sys.exit('ERROR: could not determine Linux distro')
        distro = 'Termux'
    else:
        assert distro == 'Ubuntu', distro
else:
    sys.exit(f'Unexpected system {system}')

symlinks = (
    ('bashrc', '.bashrc'),
    ('gitconfig', f'{config_dir}/git/config'),
    ('inputrc', f'{config_dir}/'),
    ('npmrc', f'{config_dir}/'),
    ('nvim', f'{config_dir}/'),
    ('tmux.conf', f'{config_dir}/tmux/'),
    ('vim', '.vim'),
    ('zshenv', '.zshenv'),
    ('zshrc', f'{config_dir}/zsh/.zshrc'),
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
    print(f'symlink {path.relative_to(Path.home())} to {target}')
    path.parent.mkdir(parents=True, exist_ok=True)
    path.symlink_to(target)

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
    sys.exit('ERROR: no release found for github repo {repo}')


if system == 'Linux' and distro == 'Ubuntu':
    apt_cache_policy = subprocess.check_output(['apt-cache', 'policy'], text=True)

    # PPAs
    for ppa in ['jonathonf/vim', 'neovim-ppa/stable']:
        if ppa not in apt_cache_policy:
            subprocess.run(['sudo', 'add-apt-repository', f'ppa:{ppa}'], check=True)

    # nodejs
    if 'nodesource' not in apt_cache_policy:
        with urllib.request.urlopen('https://deb.nodesource.com/setup_lts.x') as req:
            subprocess.run(['sudo', '-E', 'bash', '-'], stdin=req, check=True)

    # install apt packages
    packages = {
        # general
        'aptitude', 'curl', 'gcc', 'git', 'make', 'ncdu', 'neovim', 'nodejs',
        'openssh-server', 'python3-pip', 'python3-venv', 'vim', 'zsh',

        # tmux build
        'libevent-dev', 'libncurses-dev', 'libutempter-dev',

        # python build
        # https://github.com/pyenv/pyenv/wiki/Common-build-problems#prerequisites
        'curl', 'gcc', 'git', 'libbz2-dev', 'libffi-dev', 'liblzma-dev',
        'libncurses5-dev', 'libncursesw5-dev', 'libreadline-dev',
        'libsqlite3-dev', 'libssl-dev', 'llvm', 'make', 'python-openssl',
        'tk-dev', 'wget', 'xz-utils', 'zlib1g-dev',
    }
    subprocess.run(['sudo', 'apt', 'install'] + sorted(packages), check=True)

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
            version_str = subprocess.check_output([binary_name, version_opt], text=True, stderr=subprocess.STDOUT) # XXX capturing stderr because of https://github.com/sharkdp/hexyl/issues/131
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
            assert name == 'tmux' and release_path.suffixes == ['.tar', '.gz']
            with tempfile.TemporaryDirectory() as tmp_dir:
                usable_cpus = len(os.sched_getaffinity(0))
                shutil.unpack_archive(release_path, tmp_dir)
                subprocess.run(['./configure', '--enable-utempter'], cwd=tmp_dir, check=True)
                subprocess.run(['make', f'-j{usable_cpus}'], cwd=tmp_dir, check=True)
                subprocess.run(['sudo', 'make', 'install'], cwd=tmp_dir, check=True)

        # pyenv
        if shutil.which('pyenv') is None:
            pyenv_root = Path(data_dir / 'pyenv')
            env = os.environ.copy()
            env['PYENV_ROOT'] = str(pyenv_root)

            # install pyenv
            with urllib.request.urlopen('https://pyenv.run') as req:
                subprocess.run(['bash', '-'], stdin=req, env=env, check=True)

            # install latest Python 3
            pyenv_bin = pyenv_root / 'bin/pyenv'
            pyenv_list = subprocess.check_output([str(pyenv_bin), 'install', '--list'], env=env, text=True)
            latest_version = (3, 0, 0)
            for line in pyenv_list.splitlines():
                if not (m := re.fullmatch(r'\s*3\.(\d+)\.(\d+)', line)):
                    continue
                minor, patchlevel = m.groups()
                version = (3, int(minor), int(patchlevel))
                if latest_version < version:
                    latest_version = version
            assert latest_version != (3, 0, 0)
            subprocess.run([str(pyenv_bin), 'install', '.'.join(str(i) for i in latest_version)], env=env, check=True)

# tmux
if not (tpm_dir := data_dir / 'tmux/plugins/tpm').exists():
    subprocess.run(['git', 'clone', 'https://github.com/tmux-plugins/tpm', tpm_dir], check=True)
    subprocess.run(str(tpm_dir / 'bin/install_plugins'), check=True)

# (neo)vim
if not (nvim_plug := data_dir / 'nvim/site/autoload/plug.vim').exists():
    nvim_plug.parent.mkdir(parents=True)
    with urllib.request.urlopen('https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim') as req:
        with nvim_plug.open('wb') as f:
            shutil.copyfileobj(req, f)
if not (data_dir / 'vim/plugged').exists():
    subprocess.run(['vim', '+PlugInstall', '+qall'], check=True)
if not (data_dir / 'nvim/plugged').exists():
    subprocess.run(['nvim', '+PlugInstall', '+qall'], check=True)
