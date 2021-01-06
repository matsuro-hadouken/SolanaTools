#!/bin/bash

# check if service running

loop_count="3"
sleep_interval="3"

monitoring_unit="solana.service"
instance_name="Solana Main Net"

PositiveCheck='loaded active running Solana Service'

# --------------------------------------------------

export PATH=$PATH:/usr/local/sbin

disaster='/usr/local/bin/emergency-alert.jpg' # picture to send in case of catastrophe.
log_file='/var/log/s_monitor.log' # Log file

function GetServiceStatus() {

    ServiceStatus=$(systemctl list-units -t service | grep "$monitoring_unit" | grep -o 'loaded active running Solana Service')

}

function CheckCondition() {

    GetServiceStatus

    if ! [[ "$ServiceStatus" == "$PositiveCheck" ]]; then

        print_log "WARN Invalid respors detected from $monitoring_unit - [ $ServiceStatus ] - going for loop check ..."

        telegram-notify --warning --text "Possible $monitoring_unit is down, going trough loop check ..."

        LoopCheck

    else

        print_log "INFO Check pass Ok, $monitoring_unit respond: [ $ServiceStatus ]"

    fi

}

function LoopCheck() {

    error_counter=1

    print_log "DEBUG Starting loop check, ping $monitoring_unit for $loop_count times with sleep interval $sleep_interval ..."
    print_log "DEBUG Error counter = $error_counter"

    for run in $(seq "$loop_count"); do

        print_log "DEBUG Cycle $run ..."
        print_log "DEBUG Error counter = $error_counter"
        print_log "DEBUG Sleeping for $sleep_interval seconds ..."

        sleep "$sleep_interval" && GetServiceStatus

        print_log "DEBUG $monitoring_unit replay: [ $ServiceStatus ]"

        if ! [[ "$ServiceStatus" == "$PositiveCheck" ]]; then

            print_log "DEBUG Negative replay from $monitoring_unit = [ $ServiceStatus ] "

            error_counter=$((error_counter + 1))

            print_log "DEBUG Error counter incremented = $error_counter"

        else

            print_log "DEBUG Check pass OK, $monitoring_unit service respond = [ $ServiceStatus ], flase alert, exiting ..."
            telegram-notify --success --text "Faslse alert, $monitoring_unit is up and running, nothing to worry about."

            exit 0

        fi

        if [[ "$error_counter" -ge $loop_count ]]; then

            print_log "ERROR $monitoring_unit - Service status = [ $ServiceStatus ]"
            telegram-notify --error --text "FATAL: $monitoring_unit on $instance_name is NOT running [ $ServiceStatus ], please wake up administrator." --photo "$disaster"

            exit 0

        fi

    done

}

print_log() {

    type_of_msg=$(echo "$@" | cut -d" " -f1)
    msg=$(echo "$@" | cut -d" " -f2-)

    [[ $type_of_msg == INFO ]] && type_of_msg="INFO"
    [[ $type_of_msg == WARN ]] && type_of_msg="WARN"
    [[ $type_of_msg == ERROR ]] && type_of_msg="ERROR"
    [[ $type_of_msg == DEBUG ]] && type_of_msg="        "

    echo " [$type_of_msg] :: $(date "+%Y.%m.%d-%H:%M:%S %Z") :: $msg" >>$log_file
}

CheckCondition
