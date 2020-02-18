#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

# be careful that composer does not uses XDG when no XDG_* defined
export PATH="$HOME/.local/bin:$XDG_CONFIG_HOME/composer/vendor/bin/:$PATH"

# XDG workarounds
# policy: (!customized) => ((PMs) => data, (!PMs && !important) => cache)
[ ! -d "$XDG_CACHE_HOME" ] && mkdir "$XDG_CACHE_HOME"
HISTFILE="$XDG_CACHE_HOME/bash_history"
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
if [ -n "$(grep -F 'ID=arch' /etc/os-release 2>/dev/null)" ] ||
		[ -n "$(grep -F 'ID_LIKE=arch' /etc/os-release 2>/dev/null)" ];then
	export VIMINIT=":source $XDG_CONFIG_HOME/vim/vimrc"
else
	export VIMINIT=":source $XDG_CONFIG_HOME/vim/vimrc-nonarch"
fi
export SCREENRC="$XDG_CONFIG_HOME/screen/screenrc"
export GRADLE_USER_HOME="$XDG_CACHE_HOME/gradle"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CACHE_HOME/java
	$_JAVA_OPTIONS"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export PARALLEL_HOME="$XDG_CACHE_HOME/parallel"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export ICEAUTHORITY="$XDG_CACHE_HOME/ICEauthority"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export SQLITE_HISTORY="$XDG_CACHE_HOME/sqlite_history"
export MYSQL_HISTFILE="$XDG_CACHE_HOME/mysql_history"
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history"

# shell options
HISTCONTROL=ignoredups
HISTSIZE=2048
HISTFILESIZE=2048
HISTIGNORE="history:exit:top:ls:clear:mount:python"
PS1="\[\033[01;32m\]\u@\h${STY:+>${STY#*\.}} \[\033[01;34m\]\W\[\033[00m\]\$ "

# aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias rm='rm -I'
[ -f /usr/bin/vimpager ] && alias less=vimpager
alias sway="env LC_ALL=zh_TW.utf8 sway"

# TODO output quick switches for xps with sway
alias hdmiclone='xrandr --output HDMI-1 --mode 1360x768 --pos 0x0'
alias hdmiright='xrandr --output HDMI-1 --mode 1920x1080 --right-of LVDS-1'
alias vgaclone='xrandr --newmode "1360x768_60.00"   84.75  1360 1432 1568 1776  768 771 781 798 -hsync +vsync;
xrandr --addmode VGA-1 "1360x768_60.00"
xrandr --output VGA-1 --mode "1360x768_60.00" --pos 0x0'
alias vgaright='xrandr --output VGA-1 --mode 1920x1080 --right-of LVDS-1'
alias bookmode='xrandr --output LVDS-1 --rotate right && xinput set-prop "SynPS/2 Synaptics TouchPad" --type=float "Coordinate Transformation Matrix" 0 1 0 -1 0 1 0 0 1'
alias normalmode='xrandr --output LVDS-1 --rotate normal && xinput set-prop "SynPS/2 Synaptics TouchPad" --type=float "Coordinate Transformation Matrix" 0 0 0 0 0 0 0 0 0'

# functions
batlvl() {
	echo $(($(cat /sys/class/power_supply/BAT0/charge_now) * 100 /
		$(cat /sys/class/power_supply/BAT0/charge_full_design) ))
}

# application envs
# policy: should here even if global like /etc/environments
export GPG_TTY=$(tty)
[ -f /usr/bin/vimpager ] && export PAGER=vimpager
export LESS='-S -R'
export LESSHISTFILE=-
export EDITOR=vim
export AIRCRACK_LIBEXEC_PATH=/usr/lib/aircrack-ng
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd -Xmn512m -Xms2G -Xmx2G -XX:+UseTransparentHugePages -Xnoclassgc -XX:MaxGCPauseMillis=50 -XX:+UseG1GC $_JAVA_OPTIONS"
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland-egl
export MESA_LOADER_DRIVER_OVERRIDE=iris
export SDL_VIDEODRIVER=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx

# shell level prompt
# PTERM: poisoned TERM, $TERM/$LVLSTR, ssh pass TERM by default
# if $PPID is a GUI term, treat it as a fresh start
# if $TERM contains /, it is $PTERM passed from ssh
case "$TERM" in
	*/*)
		PTERM=$TERM
		TERM=${TERM%%/*}
		;;
esac
# bash complains if $() faces null
PCMD=$(tr -d '\000' < /proc/$PPID/cmdline)
PTERM=${PTERM:-$TERM/}
case "$PCMD" in
	SCREEN*)
		PTERM="${PTERM}S"
		;;
	sshd*)
		PTERM="${PTERM}s"
		;;
	*term*)
		PTERM="$TERM/"
		;;
	*)
		[ -z "$INITLVL" ] && PTERM="${PTERM}n"
		;;
esac
LVLSTR=${PTERM##*/}
PS1A=
while [ -n "$LVLSTR" ];do
	case "$LVLSTR" in
		S*)
			PS1A="$PS1A\[\033[01;33m\]>"
			;;
		s*)
			PS1A="$PS1A\[\033[01;31m\]>"
			;;
		n*)
			PS1A="$PS1A\[\033[01;32m\]>"
			;;
	esac
	LVLSTR=${LVLSTR#?}
done
PS1="$PS1A$PS1"
export PTERM
alias ssh="env TERM=$PTERM ssh"
