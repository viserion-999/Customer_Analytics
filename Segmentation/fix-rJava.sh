#!/usr/bin/env bash
# Script to configure rJava correctly on macOS.

# Check R is available.
RP=$(which R)
if [ $? -ne 0 ]; then
	>&2 echo "Unable to find R executable; please ensure it is installed correctly."
	exit 1
fi

# Check whether R is installed via Homebrew.
if $(which brew 2&>/dev/null) && $(brew unlink --dry-run r | grep "$RP" 2&>/dev/null) ; then
	RPATH="$(brew --prefix r)/bin"
fi

# If not a Homebrew installation, check for script running under admin account.
if [ -z $RPATH ]; then
	if groups $USER | grep -q -w -v admin; then
		echo "Please run this script using an administrator account."
		exit 2
	fi
fi

# Check location of Java installation.
JAVA_HOME=${JAVA_HOME:-$(/usr/libexec/java_home)}
if [ $? -ne 0 ]; then
	>&2 echo "Failed to locate JAVA_HOME; make sure Java is installed"
	exit 3
fi
echo "Using JAVA_HOME: ${JAVA_HOME}"

# Notify user, and request confirmation.
echo "Ensure you've reinstalled R since updating your Java installation"
read -p "Continue...[Y/n]? " yn
case $yn in
	[Nn]* ) exit;;
	* ) ;;
esac

# Resolve location of R installation (works on both package-installed & Homebrew).
RPATH=$(dirname $(dirname $(perl -MCwd -e 'print Cwd::abs_path shift' "$(which R)")))
# Check for existence of javareconf script.
JRFILE=$(find "$RPATH" -type f -name 'javareconf' -print | head -n 1)
if [ ! -e "$JRFILE" ]; then
	>&2 echo "Failed to find Java configuration script for R (\"javareconf\")"
	RPATH=$(brew --prefix r 2&>/dev/null)
	if [ $? -eq 0 ]; then
		brew info r | grep '\--with-java' >/dev/null
		if [ $? -ne 0 ]; then
			>&2 echo -e "Please reinstall Homebrew package 'r' with Java support:\n\tbrew uninstall r && brew install r --with-java"
		else
			>&2 echo -e "Found Homebrew 'r' installation, but no \"javareconf\"; maybe try reinstalling?\n\tbrew uninstall r && brew install r --with-java"
		fi
	else
		>&2 echo -e "Please check R installation, or reinstall."
	fi
	exit 4
fi

# Run javareconf script with custom variables.
LIBJVM=$(find "${JAVA_HOME}" -name 'libjvm.dylib')
R CMD javareconf JAVA_LIBS="$LIBJVM" JAVA_LD_LIBRARY_PATH="$LIBJVM" JAVA_CPPFLAGS="'-I${JAVA_HOME}/include -I${JAVA_HOME}/include/darwin -I$(dirname "$LIBJVM")'"

# Link JVM library to allow R to find it.
ln -fs "$LIBJVM" "$RPATH/lib"
