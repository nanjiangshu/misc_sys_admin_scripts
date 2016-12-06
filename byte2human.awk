#!/usr/bin/awk -f
function isnum(x){return(x==x+0)}
BEGIN{
    split("B KB MB GB TB PB",type)
}
{
    y = 0;
    if(isnum($1)){
        x = $1;
        for(i=5;y < 1;i--){
            y = x / (2**(10*i));
        }
        tp = type[i+2];
        if(tp == "B"){
            printf ("%d %s\n", y, type[i+2]);
        } else{
            printf ("%.1f %s\n", y, type[i+2]);
        }
    }
}
END{
    }


