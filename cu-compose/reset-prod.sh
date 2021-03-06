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

source /etc/environment

if [[ $USER != "admincu" ]]; then
    echo "This script must be run as admincu"
    exit 1
fi

function reset {
    docker rm -vf $(docker ps -aq)
    docker volume rm $(docker volume ls -q)
    # in the future the networks too
}

echo -n "Do you agree with this? [yes or no]: "
read yno
case $yno in

        [yY] | [yY][Ee][Ss] )
                echo "Agreed"
                reset
                ;;

        [nN] | [n|N][O|o] )
                echo "Not agreed, you can't reinit the installation";
                exit 1
                ;;
        *) echo "Invalid input"
                exit 1
            ;;
esac







