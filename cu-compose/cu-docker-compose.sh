# LICENCE : CloudUnit is available under the Affero Gnu Public License GPL V3 : https://www.gnu.org/licenses/agpl-3.0.html
# but CloudUnit is licensed too under a standard commercial license.
# Please contact our sales team if you would like to discuss the specifics of our Enterprise license.
# If you are not sure whether the GPL is right for you,
# you can always test our software under the GPL and inspect the source code before you contact us
# about purchasing a commercial license.

# LEGAL TERMS : "CloudUnit" is a registered trademark of Treeptik and can't be used to endorse
# or promote products derived from this project without prior written permission from Treeptik.
# Products or services derived from this software may not be called "CloudUnit"
# nor may "Treeptik" or similar confusing terms appear in their names without prior written permission.
# For any questions, contact us : contact@treeptik.fr

#!/usr/bin/env bash

##
##
## FUNCTIONS
##
##

function init {
    echo "init"
    mkdir -p /home/$USER/jenkins_home
    # BUG with jenkins... to investigate about rights
    sudo chmod -R 777 /home/$USER/jenkins_home
}

function with-elk {
    docker-compose  -f docker-compose.elk.yml \
                    -f docker-compose.yml \
    up -d
}

function with-elk-and-selenium {
    docker-compose  -f docker-compose.elk.yml \
                    -f docker-compose.selenium.yml \
                    -f docker-compose.yml \
    up -d
}

function reset {
    if [ "$1" != "-y" ]; then
        echo "Are you sure to delete them ? [y/n]"
        read PROD_ASW
        if [ "$PROD_ASW" != "y" ] && [ "$PROD_ASW" != "n" ]; then
            echo "Entrer y ou n!"
            exit 1
        elif [ "$PROD_ASW" = "n" ]; then
            exit 1
        fi
    fi
    docker-compose  -f docker-compose.elk.yml -f docker-compose.selenium.yml -f docker-compose.yml kill
    docker-compose  -f docker-compose.elk.yml -f docker-compose.selenium.yml -f docker-compose.yml rm -f
}

##
##
## MAIN
##
##

case "$1" in

'with-elk')
init && with-elk
;;

'with-elk-and-selenium')
init && with-elk-and-selenium
;;

'reset')
reset
;;


*)
echo ""
echo "Usage $0 "
echo "Example : $0 with-elk"
echo "Choice between : "
echo "                    with-elk"
echo "                    with-elk-and-selenium"
echo "                    reset"
echo ""
;;

esac

