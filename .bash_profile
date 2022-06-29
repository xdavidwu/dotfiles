#
# ~/.bash_profile
#

# sanitize
# alpine exports PS1
export -n PS1
# arch set PROMPT_COMMAND for terminal title
unset PROMPT_COMMAND

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

# be careful that composer does not uses XDG when no XDG_* defined
PATH="$HOME/.local/bin:$XDG_DATA_HOME/npm/bin/:$XDG_CONFIG_HOME/composer/vendor/bin/:$PATH"

# XDG workarounds
[ ! -d "$XDG_CACHE_HOME" ] && mkdir "$XDG_CACHE_HOME"
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
export VIMINIT=":source $XDG_CONFIG_HOME/vim/vimrc"
export VIMPAGER_RC="$XDG_CONFIG_HOME/vim/vimrc"
export SCREENRC="$XDG_CONFIG_HOME/screen/screenrc"
export GRADLE_USER_HOME="$XDG_CACHE_HOME/gradle"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CACHE_HOME/java
	$_JAVA_OPTIONS"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export PARALLEL_HOME="$XDG_CACHE_HOME/parallel"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_GLOBALCONFIG="$XDG_CONFIG_HOME/sensitive/npm/npmrc"
export ICEAUTHORITY="$XDG_CACHE_HOME/ICEauthority"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export SQLITE_HISTORY="$XDG_CACHE_HOME/sqlite_history"
export MYSQL_HISTFILE="$XDG_CACHE_HOME/mysql_history"
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass
export ABDUCO_SOCKET_DIR="$XDG_DATA_HOME"

# application envs
[ -f /usr/bin/vimpager ] && export PAGER=vimpager
export LESS='-S -R'
export LESSHISTFILE=-
if [ -f /usr/bin/nvim ]; then
	export EDITOR=nvim
	export VIMPAGER_VIM=nvim
else
	export EDITOR=vim
fi
export DVTM_PAGER=less
export ABDUCO_CMD="dvtm -M"
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland-egl
export SDL_VIDEODRIVER=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GTK_IM_MODULE=wayland
export QT_IM_MODULE=fcitx

if [ ! -d "$ANDROID_HOME" ]; then
	if [ ! -d "$ANDROID_SDK_ROOT" ] && [ -d ~/android-sdk ]; then
		export ANDROID_SDK_ROOT=~/android-sdk
		# platform-tools also contains stuff like mke2fs, sqlite3
		PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"
	fi
else
	export ANDROID_SDK_ROOT="$ANDROID_HOME"
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
