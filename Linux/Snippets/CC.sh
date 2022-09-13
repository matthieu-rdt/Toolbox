wget https://raw.githubusercontent.com/matthieu-rdt/Toolbox/master/Linux/ConfirmChoice.sh

source $HOME/ConfirmChoice.sh

ConfirmChoice "echo ok" && echo ok

rm $HOME/ConfirmChoice.sh
