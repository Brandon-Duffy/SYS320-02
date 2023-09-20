#!/bin/bash

# Storyline: Script to add and delete VPN peers

while getopts 'hdauc:' OPTION ; do
    case "$OPTION" in
        d) u_del=${OPTION} ;;
        a) u_add=${OPTION} ;;
        u) t_user=${OPTARG} ;;
        c) c_user=${OPTARG} ;;
        h)
            echo ""
            echo "Usage: $(basename $0) [-a] | [-d] -u username"
            echo ""
            exit 1
            ;;
        *)
            echo "Invalid value."
            exit 1
            ;;
    esac
done

# Check user existence in the wg0.conf file
if [[ $c_user ]]; then
    if grep -q "# $c_user begin" wg0.conf; then
        echo "User $c_user exists in wg0.conf."
        exit 0
    else
        echo "User $c_user does not exist in wg0.conf."
        exit 1
    fi
fi

# Check to see if the -a and -d are empty or if they are both specified throw an error
if [[ -z $u_del && -z $u_add ]] || [[ -n $u_del && -n $u_add ]]; then
    echo "Please specify -a or -d and the -u and username."
    exit 1
fi

# Check to ensure -u is specified
if [[ (-n "$u_del" || -n "$u_add") && -z "$t_user" ]]; then
    echo "Please specify a user (-u)!"
    echo "Usage: $(basename $0) [-a][-d] -u username"
    exit 1
fi

# Delete a user
if [[ -n $u_del ]]; then
    echo "Deleting user..."
    sed -i "/# ${t_user} begin/,/# ${t_user} end/d" wg0.conf
fi

# Add a user
if [[ ${u_add} ]]
then

    echo "Create the User..."
    bash peer.bash ${t_user}

fi
