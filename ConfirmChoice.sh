# Function from Manu
function ConfirmChoice ()
{
        ConfYorN="";
                while [ "${ConfYorN}" != "y" -a "${ConfYorN}" != "Y" -a "${ConfYorN}" != "n" -a "${ConfYorN}" != "N" ]
                do
                        echo -n $1 "(y/n) : "
                        read ConfYorN
                done
        [ "${ConfYorN}" == "y" -o "${ConfYorN}" == "Y" ] && return 0 || return 1
}

#	Usage
#	ConfirmChoice "Do you want to update your sources" && apt update
