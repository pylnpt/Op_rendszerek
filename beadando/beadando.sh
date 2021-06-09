#/bin/bash
#Név : Molnár Péter
#Neptunkód: H1MCKP


get_distilleries_data_by_slug(){
 url="https://whiskyhunter.net/api/distillery_data/$1/"
 echo "Would you like to save the results to a txt?(y\n)"
 read ans
 echo $ans
 if [[ ( $ans == "n") ]];
 then
 wh=$(curl ${url})
 echo $wh | jq '.[] |  .'
 elif [[ (  $ans == "y" ) ]];
 then
 dirname="distillery_data"
 output="$1"_info.txt
 mkdir -p $dirname
 pathname="$dirname/$output"
 wh=$(curl ${url})
 printf $wh | jq -r '(["DATE", "MAX_WINNING_BID", "MIN_WINNING_BID", "WINNING_BID_MEAN", "TRADING_VOLUME", "LOTS_COUNT"] | (., map(length*"="))), (.[] | [.dt , .winning_bid_max, .winning_bid_min, .winning_bid_mean, .trading_volume, .lots_count])| @tsv'|column -t  > $pathname
 else
 echo "That is not a valid option"
 fi
 echo "Done $pathname"
}

get_distilleries_info(){
 url="https://whiskyhunter.net/api/distilleries_info/"
 wh=$(curl ${url})
 echo  $wh | jq '.[] | .slug'
}

get_winning_bid_min_or_max(){
 url="https://whiskyhunter.net/api/distillery_data/$1/"
 wh=$(curl ${url})
 if [[ ( $2 == "max") ]];
 then
 echo "From the $1 distillery the maximum value of a winning bid is:"
 echo $wh | jq '.[] |= . | max_by(.winning_bid_max) | .winning_bid_max'
 echo "Date:"
 echo $wh | jq '.[] |= . | max_by(.winning_bid_max) | .dt'
 elif [[ ( $2 == "min") ]];
 then
 echo "From the $1 distillery the minimum value of a winning bid is:"
 echo $wh | jq '.[] |= . | min_by(.winning_bid_min) | .winning_bid_min'
 echo "Date:"
 echo $wh | jq '.[] |= . | min_by(.winning_bid_min) | .dt'
 else
 echo "Invalid command."
 fi
}

while getopts d:w:ha flag
do
	case "${flag}" in
		d) get_distilleries_data_by_slug ${OPTARG}
			;;
		h) clear
		   more manual.txt
			;;
		a) get_distilleries_info
			;;
		w) get_winning_bid_min_or_max ${OPTARG}
			;;
		*) echo "Invalid flag: - ${flag}" ;;
	esac
done
