#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

# be careful that composer does not uses XDG when no XDG_* defined
PATH="$HOME/.local/bin:$XDG_DATA_HOME/npm/bin/:$XDG_CONFIG_HOME/composer/vendor/bin/:$PATH"

if [ "$OSTYPE" = msys ]; then
	export LC_ALL=zh_TW.UTF-8
	PATH="/usr/bin:/bin:/mingw64/bin:$PATH"
fi

# XDG workarounds
# policy: (!customized) => ((PMs) => data, (!PMs && !important) => cache)
[ ! -d "$XDG_CACHE_HOME" ] && mkdir "$XDG_CACHE_HOME"
HISTFILE="$XDG_CACHE_HOME/bash_history"
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

# alpine exports PS1
export -n PS1

# shell options
HISTCONTROL=ignoredups
HISTSIZE=2048
HISTFILESIZE=2048
HISTIGNORE="history:exit:top:ls:clear:mount:python"

PS1="\[\033[01;32m\]\u@\h${STY:+>${STY#*\.}} \[\033[01;34m\]\W\[\033[31m\]\${?#0}\[\033[0m\]\\$ "

# aliases
if [ "${OSTYPE%%-*}" = "linux" ] || [ "$OSTYPE" = "msys" ];then
	# coreutils
	alias ls='ls --color=auto'
	alias diff='diff --color=auto'
elif [ "${OSTYPE%%[0-9]*}" = "freebsd" ];then
	alias ls='ls -G'
fi
alias mvi='mpv --config-dir=$HOME/.config/mvi'
# non-posix, but exists on freebsd
alias rm='rm -I'
alias grep='grep --color=auto'

alias sftp='sftp -p -o Compression=no'

[ -f /usr/bin/vimpager ] && alias less=vimpager
alias sway="env LC_ALL=zh_TW.utf8 sway"
alias mcshl="env ALSOFT_DRIVERS=alsa _JAVA_OPTIONS=\"-Dorg.lwjgl.glfw.libname=/usr/lib/libglfw.so -Dawt.useSystemAAFontSettings=lcd -Xmn512m -Xms2G -Xmx2G -XX:+UseTransparentHugePages -XX:MaxGCPauseMillis=50 -XX:+UseZGC -Xaggressive $_JAVA_OPTIONS\" mcshl"
alias tstoggle="swaymsg input 1267:9454:ELAN24EE:00_04F3:24EE events toggle"

alias laravelphpcs="phpcs --standard=PSR2 app routes config tests"

alias makepkgsh="podman run -itu builder -w /home/builder -v .:/home/builder -v /var/cache/pacman/pkg:/var/cache/pacman/pkg --userns keep-id registry.xdavidwu.link/ci-modulize/archlinux-docker-ci/base-devel sh"
alias abuildsh="podman run -itu builder -w /home/builder -v .:/home/builder --userns keep-id registry.xdavidwu.link/ci-modulize/abuild:edge"
if [ -f /usr/bin/composer.phar ]; then
	alias composer7="php7 /usr/bin/composer.phar"
else
	alias composer7="php7 /usr/bin/composer"
fi
alias artisan="php8 artisan"
alias artisan7="php7 artisan"
alias tiocgwinsz="python3 -c \"import struct, fcntl, termios; print('%d %d %d %d' % struct.unpack('4H', fcntl.ioctl(0, termios.TIOCGWINSZ, '        ')))\""
alias dl="curl -OJLR --compressed"

# functions
batlvl() {
	echo $(($(cat /sys/class/power_supply/BAT0/charge_now) * 100 /
		$(cat /sys/class/power_supply/BAT0/charge_full_design) ))
}

play-playlist() {
	ARGS=
	for list in $@;do
		ARGS="$ARGS --playlist=$list"
	done
	mpv --ytdl-raw-options=audio-format=best --no-video $ARGS
}

psave() {
	if [ "$1" = "perf" ];then
		echo powersave perfomance
		echo performance | doas tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference >/dev/null
	elif [ "$1" = "off" ];then
		echo powersave off
		echo balance_performance | doas tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference >/dev/null
	else
		echo powersave on
		echo power | doas tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference >/dev/null
	fi
}

timesync() {
	doas busybox ntpd -dqn -p time.stdtime.gov.tw
	doas busybox hwclock -wu
}

sleepto() {
	sleep $(($(date --date="$1" +%s) - $EPOCHSECONDS))
}

imgcat_max_pixels() {
	tiocgwinsz | (
		read MROW MCOL MX MY
		echo ${MX}x$(($MY / $MROW * $(($MROW - 1))))
	)
}

imgcat() {
	EXTRA=
	MAX=$(imgcat_max_pixels 2>/dev/null)
	[ -n "$MAX" ] && EXTRA="-resize ${MAX}>"
	for i; do
		convert "$i" $EXTRA sixel:-
	done
}

vidcat() {
	ffmpeg -i "$@" -loglevel warning -vframes 1 -f apng - | imgcat -
}

notify() {
	echo -ne "\x1b]777;notify;title;$@\x1b"'\\'
}

st() {
	ST_SERVER=$(curl -q https://www.speedtest.net/speedtest-servers-static.php 2>/dev/null | head -n 3 | tail -n 1 | cut -f 2 -d '"')
	echo download
	curl -q "$(dirname "$ST_SERVER")"/random7000x7000.jpg -m 10 >/dev/null
	echo upload
	head -c 100M /dev/urandom | curl -q "$ST_SERVER" -m 10 --data-binary @- >/dev/null
}

# application envs
export GPG_TTY=$(tty 2>/dev/null)
[ -f /usr/bin/vimpager ] && export PAGER=vimpager
export LESS='-S -R'
export LESSHISTFILE=-
export EDITOR=vim
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland-egl
export SDL_VIDEODRIVER=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GTK_IM_MODULE=wayland
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
[ -f "/proc/$PPID/cmdline" ] && PCMD=$(tr -d '\000' < /proc/$PPID/cmdline)
[ -z "$PTERM" ] && INITLVL=1
PTERM=${PTERM:-$TERM/}
case "$PCMD" in
	SCREEN*)
		PTERM="${PTERM}S"
		;;
	sshd*)
		PTERM="${PTERM}s"
		;;
	*term*|foot*)
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
			PS1A="$PS1A\[\033[44m\]>"
			;;
		s*)
			PS1A="$PS1A\[\033[45m\]>"
			;;
		n*)
			PS1A="$PS1A\[\033[0m\]>"
			;;
	esac
	LVLSTR=${LVLSTR#?}
done
PS1="$PS1A\[\033[0m\]$PS1"
export PTERM
alias rssh="command ssh"
alias ssh="env TERM=$PTERM ssh"

if ! type _completion_loader >/dev/null 2>&1; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /data/data/com.termux/files/usr/share/bash-completion/bash_completion ]; then
		. /data/data/com.termux/files/usr/share/bash-completion/bash_completion
	fi
fi

_completion_loader ssh 2>/dev/null
[ $? -eq 124 ] && complete -F _ssh rssh

_completion_loader sudo 2>/dev/null
[ $? -eq 124 ] && complete -F _sudo doas

_completion_loader symfony-autocomplete 2>/dev/null
[ $? -eq 124 ] && complete -F _symfony artisan artisan7 composer7
true
