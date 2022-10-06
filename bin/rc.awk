#!/usr/bin/env awk -f

# Usage:
#   rc.awk env /tmp/homebrew_env_sorted.sh
#   rc.awk /usr/local/Homebrew/Library/Homebrew/brew.sh /tmp/homebrew_env_sorted.sh

BEGIN {
    if ( ARGV[1] == "env" ) {
        OFS="=";
        HEADER=ARGV[2]".txt";
        TMP=ARGV[2]".tmp";
        TMP_SORTED=ARGV[2]".sorted";
        DEST=ARGV[2];
        system("rm -f "HEADER" "TMP" "TMP_SORTED);
        print "# shellcheck shell=sh" > HEADER;
        print "#" > HEADER;
        print "# Homebrew configuration variables from:" > HEADER;
        print "#  - https://raw.githubusercontent.com/Homebrew/install/master/install.sh" > HEADER;
        print "#  - https://raw.githubusercontent.com/Homebrew/brew/master/bin/brew" > HEADER;
        print "#  - https://raw.githubusercontent.com/Homebrew/brew/master/Library/Homebrew/brew.sh" > HEADER;
        print "#" > HEADER;
        print "# $HOMEBREW_PREFIX is where directory subdirectories (etc, Caskroom, Cellar, ...) are created" > HEADER;
        print "# $HOMEBREW_REPOSITORY (https://github.com/Homebrew/brew) is usually clone as" > HEADER;
        print "#   Homebrew under $HOMEBREW_PREFIX (except macOS arm) if brew install.sh script is used." > HEADER;
        print "# if $HOMEBREW_PREFIX != $HOMEBREW_REPOSITORY (https://github.com/Homebrew/brew):" > HEADER;
        print "#   - Subdirectories are created under $HOMEBREW_PREFIX." > HEADER;
        print "#   - Contents below subdirectories are symlinked to Cellar, etc" > HEADER;
        print "#   - brew executable is symlinked from $HOMEBREW_REPOSITORY to $HOMEBREW_PREFIX." > HEADER;
        print "#" > HEADER;
        print "# Generated by: "ENVIRON["_"]", on: "ENVIRON["DATE"] > HEADER;
        print "" > HEADER;

        for ( v in ENVIRON ) {
            if ( v ~ /SSL_/ || v ~ /LC_/ || v ~ /HOMEBREW_/ ) {
                printf("%s=\"%s\"\n", "export " v, ENVIRON[v]) >> TMP;
            }
        }
        if ( system("sort -u "TMP" > "TMP_SORTED) ) {
            print "Error: failed to sort "TMP" > "TMP_SORTED;
            exit 1;
        }
        if ( system("cat "HEADER" "TMP_SORTED" > "DEST) ) {
            print "Error: failed to cat "HEADER" "TMP_SORTED" > "DEST;
            exit 1;
        }
        exit;
    } else {
        FIRST="[ ! \"${1-}\" ] || { set -- ; . \"$0\"; exit; }";
        SCRIPT=ENVIRON["_"];
        BREW=ARGV[1];
        ORIGINAL=ARGV[1]".bak";
        TMP=ARGV[1]".tmp";
        HOMEBREW_SH=ARGV[2];
        ARGV[2]="";
        if (system("cp "BREW" "ORIGINAL) != 0) {
            print "Error: Could not create backup of "BREW;
            exit 1;
        }
        print FIRST > TMP;
    }
}

{
    if ( FILENAME == HOMEBREW_SH ) {
        exit;
    }
    if ( ARGV[1] != "env" ) {
       if ( $1 == "setup-ruby-path" )  {
            printf("%s; %s; %s %s %s; %s\n", $0, "auto-update", SCRIPT, "env", HOMEBREW_SH, "return") >> TMP;
        } else {
            print $0 > TMP;
        }
    }
}

END {
    if ( ARGV[1] != "env" ) {
        if (system("mv "TMP" "BREW) != 0) {
            print "Error: Could not replace "BREW;
        } else {
            if (system("brew env") != 0) {
                print "Error: Could not get "BREW" environment";
            }
        }
        if (system("mv "ORIGINAL" "BREW) != 0) {
            print "Error: Could not replace "BREW;
            exit 1;
        }
    }
}