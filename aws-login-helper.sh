#!/bin/bash

#script to assist with authenticating and logging into bakery aws instaces/tunnles
#assumes you have aws profiles setup already and named "bakery-$env"

#set aws ec2 variables (next itteration should pull this data from aws by request)
#dev
devBastion="i-0016015d217"
devWeb="i-0370d25488a"

#uat
uatBastion="i-04eb73fbc2a"
uatWeb="i-0089db65b68"

#staging
stagingBastion="i-093f5cf8eed2"
stagingWeb1="i-0c91d97b430a"
stagingWeb2="i-08aa3a8c101"

#production
productionBastion="i-0b8e6fee8"
productionWeb1="i-0aefa3143121"
productionWeb2="i-08dd20e8c1"

#prompt and store env variable (dev, uat, staging, production)
echo ""
read -p "Enter enviorment to use (dev, uat, staging, production): " env

#validate var
if [[ $env == dev || $env == uat || $env == staging || $env == production ]]; then
	echo "Selecting the $env evniorment."
	echo ""

else
	echo "Incorrect enviorment selected."
	echo ""
        exit

fi

#set web and bastion vars based on env var
if [[ $env == dev ]]; then
	bastion=$devBastion
	web=$devWeb

elif [[ $env == uat ]]; then
        bastion=$uatBastion
        web=$uatWeb

elif [[ $env == staging ]]; then
        bastion=$stagingBastion
        web1=$stagingWeb1
	      web2=$stagingWeb2

elif [[ $env == production ]]; then
        bastion=$productionBastion
        web1=$productionWeb1
	      web2=$productionWeb2

fi

#autenticate with aws
echo ""
echo "Logging into aws"
echo ""
export AWS_PROFILE=bakery-$env
aws sso login --profile bakery-$env

#move into menu, prompt for selection
echo ""
echo "1. open ssh tunnel via bastion"
echo "2. open ssh connection to bastion"
echo "3. open ssh connection to web instance"
echo "4. exit"
echo ""
read -p "Please select an option(#): " option

#execute option, or quit if incorrect option selected
if [[ $option == 1 ]]; then
        echo ""
        echo "opening ssh tunnel via bastion..."
	echo ""
        ssh -D 8000 ec2-user@$bastion
	exit

elif [[ $option == 2 ]]; then
	echo ""
        echo "opening ssh connection to bastion..."
        echo ""
        ssh ec2-user@$bastion
        exit

elif [[ $option == 3 ]]; then
        #proceed based on wether env is single or multi web server
	if [[ $env == staging || $env == production ]]; then
		echo ""
		read -p "Please select web server(1, 2): " server
		echo ""

		if [[ $server == 1 ]]; then
			echo ""
                	echo "opening ssh connection to web 1..."
                	echo ""
                	ssh ec2-user@$web1
                	exit

		elif [[ $server == 2 ]]; then
                        echo ""
                        echo "opening ssh connection to web 2..."
                        echo ""
                        ssh ec2-user@$web2
                        exit

		else
			echo ""
			echo "Incorrect web server option."
			echo ""
			exit

		fi

	else
		echo ""
        	echo "opening ssh connection to web..."
        	echo ""
        	ssh ec2-user@$web
        	exit
	fi

elif [[ $option == 4 ]]; then
        echo ""
        echo "exiting..."
        echo ""
        exit

else
	echo ""
	echo "Incorrect option selected."
        echo ""
        exit

fi
