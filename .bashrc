#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

shopt -s histappend extglob
set +H

# sanitize
unset _GCOMPAT_PRELOAD

if [ "$OSTYPE" = msys ]; then
	export LC_ALL=zh_TW.UTF-8
	PATH="/usr/bin:/bin:/mingw64/bin:$PATH"
	EXECIGNORE="*.!(exe)"
elif [ "$OSTYPE" = "linux-musl" ]; then
	_GCOMPAT_PRELOAD="LD_PRELOAD=/lib/libgcompat.so.0"
fi

HISTFILE="$XDG_CACHE_HOME/bash_history"
HISTCONTROL=ignoreboth
HISTSIZE=2048
HISTFILESIZE=2048
HISTIGNORE="history:exit:top:ls:clear"

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

if command -v nvimpager >/dev/null;then
	alias less=nvimpager
elif command -v vimpager >/dev/null;then
	alias less=vimpager
fi
command -v nvim >/dev/null && alias vim=nvim
alias sway="env LC_ALL=zh_TW.utf8 XDG_CURRENT_DESKTOP=sway sway"
alias mcshl="env ALSOFT_DRIVERS=alsa $_GCOMPAT_PRELOAD _JAVA_OPTIONS=\"-Dawt.useSystemAAFontSettings=lcd -Xmn512m -Xms2G -Xmx2G -XX:+UseTransparentHugePages -XX:MaxGCPauseMillis=50 -XX:+UseZGC $_JAVA_OPTIONS\" mcshl"
alias tstoggle="swaymsg input 1267:9454:ELAN24EE:00_04F3:24EE events toggle"

alias makepkgsh="podman run -itu builder -w /home/builder -v .:/home/builder -v /var/cache/pacman/pkg:/var/cache/pacman/pkg --userns keep-id registry.xdavidwu.link/ci-modulize/archlinux-docker-ci/base-devel sh"
if [ -f /usr/bin/composer.phar ]; then
	alias composer81="php81 /usr/bin/composer.phar"
	alias composer82="php82 /usr/bin/composer.phar"
	alias composer="php83 /usr/bin/composer.phar"
fi
alias artisan81="php81 artisan"
alias artisan82="php82 artisan"
alias artisan="php83 artisan"
alias dl="curl -OJLR --compressed"
alias errno="grep -h '^#define[[:space:]]*E' /usr/include/asm-generic/errno* | sed 's|^#define[[:space:]]*||'"
alias signal="grep -h '^#define SIG' /usr/include/asm/signal.h | sed 's|^#define ||'"
alias timesync='doas busybox ntpd -dqn -p time.stdtime.gov.tw && doas busybox hwclock -wu'
alias notify="printf '\x1b]777;notify;title;%s\x1b'"

sleepto() {
	sleep $(($(date --date="$1" +%s) - $EPOCHSECONDS))
}

# application envs
export GPG_TTY=$(tty 2>/dev/null)

# shell level prompt
# PTERM: poisoned TERM, $TERM/$LVLSTR, ssh passes TERM by default
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
	dvtm*)
		PTERM="${PTERM}d"
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
PS1AO=
while [ -n "$LVLSTR" ];do
	case "$LVLSTR" in
		S*)
			PS1A="$PS1A\[\e[44m\]>"
			PS1AO="$PS1AO>"
			;;
		s*)
			PS1A="$PS1A\[\e[45m\]>"
			PS1AO="$PS1AO>"
			;;
		d*)
			PS1A="$PS1A\[\e[42m\]>"
			PS1AO="$PS1AO>"
			;;
		n*)
			PS1A="$PS1A\[\e[0m\]>"
			PS1AO="$PS1AO>"
			;;
	esac
	LVLSTR=${LVLSTR#?}
done
PS1="\[\e]133;A\e\\\\\]\[\e[01;32m\]\u@\h${ABDUCO_SESSION:+>$ABDUCO_SESSION}${STY:+>${STY#*\.}} \[\e[01;34m\]\w\[\e[31m\]\${?#0}\[\e[0m\]\\$ "
PS1="\[\e]2;$PS1AO\u@\h${ABDUCO_SESSION:+>$ABDUCO_SESSION}${STY:+>${STY#*\.}} \w\e\\\\\]$PS1A\[\e[0m\]$PS1"
PROMPT_DIRTRIM=2
export PTERM
alias rssh="command ssh"
alias ssh="env TERM=$PTERM ssh"

if ! type _completion_loader >/dev/null 2>&1; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /usr/local/share/bash-completion/bash_completion ]; then
		. /usr/local/share/bash-completion/bash_completion
	elif [ -f /data/data/com.termux/files/usr/share/bash-completion/bash_completion ]; then
		. /data/data/com.termux/files/usr/share/bash-completion/bash_completion
	fi
fi

_completion_loader ssh 2>/dev/null
[ $? -eq 124 ] && complete -F _comp_cmd_ssh rssh

_completion_loader sudo 2>/dev/null
[ $? -eq 124 ] && complete -F _comp_cmd_sudo doas

_completion_loader symfony-autocomplete 2>/dev/null
[ $? -eq 124 ] && complete -F _symfony artisan artisan81 composer composer81
true
