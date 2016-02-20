## Bash Prog Intro Notes

http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO.html
http://tldp.org/LDP/abs/html/
http://mywiki.wooledge.org/BashPitfalls
https://google.github.io/styleguide/shell.xml

## Intro:
I feel like writing bash is like building something with hot glue.
When try it for the first time, you'll probably make a big mess and burn yourself.
As you get a little more experienced, you can slap things together really quickly but the end result won't be very sturdy or pretty.

Google has a nice little bash style guide I definitely recommend.
Here's my favorite line: "Shell should only be used for small utilities or simple wrapper scripts."

This guide provides a cheat sheet for bash functions that I use frequently.
The commands start fairly simply with a handful of more advanced commands and gotchas towards the end.

## Hello world

1. Create a file called `hello-world` with the following contents
```
#!/bin/bash

echo "Hello, World!"
```
Note: All bash scripts should start with a bash header.
`#!/bin/bash` is the most common, although `#!/usr/bin/env bash` is also used.

2. Make it executable
```
chmod +x ./hello-world
```
Note: Notice that the script does not have the `.sh` extension.
Omitting the extension makes it easier to replace the script with a script or
executable written in another language later on.

3. Run it
```
./hello-world
```
You should see `Hello, World!` printed in your terminal.

## The basics

Printing to the terminal:
```
# write to stdout
echo "Hello, world!"

# write to stderr
echo "Something went wrong..." >&2
```

Variables:
```
# integers
count=10

# strings
message="Installing dependencies..."

# BAD: bash does not support floats
bad_var=1.1
```
Style Tip: local variable names should use lowercase letters and underscores

Integer Arithmetic
```
echo "$((2+2))" # 4
a=1
(( a++ )) # sets `a` to 2
echo "$(( a++ ))" # still prints 2, then sets value to 3. Be careful with pre vs post increment!
```

Create arrays of values:
```
# Note that values are space delimited instead of commas unlike most languages
values=( 1 2 3 4 ) # initialize array of integers
strings=( "foo" "bar" "asdf" ) # or strings

echo "${values[0]}" # prints first value in array, "1"
echo "${#values[@]} # prints length of array, "4"
```

If statements
```
if [[ $condition0 ]]; then
  command0
elif [[ $condition1 ]]; then
  command1
else
  command2
fi
```

Test Operators
```
# integers
if [[ "$a" -eq "$b" ]] # equal
if [[ "$a" -ne "$b" ]] # not equal
if [[ "$a" -gt "$b" ]] # greater than
if [[ "$a" -lt "$b" ]] # less than

# strings
if [[ "$a" == "$b" ]]
if [[ "$a" != "$b" ]]

# variables
if [[ -z "$1" ]] # succeeds if $1 is unset
if [[ -n "$1" ]] # succeeds if $1 is set

# boolean operators
if [[ ! $condition ]] # invert result
if [[ $condition0 ]] && [[ $condition1 ]] # and
if [[ $condition0 ]] || [[ $condition1 ]] # or

## file operators
if [[ -e $file ]] # true if file or directory exists
if [[ -f $file ]] # true if file exists, false for directories
if [[ -d $dir ]] # true if directory exists, false for files
```

For loops
```
# print 1 through 10 inclusive
for i in $(seq 1 10); do # be sure not to quote "$(...)"
  echo "$i"
done

# iterate over values in array
for i in "${values[@]}"; do
  echo "${i}"
done

```

Iterate over lines in a file
```
while read line; do
  echo "$line"
done < input.txt
```

Case statements
```
case "$1" in

  start)
    echo "Starting..."
    ;;

  stop | shutdown)
    echo "Stopping..."
    ;;

  *)
    # default case
    echo "ERROR: Unrecognized option '$1'"
    echo "Usage: my_script {start|stop|shutdown}"
    ;;
esac
```

Create functions
```
pretty_print() { # 'function' keyword is optional, omitting it is more portable
  echo "****** $1 ******"
}

result="$(pretty_print "hello world!")"
```
Note: there is no `return` keyword, only writing to stdout/err

## Inputs, outputs, and redirection

Redirecting program output to stdout and stderr:
```
happy_command > stdout.log # write stdout to file (overrides exists content)
sad_command 2> stderr.log # write stderr to file
mixed_command &> combined.log # write both stdout and stderr to file
happy_again >> stdout.log # add additional `>` to redirections to append rather than override
```

Piping the output of one command as input to another:
```
# prints line containing the word "ERROR"
cat debug.log | grep "ERROR"

# pretty print JSON response from API
curl -H "Content-Type: application/json" http://my-api/users | jq '.'

# Sort directories by size
du -h | sort -rh
```

Assign output of command to variable
```
# simple
output="$(echo 'hello!')"

# more complex
first_user_id="$(curl -H "Content-Type: application/json" http://my-api/users | jq -r '.users[0].id')"
```

