BEGIN{
    COUNTER=0;
    FIRST_INSERT="";
    CURRENT_INSERT="";
    VALUE_STRING="";
    INSERTS[0] = "";
    LAST_RECORD_INSERT_COLLECTED=-1
}

function VALUESstartAt(){
    for(c=1;c <= NF;c++){
        if(tolower($c) == "values"){
            return c;
        }
    }
    return NF
}

function collectInsertPart(limit){
    if(NR == LAST_RECORD_INSERT_COLLECTED){
        return;
    }
    LAST_RECORD_INSERT_COLLECTED=NR;
    for(c=1;c <= limit;c++){
        CURRENT_INSERT = CURRENT_INSERT $c " ";
    }
    if(FIRST_INSERT == ""){
        FIRST_INSERT=CURRENT_INSERT;
    }
}

function collectValuesPart(start){
    for(;start <= NF;start++){
        VALUE_STRING = VALUE_STRING $start " ";
    }
}

function appendValuesToCurrentInsert(){
    INSERTS[COUNTER]=VALUE_STRING;
}

function printInsertsAndResetCounter(){
    printed_anything=0
    if(COUNTER > 0){
        print FIRST_INSERT;
        for(c=0;c <= COUNTER;c++){
            finalizer= c + 1 <= COUNTER ? ", " :"; "  ;
            if(length(INSERTS[c]) > 0){
                print INSERTS[c] finalizer;
                printed_anything++;
            }
        }
        if(printed_anything > 0){
            print "commit;"
        }
    }
    COUNTER=0;
}

tolower($0) ~ /^ *insert / {
    if(CURRENT_INSERT != FIRST_INSERT){
        appendValuesToCurrentInsert();
        printInsertsAndResetCounter();
        FIRST_INSERT = CURRENT_INSERT;
        VALUE_STRING="";
    }
    if(VALUE_STRING != ""){
        appendValuesToCurrentInsert();
        if(COUNTER >= COMMIT_EVERY){
            printInsertsAndResetCounter();
        }
    }
    CURRENT_INSERT=""
    VALUE_STRING=""
    start=VALUESstartAt();
    collectInsertPart(start);
    if(FIRST_INSERT != "" && start < NF && CURRENT_INSERT != FIRST_INSERT){
        printInsertsAndResetCounter();
        FIRST_INSERT = CURRENT_INSERT;
        VALUE_STRING="";
    }
    collectValuesPart(start + 1);
    COUNTER += 1;
}

tolower($0) !~ /^ *insert / {
    if(LAST_RECORD_INSERT_COLLECTED != -1){
        start=VALUESstartAt();
        collectInsertPart(start);
        collectValuesPart(start + 1);
    }
}

END{
    appendValuesToCurrentInsert();
    printInsertsAndResetCounter();

}

