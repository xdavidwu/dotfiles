#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

# be careful that composer does not uses XDG when no XDG_* defined
export PATH="$HOME/.local/bin:$XDG_DATA_HOME/npm/bin/:$XDG_CONFIG_HOME/composer/vendor/bin/:$PATH"

# XDG workarounds
# policy: (!customized) => ((PMs) => data, (!PMs && !important) => cache)
[ ! -d "$XDG_CACHE_HOME" ] && mkdir "$XDG_CACHE_HOME"
HISTFILE="$XDG_CACHE_HOME/bash_history"
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
if [ -n "$(grep -F 'ID=arch' /etc/os-release 2>/dev/null)" ] ||
		[ -n "$(grep -F 'ID_LIKE=arch' /etc/os-release 2>/dev/null)" ];then
	export VIMINIT=":source $XDG_CONFIG_HOME/vim/vimrc"
	export VIMPAGER_RC="$XDG_CONFIG_HOME/vim/vimrc"
else
	export VIMINIT=":source $XDG_CONFIG_HOME/vim/vimrc-nonarch"
	export VIMPAGER_RC="$XDG_CONFIG_HOME/vim/vimrc-nonarch"
fi
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

# shell options
HISTCONTROL=ignoredups
HISTSIZE=2048
HISTFILESIZE=2048
HISTIGNORE="history:exit:top:ls:clear:mount:python"
PS1="\[\033[01;32m\]\u@\h${STY:+>${STY#*\.}} \[\033[01;34m\]\W\[\033[00m\]\\$ "

# aliases
if [ "$(uname)" = "Linux" ];then
	alias ls='ls --color=auto'
	alias diff='diff --color=auto'
elif [ "$(uname)" = "FreeBSD" ];then
	alias ls='ls -G'
fi
# non-posix, but exists on freebsd
alias rm='rm -I'
alias grep='grep --color=auto'

alias sftp='sftp -o Compression=no'

[ -f /usr/bin/vimpager ] && alias less=vimpager
alias sway="env LC_ALL=zh_TW.utf8 sway"
alias mcshl="env ALSOFT_DRIVERS=alsa _JAVA_OPTIONS=\"-Dawt.useSystemAAFontSettings=lcd -Xmn512m -Xms2G -Xmx2G -XX:+UseTransparentHugePages -XX:MaxGCPauseMillis=50 -XX:+UseZGC -Xaggressive $_JAVA_OPTIONS\" mcshl"
alias tstoggle="swaymsg input 1267:9454:ELAN24EE:00_04F3:24EE events toggle"

alias laravelphpcs="phpcs --standard=PSR2 app routes config tests"

alias makepkgsh="podman run -itu builder -w /home/builder -v .:/home/builder -v /var/cache/pacman/pkg:/var/cache/pacman/pkg --userns keep-id registry.eglo.ga/ci-modulize/archlinux-docker-ci/base-devel sh"
alias composer7="php7 /usr/bin/composer"
alias composer17="php7 /usr/bin/composer1"
alias tiocgwinsz="python3 -c \"import struct, fcntl, termios; print('%d %d %d %d' % struct.unpack('4H', fcntl.ioctl(0, termios.TIOCGWINSZ, '        ')))\""

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
	sleep $(($(date --date="$1" +%s) - $(date +%s)))
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
	convert "$@" $EXTRA sixel:-
}

vidcat() {
	ffmpeg -i "$@" -loglevel warning -vframes 1 -f apng - | imgcat -
}

# application envs
# policy: should here even if global like /etc/environments
export GPG_TTY=$(tty)
[ -f /usr/bin/vimpager ] && export PAGER=vimpager
export LESS='-S -R'
export LESSHISTFILE=-
export EDITOR=vim
export AIRCRACK_LIBEXEC_PATH=/usr/lib/aircrack-ng
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland-egl
export MESA_LOADER_DRIVER_OVERRIDE=iris
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
PCMD=$(tr -d '\000' < /proc/$PPID/cmdline)
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
alias rssh="$(command -v ssh)"
alias ssh="env TERM=$PTERM ssh"

_completion_loader ssh 2>/dev/null
[ $? -eq 124 ] && complete -F _ssh rssh

_completion_loader sudo 2>/dev/null
[ $? -eq 124 ] && complete -F _sudo doas