## Allowing your script to take arguments

Positional Arguments
```
# Usage
./my-script hello world

echo "$0" # ./test, script path
echo "$1" # hello, first positional arg
echo "$2" # world, second arg

echo "$#" # 2, total number of args
echo "$*" # "hello world", expands all args as a single word
echo "$@" # "hello" "world", expands all args as separate words

# shift
echo "$1" # hello
shift # discard first arg, slide remaining args to left
echo "$1" # world

# print each arg
for arg in "$@"; do
  echo "$arg"
done
```

Environment variables + Parameter substitution:
```
# Usage
MY_VAR="some-value" ANOTHER_VAR=1 ./my-script

# declare a required environment variable
: ${REQUIRED_VAR:?} # will throw an error if variable is not set

# declare an optional environment variable
: ${OPTIONAL_VAR:=} # sets OPTIONAL_VAR to empty string if unset

# declare an optional environment variable with a default value
: ${OPTIONAL_VAR:=default_value} # sets OPTIONAL_VAR to `default_value` if unset

# make variable available to child processes
export MY_VAR
./my-child-script

# assign default value to positional arg
arg="${1:-default_value}" # sets `arg` to first positional arg if set, `default_value` otherwise
```
Note: The leading `:` prevents bash from running the variable contents as a command

Command line flags:
```
# invoke script with ./my_script -p foo -c bar
while getopts "c:p:" opt; do
  case $opt in
    c)
      c_value="$OPTARG"
      ;;
    p)
      p_value="$OPTARG"
      ;;
    *)
      echo "Unknown argument: $opt"
      ;;
  esac
done
```

## Working with files and directories

View and edit files
```
less output.log # view, but not change a file
vim main.go # a powerful file editor with a bit of a learning curve...
```

Filepath operations:
```
basename "/path/to/file.txt" # prints "file.txt"
dirname "/path/to/file.txt" # prints "/path/to/"
```

Create temporary files:
```
# Create a directory in /tmp
# 'XXXXX' will be replaced with random characters
tmpdir="$(mktemp -d /tmp/my-project.XXXXX)"
trap '{ rm -rf ${tmpdir}; }' EXIT # remove tmpdir on script exit
```

Changing directories (the nice way)
```
# GOOD, reset working dir to original value when finished
pushd "${WORKSPACE}" # changes working dir to ${WORKSPACE}
  # do some work
popd # changes working dir back to original value

# BAD, forgetting to reset user's working dir...
cd "${WORKSPACE}"
# do some work
exit 0
```

Extract file or directory names
```
FILE_PATH=/home/foo/my-file.txt

FILE="$(basename $FILE_PATH)" # "my-file.txt"
DIR="$(dirname $FILE_PATH)" # "/home/foo"
```

Find and delete files by name
```
# recursively finds all files and directories named 'test' under /some/dir
find /some/dir -name "test"

# recursively find all txt files under current directory
find . -name "*.txt" -type f

# delete all .tmp files
find . -name "*.tmp" -type f -delete
# or
find . -name "*.tmp" -type f | xargs rm
```

Archive and Extract files:
```
# Create archive of all files in current directory in
# tar format, compressed with gzip
tar czvf my_files.tgz ./*

# Extract to given directory
tar xzvf my_files.tgz -C /some/output/dir
```

Sourcing utility functions from other files
```
# ./utils.sh
pretty_print() {
  # do work
}

# ./my_script
source ./utils.sh

pretty_print "hello world!"
```
Note: The `.sh` extension is useful for indicating files that should be sourced

## Working with processes

Get the previous command's exit code:
```
set -e # Exit if any command exits non-zero

# do some setup

set +e # temporarily allow commands to exit non-zero
failing_command
exit_code="$?" # returns exit code of the previous command
set -e

if [ "${exit_code}" = "0" ]; then
  echo "Failed to do something. Exiting..."
  # do some cleanup
  exit 1
fi
```

Make a command non-interactive
```
yes | rm ./*.txt # equivalent to `rm -f *.txt`
```

Determine OS
```
platform="$( uname -s )"
case "${platform}" in
  Linux)
    echo "Linux"
    ;;
  Darwin)
    echo "Mac"
    ;;
  *)
    echo "Something else"
    ;;
esac
```

Run commands in sequence:
```
# stops if command exits non-zero
mkdir tmp && do-work && rm -r tmp

# stops if command exits zero
update-file || create-file

# run all commands regardless of exit value
do-work ; cat output.log
```

Capture PID and write to file:
```
# replace current process with another process, writing process ID to a file
echo $$ > $pidfile
exec some_process

# launch process in the background, writing background process ID to a file
some_process &
echo $! > $pidfile
```

Generate timestamps (useful for logging):
```
date +%Y-%m-%d # prints "2016-01-10"

date +%F # same result, shorthand for "+%Y-%m-%d"

date +%s # prints "1452484369", seconds since Epoch
         # useful for generating "unique" filenames
```

