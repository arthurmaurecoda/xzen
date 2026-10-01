#!/bin/bash
source quit.sh

VERSION="0.1.3"

###########################################################################################################################
LOGIN="xzen"
PASS_FILE="$(dirname "$0")/.xzen_password"

hash() {
  echo -n "$1" | sha256sum | cut -d' ' -f1
}


if [ ! -f "$PASS_FILE" ]; then
  hash "xzen" > "$PASS_FILE"
fi

login() {
  local attempts=0
  while [ $attempts -lt 3 ]; do
    read -rp "login: " user
    read -rsp "password: " pass; echo
    if [ "$user" = "$LOGIN" ] && [ "$(hash "$pass")" = "$(cat "$PASS_FILE")" ]; then
      echo "Welcome, ${user}. type <help> to see available commands"
      return 0
    fi
    echo "Wrong login or password."
    attempts=$((attempts+1))
  done
  echo "Too many failed attempts."
  exit 1
}


###########################################################################################################################

rps_beats() {
  [[ "$1" == superkitty && "$2" != superkitty ]] ||
  [[ "$1" == rock && "$2" == scissors ]] ||
  [[ "$1" == paper && "$2" == rock ]] ||
  [[ "$1" == scissors && "$2" == paper ]]
}


rps_choice() {
  local c
  while true; do
    read -rsp "${1}, your turn (rock/paper/scissors/superkitty): " c; echo
    case "${c,,}" in
      r | rock ) RPS_PICK=rock; return;;
      p | paper ) RPS_PICK=paper; return;;
      s | scissors ) RPS_PICK=scissors; return;;
      k | superkitty ) RPS_PICK=superkitty; return;;
      * ) echo "Invalid choice, try again.";;
    esac
  done
}

rps_game() {
  local p1 p2 s1=0 s2=0 c1 c2 round

  read -rp "Player 1 name: " p1
  read -rp "Player 2 name: " p2
  p1=${p1:-Player1}
  p2=${p2:-Player2}

  for round in 1 2 3; do
    echo
    echo "--- Round ${round}/3 ---"

    rps_choice "$p1"; c1=$RPS_PICK
    rps_choice "$p2"; c2=$RPS_PICK

    echo "${p1}: ${c1}  |  ${p2}: ${c2}"
    if [ "$c1" = "$c2" ]; then
      echo "Draw!"
    elif rps_beats "$c1" "$c2"; then
      echo "${p1} wins the round!"
      s1=$((s1+1))
    else
      echo "${p2} wins the round!"
      s2=$((s2+1))
    fi
    echo "Score: ${p1} ${s1} - ${s2} ${p2}"
  done

  echo
  if [ $s1 -gt $s2 ]; then
    echo "${p1} wins the game ${s1}-${s2}!"
  elif [ $s2 -gt $s1 ]; then
    echo "${p2} wins the game ${s2}-${s1}!"
  else
    echo "The game ends in a draw, ${s1}-${s2}."
  fi
}

###########################################################################################################################

cmd() {
  local command=$1
  shift   # "$@" now holds only the arguments

  case "${command}" in

    quit | exit )
      quit
      ;;

    help )
      echo "Available commands:"
      echo "  help                  list the commands"
      echo "  ls                    list files and folders (including hidden)"
      echo "  rm <file>             delete a file"
      echo "  rmd | rmdir <dir>     delete a folder"
      echo "  about                 description of this program"
      echo "  version | --v | vers  show the prompt version"
      echo "  age                   adult or minor?"
      echo "  quit                  exit the prompt"
      echo "  profil                first name, last name, age and email"
      echo "  passw                 change password (with confirmation)"
      echo "  cd <dir>              change directory (cd - goes back)"
      echo "  pwd                   print current directory"
      echo "  hour                  current time"
      echo "  httpget <url>         download a page's HTML"
      echo "  smtp                  send an email"
      echo "  open <file>           open a file in VIM"
      echo "  rps                   two-player rock paper scissors"
      echo "  rmdirwtf <files...>   delete several files (password required)"
      echo "  rapgod                rap god"
      ;;

    ls )
      ls -a "$@"
      ;;

    ohhestoomainstream )
      echo "well that's what they do when they get jealous and confuse it";;

    itsnothiphopitspop )
      echo "cause i found a hella way to fuse it";;


    rm )
      rm "$@"
      ;;

    rmd | rmdir )
      rmdir "$@"
      ;;

    rapgod )
      echo "Uh, summa-lumma, dooma-lumma, you assumin' I'm a human
      What I gotta do to get it through to you?
      I'm superhuman, innovative and I'm made of rubber
      So that anything you say is ricochetin' off of me, and it'll glue to you
      And I'm devastating, more than ever demonstrating
      How to give a motherfuckin' audience a feeling like it's levitating
      Never fading, and I know the haters are forever waiting
      For the day that they can say I fell off, they'll be celebrating
      'Cause I know the way to get 'em motivated
      I make elevating music, you make elevator music"
      ;;

    about )
      echo "Xzen: a custom shell written in Bash."
      ;;

    version | --v | vers )
      echo "Xzen version ${VERSION}"
      ;;

    age )
      read -rp "Age: " age
      if [[ ! "$age" =~ ^[0-9]+$ ]]; then
        echo "Please enter a valid number."
      elif [ "$age" -ge 18 ]; then
        echo "You are an adult."
      else
        echo "You are a minor."
      fi
      ;;

    profil )
      echo "First name: Arthur"
      echo "Last name:  Maure"
      echo "Age:        16"
      echo "Email:      arthur@maure.fr"
      ;;

    passw )
      read -rsp "New password: " p1; echo
      read -rsp "Confirm password: " p2; echo
      if [ "$p1" = "$p2" ]; then
        hash "$p1" > "$PASS_FILE"
        echo "Password changed."
      else
        echo "Passwords do not match."
      fi
      ;;

    cd )
      cd "$@"
      ;;

    pwd )
      pwd
      ;;

    hour )
      date +%H:%M
      ;;

    httpget )
      if [ -z "$1" ]; then
        echo "Usage: httpget <url>"
      else
        read -rp "File name: " file
        curl -s "$1" -o "$file" && echo "Saved to ${file}"
      fi
      ;;

    smtp )
      read -rp "Address: " to
      read -rp "Subject: " subject
      read -rp "Body: " body
      echo "$body" | mail -s "$subject" "$to" && echo "Mail sent."
      ;;

    open )
      vim "$1"
      ;;

    rps )
      rps_game
      ;;

    rmdirwtf )
      if [ $# -eq 0 ]; then
        echo "Usage: rmdirwtf <file1> [file2 ...]"
      else
        read -rsp "Password: " pass; echo
        if [ "$(hash "$pass")" = "$(cat "$PASS_FILE")" ]; then
          rm -- "$@"
        else
          echo "Wrong password. Nothing was deleted."
        fi
      fi
      ;;
      
    "" )
      ;;   

    * )
      echo "Unknown command: ${command}"
      ;;

  esac
}
###########################################################################################################################
main() {
  login
  lineCount=1

  while true; do
    date=$(date +%H:%M)
    echo -ne "${date} - [\033[31m${lineCount}\033[m] - \033[33mXzen\033[m ~ 🔯 ~ "
    read -r string

    cmd $string
    lineCount=$((lineCount+1))
  done
}

main