## HTTP utilities

Download a file:
```
wget https://imgs.xkcd.com/comics/escape_artist.png # saves escape_artist.png in working dir
wget http://imgs.xkcd.com/comics/escape_artist.png -O /tmp/xkcd.png # saves file at given path
wget --content-disposition https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent?v=3177 # save as remote filename rather than name in URL
```

Send HTTP requests:
```
curl -vL google.com # GET request with verbose output and follows redirects
curl -H "Content-Type: application/json" -X POST -d '{"key": "value"}' localhost:8080 # post JSON data
```

## Working with text

Print a multi-line string using a heredoc
```
cat <<EOF
Usage:
  ./my-script hello world
EOF
```
Note that `EOF` can be any unique delimiter.

Save heredoc to variable
```
result="$(cat <<EOF
some
multi-line
text
EOF)"
```

Write a heredoc to a file
```
cat > some-file.txt <<EOF
your
  file
    contents
      here
EOF
```

Print the n-th item in a line
```
WORDS="this is only a test"
echo "$WORDS" | cut -d ' ' -f3 # prints "only", index starts at 1
echo "$WORDS" | cut -d ' ' -f1-3 # prints "this is only"
echo "$WORDS" | cut -d ' ' -f1,f5 # prints "this test"

CSV="first,last,address"
echo "$CSV" | cut -d ',' -f2 # prints "last", changes delimiter
```

Replace characters in string
```
CSV="first,last,address"
echo "$WORDS" | sed 's/,/\n/g' # prints "first\nlast\naddress"
```

Remove lines matching a pattern
```
sed '/DEBUG/d` debug.log # prints file with lines containing DEBUG removed
sed -i '/^\s*$/d' output.txt # remove empty lines from file, overriding in-place
```

Get leading or trailing lines in file
```
head -n1 ./some_file # prints first line in file
tail -n1 ./some_file # prints last line in file
tail -f ./process.log # streams file contents as new lines are added, useful for debugging
```

Counting things
```
wc -w ./some-file # prints word count
wc -l ./some-file # line count
wc -m ./some-file # char count

echo "$output" | wc -w # also accepts stdin
```

Searching for text
```
# print lines matching pattern
grep 'foo' ./some-file
grep -i 'fOo' ./some-file # case insensitive
grep -v 'bar' ./some-file # inverse, print lines not matching regex
grep 'fo\+' ./some-file # regex, use egrep for better regex support
echo "${var}" | grep 'foo' # can be used with pipes

# check for running process name
ps aux | grep mysql
```

Regex
```
regex='[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}'
if [[ "10.10.0.255" =~ ${regex} ]]; then # do not surround regex variable in quotes
  echo "Match!"
else
  echo "No match..."
fi

# capture groups
regex='[a-z]+_([a-z]+)' # capture letters following `_`
[[ "first_last" =~ ${regex} ]]
last_name="${BASH_REMATCH[1]}" # [0] is the full match, [1] is the first capture group
```
Notes:
- Uses POSIX regex, e.g. `[[:digit:]]` instead of `\d`
- To avoid unexpected behavior, always store regex in a variable and
  do not quote the variable after the `=~` operator.

## Patterns I like

Setting reasonable default options
```
# exit immediately if a command exits non-zero
set -e

# treat unset variables as errors
set -u

# prints commands as they are executed
# Nice for logging in prod/CI environments, but probably omit if your script is
# intended to be run by humans
set -x

# sets return value of pipeline to non-zero if any command returns non-zero
set -o pipefail

# one-liner
set -eux -o pipefail
```

Locating other files safely
```
# get the absolute location of this script, following symlinks
my_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir="$( cd "${my_dir}/.." && pwd )" # assumes MY_DIR is one level below PROJECT_DIR

pushd "${project_dir}"
  cat ./data/config.yml
  ./scripts/other_script
popd
```

Boilerplate file template:
```
#!/bin/bash

set -eux -o pipefail

my_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_dir="$( cd "${my_dir}/.." && pwd )"

: ${REQUIRED_VAR:?}
: ${OPTIONAL_VAR:=}
: ${DEFAULT_VAR:=default-value}

# YOUR CODE HERE
```

## Pitfalls

- = vs -eq
- whitespace in variable assignment and conditionals
  - val = "some value" # syntax error, should be val="some value"
  - if ["${val}" = "some value"] # syntax error, needs spaces around []
- pipefail
- quoting variables
  - rm -rf $my_dir # rm -rf my files/my_dir
  - [ -z $VAL ] # [ -z ], syntax error if VAL is empty
- rm -rf "${output_dir}/*" # rm -rf /* if ${output_dir} is empty...
- Use ${HOME} instead of ~ in scripts
  - ~ does not expand when quoted
- "bash: ./my-script: Permission denied"
  - Make sure script is executable (`chmod +x ./my-script`)
